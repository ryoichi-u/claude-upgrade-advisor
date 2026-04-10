---
description: Show recent Claude Code release notes summary
allowed-tools: [Read, Bash(bash*), Bash(gh*), Bash(cat*), Bash(date*), Bash(python3*), WebFetch]
argument-hint: "[<count>] [--since <version>] [--force] [--lang en|ja|auto]"
---

# What's New in Claude Code

Show a summary of recent Claude Code releases. This is a lightweight, read-only view of release notes without setup analysis.

## Language Detection

1. Check `$ARGUMENTS` for `--lang en` or `--lang ja`
2. If absent or `auto`: read root `CLAUDE.md` first 50 lines, compute multi-byte ratio. If >= 0.20, use Japanese
3. Default: English

For Japanese, use these headers:
- Title: "Claude Code 最新情報"
- Sections: "新機能", "改善", "バグ修正", "破壊的変更", "非推奨化"
- Empty message: "最近のリリースが見つかりませんでした。"

For English, use:
- Title: "What's New in Claude Code"
- Sections: "New Features", "Improvements", "Bug Fixes", "Breaking Changes", "Deprecations"
- Empty message: "No recent releases found."

## Fetch Data

Run:
```
bash ${CLAUDE_PLUGIN_ROOT}/scripts/fetch-releases.sh
```

Pass `--force` if the user specified it in `$ARGUMENTS`.

Read the returned cache file (`~/.claude/cache/upgrade-advisor/releases.json`).

## Filter Releases

- If `$ARGUMENTS` contains a plain number N (e.g., `5`), show the N most recent releases. Default: 5.
- If `--since <version>` is specified, show only releases newer than that version.

## Format Output

For each release (newest first), output:

```markdown
### vX.Y.Z — YYYY-MM-DD

**New Features**
- Feature 1
- Feature 2

**Improvements**
- Improvement 1

**Bug Fixes**
- Fix 1

**Breaking Changes**
- Change 1

**Deprecations**
- Deprecated 1
```

Omit empty sections. If a release has no parsed sections but has a body, show a brief summary of the body text instead.

At the end, add:
> Run `/upgrade-advisor` for a full analysis of how these changes apply to your setup.
