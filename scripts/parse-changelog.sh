#!/usr/bin/env bash
# parse-changelog.sh — Parse CHANGELOG.md into structured JSON
# Usage: bash parse-changelog.sh <changelog-path> [--limit N]
# Fallback parser when GitHub API is unavailable
# Output: JSON array to stdout

set -euo pipefail

CHANGELOG_PATH="${1:-}"
LIMIT=50

if [[ -z "${CHANGELOG_PATH}" ]]; then
  echo "Usage: parse-changelog.sh <changelog-path> [--limit N]" >&2
  exit 1
fi

if [[ ! -f "${CHANGELOG_PATH}" ]]; then
  echo "Error: File not found: ${CHANGELOG_PATH}" >&2
  exit 1
fi

shift
while [[ $# -gt 0 ]]; do
  case "$1" in
    --limit) LIMIT="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

python3 << 'PYEOF'
import json
import re
import sys

def parse_changelog(path, limit):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    releases = []
    # Split by version headers (## [version] or ## version)
    version_pattern = r'^##\s+\[?v?(\d+\.\d+\.\d+(?:-[a-zA-Z0-9.]+)?)\]?(?:\s*[-–—]\s*(.+?))?$'

    lines = content.split('\n')
    current_release = None
    current_section = None

    section_map = {
        'features': r'(?:new\s+features?|features?|additions?|added)',
        'deprecations': r'(?:deprecat(?:ed|ions?)|removed|removals?)',
        'breaking': r'(?:breaking\s+changes?|breaking)',
        'improvements': r'(?:improvements?|enhancements?|updates?|changed)',
        'fixes': r'(?:bug\s*fix(?:es)?|fix(?:es)?|resolved)'
    }

    for line in lines:
        stripped = line.strip()

        # Check for version header
        ver_match = re.match(version_pattern, stripped, re.MULTILINE)
        if ver_match:
            if current_release and len(releases) < limit:
                releases.append(current_release)

            version = ver_match.group(1)
            date_str = ver_match.group(2).strip() if ver_match.group(2) else ''

            current_release = {
                'version': version,
                'date': date_str,
                'name': f'v{version}',
                'body': '',
                'prerelease': False,
                'url': '',
                'features': [],
                'deprecations': [],
                'breaking': [],
                'improvements': [],
                'fixes': []
            }
            current_section = None
            continue

        if not current_release:
            continue

        # Check for section header
        section_match = re.match(r'^#{3,4}\s+(.+)', stripped)
        if section_match:
            header = section_match.group(1).strip().lower()
            matched = False
            for section, pattern in section_map.items():
                if re.search(pattern, header, re.IGNORECASE):
                    current_section = section
                    matched = True
                    break
            if not matched:
                current_section = 'improvements'
            continue

        # Collect items
        item_match = re.match(r'^[-*]\s+(.+)', stripped)
        if item_match and current_section and current_release:
            current_release[current_section].append(item_match.group(1).strip())

        # Accumulate body
        if current_release:
            current_release['body'] += line + '\n'

    # Don't forget last release
    if current_release and len(releases) < limit:
        releases.append(current_release)

    return releases[:limit]

changelog_path = sys.argv[1]
limit = int(sys.argv[2])
releases = parse_changelog(changelog_path, limit)
print(json.dumps(releases, indent=2, ensure_ascii=False))
PYEOF
"${CHANGELOG_PATH}" "${LIMIT}"
