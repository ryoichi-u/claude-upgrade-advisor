---
name: upgrade-advisor
description: This skill activates when the user asks about "Claude Code updates", "new features in Claude Code", "what changed in Claude Code", "is there a better way to configure this", "upgrade my Claude Code setup", "deprecation warning", or when the user's CLAUDE.md, commands, hooks, agents, or settings appear to use outdated patterns. Provides release-note-aware recommendations for Claude Code setup improvements.
version: 0.1.0
---

# Upgrade Advisor — Proactive Skill

Provide contextual, release-note-aware guidance when the user discusses Claude Code configuration or when outdated patterns are detected during normal work.

## When This Skill Activates

This skill should trigger when:
- The user explicitly asks about Claude Code updates, new features, or changes
- The user asks "is there a better way to do X" regarding Claude Code configuration
- The user mentions wanting to upgrade or modernize their setup
- During normal work, you notice the user's setup uses patterns that have been superseded by newer features (e.g., commands without `allowed-tools`, hooks without prompt type, no plugin manifest)

## Lightweight Analysis Flow

Unlike the full `/upgrade-advisor` command, this proactive skill performs a **lightweight, contextual** analysis:

### 1. Check Cached Data

Read `~/.claude/cache/upgrade-advisor/releases.json` if it exists. If the cache does not exist or is unreadable, mention that the user can run `/upgrade-advisor` for a full analysis with fresh data, and proceed with knowledge from `references/feature-catalog.md` only.

Do NOT run the fetch script proactively — it requires network access and adds latency.

### 2. Context-Filtered Recommendations

Based on the user's current question or the files being worked on:
- Filter the feature catalog to entries relevant to the current context
- For example, if the user is editing a hook configuration, surface only hook-related improvements
- If the user is creating a new command, check if they should use the skills format instead

### 3. Concise Output

Keep proactive suggestions brief — 2-5 sentences maximum:
- State what you noticed
- Explain the improvement opportunity  
- Reference the specific feature or version
- Suggest the concrete change

Example:
> I notice this command doesn't have `allowed-tools` in its frontmatter. Since Claude Code 1.0.22+, adding `allowed-tools` reduces permission prompts and speeds up execution. For this command, you'd want: `allowed-tools: [Read, Glob, Grep]`

### 4. Escalation

For complex improvements or when multiple issues are detected, suggest running the full analysis:
> For a comprehensive review of your setup against the latest releases, run `/upgrade-advisor`.

## Reference Data

- **`references/feature-catalog.md`** — Version-to-feature mapping with detection heuristics
- **`references/analysis-patterns.md`** — Full pattern definitions for detecting improvement opportunities

Use these references to inform your suggestions. Always cite the version that introduced a feature when making recommendations.

## Language

Match the language of the current conversation. If the conversation is in Japanese, provide suggestions in Japanese (keeping technical terms in English). If in English, respond in English.

## Boundaries

- Do NOT run scripts or make network requests proactively
- Do NOT modify files without explicit user request
- Do NOT interrupt the user's workflow — weave suggestions naturally into responses
- Limit to 1-2 suggestions per interaction to avoid overwhelming
- If the user dismisses a suggestion, do not repeat it in the same session
