# Claude Upgrade Advisor

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin that analyzes release notes against your setup and recommends feature adoption, deprecation fixes, and configuration improvements.

**[日本語版 README](README.ja.md)**

## The Problem

Claude Code ships frequent updates with new features, deprecations, and best practice changes. Without tracking release notes, you:

- Miss powerful new features (skills format, prompt-based hooks, agent definitions)
- Continue using deprecated patterns that may break in future versions
- Operate with suboptimal configurations that waste tokens or cause unnecessary permission prompts

## What It Does

- **Fetches & parses** Claude Code release notes from GitHub (cached, respects rate limits)
- **Scans your setup** — CLAUDE.md, commands, agents, skills, hooks, settings, MCP config
- **Cross-references** release notes with your configuration to find gaps
- **Generates a prioritized report** with Quick Wins, feature adoption, deprecation warnings, and configuration improvements
- **Offers to apply fixes** with before/after previews and user confirmation
- **Supports English & Japanese** with extensible i18n (add a language by adding one file)

## Relationship to claude-token-optimizer

This plugin **complements** [claude-token-optimizer](https://github.com/ryoichi-u/claude-token-optimizer):

| Tool | Focus |
|------|-------|
| **claude-token-optimizer** | Token consumption analysis and reduction (static context, runtime injection) |
| **claude-upgrade-advisor** | Release-note-driven improvement proposals (feature adoption, deprecation, modernization) |

They work together — the advisor may reference optimizer commands when relevant.

## Quick Start

### Plugin Installation (Recommended)

```bash
# From the Claude Code marketplace
/plugin install claude-upgrade-advisor
```

### Manual Installation

```bash
git clone https://github.com/ryoichi-u/claude-upgrade-advisor.git
cd claude-upgrade-advisor
```

Then in Claude Code, open a project where the plugin is located or add it to your plugin path.

## Commands

### `/upgrade-advisor` — Full Analysis

The primary command. Fetches release notes, scans your setup, and generates a comprehensive improvement report.

```
/upgrade-advisor                        # Full analysis (default top 15)
/upgrade-advisor --scope quick          # Top 5 recommendations only
/upgrade-advisor --scope full           # All recommendations
/upgrade-advisor --since 1.0.20         # Only releases after v1.0.20
/upgrade-advisor --lang ja              # Force Japanese output
/upgrade-advisor --force                # Force cache refresh
```

**Output includes:**
- Quick Wins (low effort, high impact)
- New features you could adopt
- Deprecated patterns with migration paths
- Configuration improvements
- Before/after code examples

### `/cc-whatsnew` — Release Notes Summary

Lightweight view of recent Claude Code releases. No setup analysis.

```
/cc-whatsnew                    # Last 5 releases
/cc-whatsnew 10                 # Last 10 releases
/cc-whatsnew --since 1.0.25     # Releases after v1.0.25
```

### `/cc-check-deprecations` — Deprecation Scanner

Focused scan for deprecated patterns only. Faster than full analysis.

```
/cc-check-deprecations          # Scan and report
/cc-check-deprecations --fix    # Scan and offer to fix
```

## Proactive Skill

The plugin includes a **model-invoked skill** that activates automatically when:
- You ask about Claude Code updates or new features
- You ask "is there a better way to configure this?"
- Your setup uses outdated patterns during normal work

The proactive skill provides brief, contextual suggestions without running the full analysis.

## Configuration

### Cache

Release notes are cached at `~/.claude/cache/upgrade-advisor/` with 24-hour validity. The SessionStart hook checks cache freshness (no network call) and notifies if data is older than 7 days.

Manage cache manually:
```bash
bash scripts/cache-manager.sh status       # Show cache status
bash scripts/cache-manager.sh invalidate   # Clear cache
bash scripts/cache-manager.sh age          # Show cache age
```

### Language

Language is auto-detected from your CLAUDE.md content or system locale. Override with `--lang`:
- `--lang en` — English
- `--lang ja` — Japanese
- `--lang auto` — Auto-detect (default)

### Adding a Language

Create a new file at `skills/upgrade-advisor-command/references/i18n/<code>.md` following the format of `en.md` or `ja.md`. The plugin will automatically pick it up when `--lang <code>` is specified.

## How It Works

```
User runs /upgrade-advisor
         │
         ▼
[Language Detection] ──→ Load i18n template
         │
         ▼
[Fetch Release Notes] ──→ gh API → cache (24h)
         │
         ▼
[Detect Version] ──→ claude --version
         │
         ▼
[Scan Setup] ──→ CLAUDE.md, commands, agents, skills, hooks, settings, .mcp.json
         │
         ▼
[Cross-Reference] ──→ releases × feature catalog × analysis patterns × user files
         │
         ▼
[Generate Report] ──→ Prioritized recommendations with before/after
         │
         ▼
[Offer Actions] ──→ Apply selected fixes with confirmation
```

## Requirements

- **Claude Code** — Any recent version
- **gh** CLI (recommended) — For GitHub API access. Falls back to `curl` + `GITHUB_TOKEN` env var
- **python3** — For JSON parsing in scripts

## Plugin Structure

```
claude-upgrade-advisor/
├── .claude-plugin/plugin.json       # Plugin manifest
├── skills/
│   ├── upgrade-advisor/             # Model-invoked proactive skill
│   │   ├── SKILL.md
│   │   └── references/
│   │       ├── feature-catalog.md   # Version-feature mapping
│   │       └── analysis-patterns.md # Detection heuristics
│   └── upgrade-advisor-command/     # /upgrade-advisor command
│       ├── SKILL.md
│       └── references/
│           ├── i18n/en.md           # English labels
│           ├── i18n/ja.md           # Japanese labels
│           ├── analysis-rules.md    # Cross-reference rules
│           └── output-format.md     # Report structure spec
├── commands/
│   ├── cc-whatsnew.md               # /cc-whatsnew
│   └── cc-check-deprecations.md    # /cc-check-deprecations
├── hooks/hooks.json                 # SessionStart cache check
└── scripts/
    ├── fetch-releases.sh            # GitHub release fetcher
    ├── cache-manager.sh             # Cache management
    └── parse-changelog.sh           # CHANGELOG.md parser (fallback)
```

## Contributing

Contributions are welcome! Key areas:

- **Feature catalog updates** — Add new Claude Code features to `feature-catalog.md`
- **Analysis patterns** — Add detection heuristics to `analysis-patterns.md`
- **New languages** — Add i18n templates in `references/i18n/`
- **Bug fixes** — Report issues or submit PRs

## License

MIT
