# Upgrade Advisor — English Output Templates

Use the labels and messages below when generating output in English.

## Section Headers

- report_title: "Upgrade Advisor Report"
- env_section: "Environment"
- new_features_section: "New Features Available"
- deprecations_section: "Deprecation Warnings"
- config_section: "Configuration Improvements"
- quick_wins_section: "Quick Wins"
- detailed_section: "Detailed Recommendations"
- summary_section: "Summary"

## Table Headers

- col_feature: "Feature"
- col_since: "Since"
- col_impact: "Impact"
- col_effort: "Effort"
- col_action: "Action"
- col_pattern: "Pattern"
- col_file: "File"
- col_deprecated_since: "Deprecated Since"
- col_migration: "Migration"
- col_area: "Area"
- col_current: "Current"
- col_recommended: "Recommended"
- col_rationale: "Rationale"

## Impact Labels

- impact_high: "High"
- impact_medium: "Medium"
- impact_low: "Low"

## Effort Labels

- effort_low: "Low (< 5 min)"
- effort_medium: "Medium (5-30 min)"
- effort_high: "High (> 30 min)"

## Category Labels

- cat_adopt: "Adopt"
- cat_migrate: "Migrate"
- cat_optimize: "Optimize"
- cat_alert: "Alert"

## Messages

- msg_cache_stale: "Release notes cache is {days} days old. Refreshing..."
- msg_cache_fresh: "Using cached release data (fetched {time_ago})."
- msg_fetching: "Fetching latest release notes from GitHub..."
- msg_no_updates: "Your setup is already well-aligned with the latest release. No new recommendations."
- msg_found: "Found {count} recommendations across {releases} releases."
- msg_version_current: "Claude Code version: {version}"
- msg_version_unknown: "Could not determine Claude Code version."
- msg_releases_analyzed: "Releases analyzed: {from} through {to} ({count} releases)"
- msg_files_scanned: "Files scanned: {count}"
- msg_offer_apply: "Would you like me to apply any of these recommendations? Specify the numbers or 'all'."
- msg_complement: "For token-level optimization, also try `/token-audit` from claude-token-optimizer."
- msg_whatsnew_title: "What's New in Claude Code"
- msg_whatsnew_empty: "No recent releases found."
- msg_deprecation_title: "Deprecation Check Report"
- msg_deprecation_clean: "No deprecated patterns detected in your setup."
- msg_deprecation_found: "Found {count} deprecated patterns."
- msg_deprecation_fix_offer: "Use `--fix` to apply recommended migrations."
