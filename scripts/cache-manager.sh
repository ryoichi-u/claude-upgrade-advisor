#!/usr/bin/env bash
# cache-manager.sh — Manage upgrade-advisor release note cache
# Usage:
#   bash cache-manager.sh check-staleness   # Print warning if cache is stale (>7 days)
#   bash cache-manager.sh invalidate        # Delete all cached data
#   bash cache-manager.sh path              # Print cache directory path
#   bash cache-manager.sh age               # Print cache age in hours
#   bash cache-manager.sh status            # Print cache status summary

set -euo pipefail

CACHE_DIR="${HOME}/.claude/cache/upgrade-advisor"
CACHE_FILE="${CACHE_DIR}/releases.json"
META_FILE="${CACHE_DIR}/releases.meta.json"
STALE_THRESHOLD_DAYS=7

get_cache_age_hours() {
  if [[ ! -f "${META_FILE}" ]]; then
    echo "-1"
    return
  fi

  local fetched_at
  if command -v python3 &>/dev/null; then
    fetched_at=$(python3 -c "import json; print(json.load(open('${META_FILE}'))['fetched_at'])" 2>/dev/null || echo "")
  else
    fetched_at=$(grep -o '"fetched_at":"[^"]*"' "${META_FILE}" | head -1 | cut -d'"' -f4)
  fi

  if [[ -z "${fetched_at}" ]]; then
    echo "-1"
    return
  fi

  if command -v python3 &>/dev/null; then
    python3 -c "
from datetime import datetime, timezone
fetched = datetime.fromisoformat('${fetched_at}'.replace('Z', '+00:00'))
now = datetime.now(timezone.utc)
hours = (now - fetched).total_seconds() / 3600
print(int(hours))
" 2>/dev/null || echo "-1"
  else
    echo "-1"
  fi
}

case "${1:-help}" in
  check-staleness)
    if [[ ! -f "${CACHE_FILE}" ]]; then
      echo "[upgrade-advisor] No release notes cache found. Run /upgrade-advisor or /cc-whatsnew to fetch."
      exit 0
    fi

    AGE_HOURS=$(get_cache_age_hours)
    if [[ "${AGE_HOURS}" -eq -1 ]]; then
      echo "[upgrade-advisor] Cannot determine cache age. Run /upgrade-advisor or /cc-whatsnew to refresh."
      exit 0
    fi

    STALE_THRESHOLD_HOURS=$((STALE_THRESHOLD_DAYS * 24))
    if [[ "${AGE_HOURS}" -ge "${STALE_THRESHOLD_HOURS}" ]]; then
      AGE_DAYS=$((AGE_HOURS / 24))
      echo "[upgrade-advisor] Release notes cache is ${AGE_DAYS} days old. Run /upgrade-advisor or /cc-whatsnew to refresh."
    fi
    # If fresh, output nothing (silent)
    ;;

  invalidate)
    if [[ -d "${CACHE_DIR}" ]]; then
      rm -f "${CACHE_FILE}" "${META_FILE}"
      echo "Cache invalidated: ${CACHE_DIR}"
    else
      echo "No cache directory found."
    fi
    ;;

  path)
    echo "${CACHE_DIR}"
    ;;

  age)
    AGE_HOURS=$(get_cache_age_hours)
    if [[ "${AGE_HOURS}" -eq -1 ]]; then
      echo "No cache or unable to determine age."
    else
      echo "${AGE_HOURS} hours"
    fi
    ;;

  status)
    if [[ ! -f "${CACHE_FILE}" ]]; then
      echo "Cache: not initialized"
      echo "Path: ${CACHE_DIR}"
      exit 0
    fi

    AGE_HOURS=$(get_cache_age_hours)
    if command -v python3 &>/dev/null && [[ -f "${META_FILE}" ]]; then
      COUNT=$(python3 -c "import json; print(json.load(open('${META_FILE}')).get('count', '?'))" 2>/dev/null || echo "?")
      SOURCE=$(python3 -c "import json; print(json.load(open('${META_FILE}')).get('source', '?'))" 2>/dev/null || echo "?")
      FETCHED=$(python3 -c "import json; print(json.load(open('${META_FILE}')).get('fetched_at', '?'))" 2>/dev/null || echo "?")
    else
      COUNT="?"
      SOURCE="?"
      FETCHED="?"
    fi

    STALE_THRESHOLD_HOURS=$((STALE_THRESHOLD_DAYS * 24))
    if [[ "${AGE_HOURS}" -ge "${STALE_THRESHOLD_HOURS}" ]]; then
      FRESHNESS="stale"
    else
      FRESHNESS="fresh"
    fi

    echo "Cache: ${FRESHNESS}"
    echo "Path: ${CACHE_DIR}"
    echo "Releases: ${COUNT}"
    echo "Source: ${SOURCE}"
    echo "Fetched: ${FETCHED}"
    echo "Age: ${AGE_HOURS} hours"
    ;;

  help|--help|-h)
    echo "Usage: cache-manager.sh <command>"
    echo ""
    echo "Commands:"
    echo "  check-staleness   Print warning if cache is stale (>7 days)"
    echo "  invalidate        Delete all cached data"
    echo "  path              Print cache directory path"
    echo "  age               Print cache age in hours"
    echo "  status            Print cache status summary"
    ;;

  *)
    echo "Unknown command: $1" >&2
    echo "Run 'cache-manager.sh help' for usage." >&2
    exit 1
    ;;
esac
