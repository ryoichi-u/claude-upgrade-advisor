#!/usr/bin/env bash
# fetch-releases.sh — Fetch Claude Code releases from GitHub API
# Usage: bash fetch-releases.sh [--force] [--limit N]
# Output: writes to ~/.claude/cache/upgrade-advisor/releases.json

set -euo pipefail

CACHE_DIR="${HOME}/.claude/cache/upgrade-advisor"
CACHE_FILE="${CACHE_DIR}/releases.json"
META_FILE="${CACHE_DIR}/releases.meta.json"
CACHE_MAX_AGE_SECONDS=86400  # 24 hours
REPO="anthropics/claude-code"
LIMIT=50
FORCE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=true; shift ;;
    --limit) LIMIT="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

# Ensure cache directory exists
mkdir -p "${CACHE_DIR}"

# Check cache freshness (skip fetch if fresh and not forced)
if [[ "${FORCE}" == "false" && -f "${CACHE_FILE}" && -f "${META_FILE}" ]]; then
  if command -v python3 &>/dev/null; then
    FETCHED_AT=$(python3 -c "import json,sys; print(json.load(open(sys.argv[1]))['fetched_at'])" "${META_FILE}" 2>/dev/null || echo "")
  else
    FETCHED_AT=$(grep -o '"fetched_at":"[^"]*"' "${META_FILE}" | head -1 | cut -d'"' -f4)
  fi

  if [[ -n "${FETCHED_AT}" ]]; then
    if command -v python3 &>/dev/null; then
      AGE_SECONDS=$(python3 -c "
from datetime import datetime, timezone
import sys
fetched = datetime.fromisoformat(sys.argv[1].replace('Z', '+00:00'))
now = datetime.now(timezone.utc)
print(int((now - fetched).total_seconds()))
" "${FETCHED_AT}" 2>/dev/null || echo "999999")
    else
      AGE_SECONDS=999999
    fi

    if [[ "${AGE_SECONDS}" -lt "${CACHE_MAX_AGE_SECONDS}" ]]; then
      echo "${CACHE_FILE}"
      exit 0
    fi
  fi
fi

# Detect available HTTP client
fetch_releases_gh() {
  gh api "repos/${REPO}/releases" --paginate --jq "
    [.[] | {
      version: .tag_name,
      date: .published_at,
      name: .name,
      body: .body,
      prerelease: .prerelease,
      url: .html_url
    }] | sort_by(.date) | reverse | .[:${LIMIT}]
  "
}

fetch_releases_curl() {
  local token="${GITHUB_TOKEN:-}"
  local auth_header=""
  if [[ -n "${token}" ]]; then
    auth_header="-H \"Authorization: Bearer ${token}\""
  fi

  local page=1
  local all_releases="[]"

  while true; do
    local response
    response=$(eval curl -sS \
      -H "Accept: application/vnd.github+json" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      ${auth_header} \
      "https://api.github.com/repos/${REPO}/releases?per_page=30&page=${page}")

    # Check for empty response or error
    local count
    count=$(echo "${response}" | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d) if isinstance(d,list) else 0)" 2>/dev/null || echo "0")

    if [[ "${count}" -eq 0 ]]; then
      break
    fi

    all_releases=$(python3 -c "
import json, sys
existing = json.loads(sys.argv[1])
new = json.load(sys.stdin)
result = existing + [{
    'version': r.get('tag_name',''),
    'date': r.get('published_at',''),
    'name': r.get('name',''),
    'body': r.get('body',''),
    'prerelease': r.get('prerelease', False),
    'url': r.get('html_url','')
} for r in new if isinstance(new, list)]
print(json.dumps(result))
" "${all_releases}" <<< "${response}")

    local current_total
    current_total=$(echo "${all_releases}" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")
    if [[ "${current_total}" -ge "${LIMIT}" ]]; then
      break
    fi

    page=$((page + 1))
    if [[ "${page}" -gt 5 ]]; then
      break  # Safety limit
    fi
  done

  echo "${all_releases}" | python3 -c "
import json, sys
data = json.load(sys.stdin)
data.sort(key=lambda x: x.get('date',''), reverse=True)
print(json.dumps(data[:${LIMIT}], ensure_ascii=False))
"
}

# Parse release note body into structured sections
parse_release_bodies() {
  python3 -c "
import json, sys, re

def classify_item(text):
    \"\"\"Classify a changelog item by its content keywords.\"\"\"
    t = text.lower()
    # Breaking changes
    if re.search(r'breaking\s+change|BREAKING|removed support for|no longer support', text):
        return 'breaking'
    # Deprecations
    if re.search(r'deprecat|removed|sunset', t):
        return 'deprecations'
    # Bug fixes
    if re.search(r'^fix(?:ed|es)?[\s:]|bug\s*fix|resolved|patch(?:ed)?|corrected|regression', t):
        return 'fixes'
    # New features (Added, New, Introduced)
    if re.search(r'^added\s|^new\s|^introduc|^launch|^support(?:ed|s)?\s+(?:new|for)', t):
        return 'features'
    # Default: improvement
    return 'improvements'

def parse_body(body):
    if not body:
        return {'features': [], 'deprecations': [], 'breaking': [], 'improvements': [], 'fixes': []}

    sections = {
        'features': [],
        'deprecations': [],
        'breaking': [],
        'improvements': [],
        'fixes': []
    }

    # Patterns for explicit section headers (case-insensitive)
    section_patterns = {
        'features': r'(?:new\s+features?|features?|additions?|added)',
        'deprecations': r'(?:deprecat(?:ed|ions?)|removed|removals?)',
        'breaking': r'(?:breaking\s+changes?|breaking)',
        'improvements': r'(?:improvements?|enhancements?|updates?|changed|what.?s\s+changed)',
        'fixes': r'(?:bug\s*fix(?:es)?|fix(?:es)?|resolved)'
    }

    lines = body.split('\n')
    current_section = None
    has_explicit_sections = False

    # First pass: detect if there are explicit categorized sections
    for line in lines:
        stripped = line.strip()
        header_match = re.match(r'^#{2,4}\s+(.+)', stripped)
        if header_match:
            header_text = header_match.group(1).strip().lower()
            for section, pattern in section_patterns.items():
                if section != 'improvements' and re.search(pattern, header_text, re.IGNORECASE):
                    has_explicit_sections = True
                    break

    # Second pass: parse items
    for line in lines:
        stripped = line.strip()

        # Check for section headers
        header_match = re.match(r'^#{2,4}\s+(.+)', stripped)
        if header_match:
            header_text = header_match.group(1).strip().lower()
            matched = False
            for section, pattern in section_patterns.items():
                if re.search(pattern, header_text, re.IGNORECASE):
                    current_section = section
                    matched = True
                    break
            if not matched:
                current_section = 'improvements'
            continue

        # Collect list items
        item_match = re.match(r'^[-*]\s+(.+)', stripped)
        if item_match:
            item_text = item_match.group(1).strip()
            if has_explicit_sections and current_section:
                # Use explicit section headers
                sections[current_section].append(item_text)
            else:
                # Auto-classify by item content (flat list format like Claude Code uses)
                category = classify_item(item_text)
                sections[category].append(item_text)

    return sections

data = json.load(sys.stdin)
for release in data:
    parsed = parse_body(release.get('body', ''))
    release.update(parsed)

print(json.dumps(data, indent=2, ensure_ascii=False))
"
}

# Execute fetch
echo "Fetching releases from ${REPO}..." >&2

RAW_DATA=""
SOURCE=""

if command -v gh &>/dev/null; then
  RAW_DATA=$(fetch_releases_gh 2>/dev/null) && SOURCE="gh-api" || true
fi

if [[ -z "${RAW_DATA}" || "${RAW_DATA}" == "[]" || "${RAW_DATA}" == "null" ]]; then
  if command -v curl &>/dev/null && command -v python3 &>/dev/null; then
    RAW_DATA=$(fetch_releases_curl 2>/dev/null) && SOURCE="curl-api" || true
  fi
fi

if [[ -z "${RAW_DATA}" || "${RAW_DATA}" == "[]" || "${RAW_DATA}" == "null" ]]; then
  echo "Error: Failed to fetch releases. Ensure 'gh' or 'curl' + 'python3' are available." >&2
  exit 1
fi

# Parse bodies into structured data
PARSED_DATA=$(echo "${RAW_DATA}" | parse_release_bodies)

# Write cache
echo "${PARSED_DATA}" > "${CACHE_FILE}"

# Write metadata
NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
COUNT=$(echo "${PARSED_DATA}" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))")

cat > "${META_FILE}" << METAEOF
{
  "fetched_at": "${NOW}",
  "source": "${SOURCE}",
  "count": ${COUNT},
  "repo": "${REPO}"
}
METAEOF

echo "Cached ${COUNT} releases to ${CACHE_FILE}" >&2
echo "${CACHE_FILE}"
