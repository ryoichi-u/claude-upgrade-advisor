---
name: upgrade-advisor
description: Analyze your Claude Code setup against latest release notes and best practices. Recommends feature adoption, deprecation fixes, and configuration improvements.
version: 0.1.0
argument-hint: "[--lang en|ja|auto] [--scope full|quick] [--since <version>] [--force]"
allowed-tools: [Read, Glob, Grep, Bash(bash*), Bash(claude*), Bash(cat*), Bash(gh*), Bash(python3*), Bash(date*), Bash(ls*), Bash(wc*), WebFetch, WebSearch, Edit]
---

# Upgrade Advisor

Analyze the user's Claude Code setup against the latest release notes, feature catalog, and best practices. Generate a prioritized report of improvements with actionable recommendations.

## Step 0: Language Detection

Determine the output language:

1. Check `$ARGUMENTS` for `--lang en` or `--lang ja` — use explicitly if present
2. If `--lang auto` or no `--lang` flag:
   - Read the root `CLAUDE.md` (first 50 lines). Compute multi-byte ratio: `(byte_count - char_count) / byte_count`. If >= 0.20, use Japanese
   - Alternatively check `$LANG` environment variable for `ja_JP`
3. Default: English

Load the appropriate i18n template from `references/i18n/en.md` or `references/i18n/ja.md`. Use its labels for all output headers, table columns, and messages. Technical terms (CLAUDE.md, hooks, settings.json, skills, allowed-tools, etc.) always remain in English.

## Step 1: Fetch Release Notes

Run the fetch script:
```
bash ${CLAUDE_PLUGIN_ROOT}/scripts/fetch-releases.sh
```

If `--force` is in `$ARGUMENTS`, pass `--force` to the script.

The script:
- Returns the cache file path on stdout
- Creates/updates `~/.claude/cache/upgrade-advisor/releases.json`
- Uses `gh api` (primary) or `curl` (fallback) for GitHub releases
- Respects 24h cache validity

Read the returned JSON file. This is an array of release objects, each with:
- `version`, `date`, `name`, `body`, `url`
- `features[]`, `deprecations[]`, `breaking[]`, `improvements[]`, `fixes[]`

If `--since <version>` is in `$ARGUMENTS`, filter releases to only those newer than the specified version.

If fetching fails, inform the user and offer alternatives:
- "Run with internet access"
- "Provide a CHANGELOG.md path for offline analysis"

## Step 2: Detect Current Version

Run:
```
claude --version 2>/dev/null || echo "unknown"
```

Record the version. If unknown, note it in the report but continue analysis (the feature catalog and patterns still apply).

Determine how many releases are "new" relative to the user's version.

## Step 3: Scan User Setup

Inventory the user's Claude Code configuration by reading these files:

**CLAUDE.md files** — Glob for `**/CLAUDE.md` in the project root (max depth 3)
**Commands** — Glob for `.claude/commands/**/*.md`
**Agents** — Glob for `.claude/agents/**/*.md` and `agents/**/*.md`
**Skills** — Glob for `skills/**/SKILL.md` and `.claude/skills/**/SKILL.md`
**Settings** — Read `.claude/settings.json` and `.claude/settings.local.json` if they exist
**Hooks** — Read hooks from settings.json `hooks` section, and `hooks/hooks.json` if it exists
**MCP** — Read `.mcp.json` and `.claude/.mcp.json` if they exist
**Plugin manifest** — Read `.claude-plugin/plugin.json` if it exists

For each file found, extract:
- Frontmatter fields (allowed-tools, model, description, argument-hint, etc.)
- Tool references in the body
- Hook types and events configured
- MCP server types
- File size (lines, characters)

Count total files scanned for the report header.

## Step 4: Cross-Reference Analysis

Load the analysis rules from `references/analysis-rules.md` and patterns from the upgrade-advisor skill's `references/analysis-patterns.md` and `references/feature-catalog.md`.

For each analysis pattern (P-HOOK-*, P-SKILL-*, P-AGENT-*, P-CONFIG-*, P-MCP-*, P-STRUCT-*):
1. Apply the **Detection** logic against the scanned files from Step 3
2. If the pattern matches (an improvement opportunity exists), create a recommendation

For each release note entry (features, deprecations, breaking changes):
1. Check if the user's setup already uses or is affected by this change
2. Classify the recommendation: **Adopt** / **Migrate** / **Optimize** / **Alert**

Score each recommendation using the priority scoring from `references/analysis-rules.md`:
- Impact (High=3, Medium=2, Low=1)
- Effort (Low=3, Medium=2, High=1)
- Category bonus (Alert=+4, Migrate=+3, Adopt=+2, Optimize=+1)

Sort recommendations by score descending. If `--scope quick`, limit to top 5. Otherwise top 15 (or all with `--scope full`).

Identify **Quick Wins**: recommendations where Impact >= Medium AND Effort == Low.

## Step 5: Generate Report

Use the output format from `references/output-format.md` and i18n labels from the loaded template.

Structure the report as:
1. **Environment** — Version, releases analyzed, files scanned
2. **Quick Wins** — Top low-effort/high-impact items (always first for actionability)
3. **New Features Available** — Adopt category, table + expandable details
4. **Deprecation Warnings** — Migrate category, table with specific files and migration paths
5. **Configuration Improvements** — Optimize category
6. **Summary** — Counts by category

For each recommendation with a clear before/after transformation, include a `<details>` block showing the code change.

Always include specific file paths that need to change.

## Step 6: Offer Actions

After presenting the report:
1. Ask the user if they want to apply any recommendations (by number or 'all')
2. If the user selects items, apply changes with Edit tool, one at a time, confirming each
3. Reference complementary tools where relevant (e.g., "For deeper token analysis, try `/token-audit`")

Do NOT auto-apply changes without explicit user confirmation.

## Notes

- Keep the report concise and scannable — use tables for overview, details for depth
- If no recommendations are found, congratulate the user and suggest running periodically
- If the cache is stale (>7 days), mention it at the top of the report
- When recommending plugin format migration, acknowledge it requires restructuring and suggest a phased approach
