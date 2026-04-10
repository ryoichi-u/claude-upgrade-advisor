---
description: Scan your Claude Code setup for deprecated patterns and suggest migrations
allowed-tools: [Read, Glob, Grep, Bash(bash*), Bash(cat*), Bash(gh*), Bash(python3*), Bash(date*), Bash(wc*), Edit]
argument-hint: "[--fix] [--lang en|ja|auto]"
---

# Check Deprecations

Scan the user's Claude Code setup specifically for deprecated patterns and provide migration guidance. Faster and more focused than the full `/upgrade-advisor`.

## Language Detection

1. Check `$ARGUMENTS` for `--lang en` or `--lang ja`
2. If absent: read root `CLAUDE.md` multi-byte ratio. If >= 0.20, use Japanese
3. Default: English

For Japanese:
- Title: "非推奨パターンチェック レポート"
- Clean: "セットアップに非推奨パターンは検出されませんでした。"
- Found: "{count}件の非推奨パターンが見つかりました。"

For English:
- Title: "Deprecation Check Report"
- Clean: "No deprecated patterns detected in your setup."
- Found: "Found {count} deprecated patterns."

## Load Deprecation Data

1. Read the feature catalog at `${CLAUDE_PLUGIN_ROOT}/skills/upgrade-advisor/references/feature-catalog.md` — focus on the **Deprecated Patterns** table
2. Read the analysis patterns at `${CLAUDE_PLUGIN_ROOT}/skills/upgrade-advisor/references/analysis-patterns.md` — use all P-* patterns that detect deprecated or outdated configurations
3. Optionally read cached release data from `~/.claude/cache/upgrade-advisor/releases.json` for additional deprecation entries

## Scan User Files

Inventory:
- `.claude/commands/**/*.md`
- `.claude/agents/**/*.md`
- `skills/**/SKILL.md`
- `.claude/settings.json` and `.claude/settings.local.json`
- `hooks/hooks.json` and hooks section in settings
- `.mcp.json`
- `.claude-plugin/plugin.json`
- `CLAUDE.md` (root)

For each file, check all deprecation detection patterns.

## Generate Report

For each deprecated pattern found:

| # | Pattern | File | Deprecated Since | Migration |
|---|---------|------|------------------|-----------|
| 1 | Description | `path/to/file` | vX.Y.Z | Specific migration steps |

If `--fix` is in `$ARGUMENTS`:
- For each pattern, show the specific change needed
- Ask the user to confirm before applying ("Apply fix #1? [y/n]")
- Apply changes using the Edit tool
- Report what was changed

If `--fix` is NOT specified and deprecations were found:
- At the end, mention: "Run `/cc-check-deprecations --fix` to apply recommended migrations."

If no deprecations found:
- Output the clean message and suggest running `/upgrade-advisor` for broader improvements

## Migration Examples

When suggesting fixes, always show before/after:

```
**#1: Missing allowed-tools** in `.claude/commands/deploy.md`

Before:
---
description: Deploy to production
---

After:
---
description: Deploy to production
allowed-tools: [Bash(git*), Bash(npm*), Read]
---
```
