# Analysis Patterns — Detection Heuristics

This document defines the heuristics used by the upgrade advisor to detect improvement opportunities in a user's Claude Code setup. Each pattern specifies what to look for, where to look, and what to recommend.

## Pattern Categories

- **P-HOOK**: Hook configuration improvements
- **P-SKILL**: Skill/command modernization
- **P-AGENT**: Agent definition improvements
- **P-CONFIG**: Settings and configuration optimization
- **P-MCP**: MCP server configuration
- **P-STRUCT**: Project structure improvements

---

## P-HOOK-01: Command-Only Hooks

**Detect**: All hook entries in `hooks.json` or `settings.json` hooks section use `"type": "command"` with none using `"type": "prompt"`
**Where**: `.claude/settings.json` (hooks section), `hooks/hooks.json`
**Recommend**: Convert simple validation hooks (input checking, style enforcement) to prompt-based hooks for more nuanced, context-aware decisions
**Impact**: Medium — reduces script maintenance, better handling of edge cases
**Effort**: Low — change type and replace command with prompt string

## P-HOOK-02: Missing Hook Events

**Detect**: Hooks config exists but does not use these high-value events: `SessionStart`, `SessionEnd`, `PreCompact`
**Where**: Hook configuration files
**Recommend**: 
- `SessionStart`: Load project context, check environment
- `SessionEnd`: Cleanup, generate reports
- `PreCompact`: Preserve critical information before context compaction
**Impact**: Medium
**Effort**: Low

## P-HOOK-03: No Hook Timeout

**Detect**: Hook entries without explicit `"timeout"` field
**Where**: Hook configuration files
**Recommend**: Add timeout to prevent hanging hooks from blocking the session (5-30s for commands, 10-60s for prompts)
**Impact**: Low — prevents rare but disruptive hangs
**Effort**: Low

---

## P-SKILL-01: Legacy Command Layout

**Detect**: Project has `commands/*.md` but no `skills/*/SKILL.md` directory structure
**Where**: Plugin root or `.claude/` directory
**Recommend**: Migrate complex commands (>50 lines or needing reference data) to skills format:
```
commands/my-cmd.md → skills/my-cmd/SKILL.md + skills/my-cmd/references/
```
**Impact**: Medium — enables reference file support, progressive disclosure
**Effort**: Medium

## P-SKILL-02: Oversized SKILL.md

**Detect**: `SKILL.md` files exceeding 3000 words without a `references/` subdirectory
**Where**: `skills/*/SKILL.md`
**Recommend**: Extract detailed content into `references/` files, keep SKILL.md as the overview + workflow
**Impact**: Medium — reduces initial context load, follows progressive disclosure
**Effort**: Medium

## P-SKILL-03: Missing Allowed-Tools

**Detect**: Command or skill `.md` files without `allowed-tools` in YAML frontmatter
**Where**: `commands/*.md`, `skills/*/SKILL.md`
**Recommend**: Add `allowed-tools` listing only the tools the command actually needs
**Impact**: High — reduces permission prompts, limits blast radius, faster execution
**Effort**: Low

## P-SKILL-04: Missing Description

**Detect**: Command or skill `.md` files without `description` in frontmatter
**Where**: `commands/*.md`, `skills/*/SKILL.md`
**Recommend**: Add concise description for `/help` output discoverability
**Impact**: Low
**Effort**: Low

## P-SKILL-05: Missing Argument Hint

**Detect**: Commands that reference `$ARGUMENTS` or `$1` in body but lack `argument-hint` in frontmatter
**Where**: `commands/*.md`, `skills/*/SKILL.md`
**Recommend**: Add `argument-hint` to show expected arguments in help
**Impact**: Low
**Effort**: Low

---

## P-AGENT-01: No Example Blocks

**Detect**: Agent definition files (`agents/*.md`) without `<example>` blocks in the description frontmatter
**Where**: `agents/*.md`
**Recommend**: Add 2-3 `<example>` blocks with `user:`, `assistant:`, and `<commentary>` to improve model-invocation accuracy
**Impact**: High — dramatically improves when the agent triggers automatically
**Effort**: Medium

## P-AGENT-02: No Model Override

**Detect**: Agent files without `model:` in frontmatter, defaulting to the most expensive model
**Where**: `agents/*.md`
**Recommend**: Set `model: sonnet` or `model: haiku` for agents doing simple/routine tasks
**Impact**: Medium — cost reduction
**Effort**: Low

## P-AGENT-03: Unrestricted Tools

**Detect**: Agent files without `tools:` array in frontmatter (gets all tools by default)
**Where**: `agents/*.md`
**Recommend**: Restrict to only needed tools for safety and clarity
**Impact**: Medium
**Effort**: Low

---

## P-CONFIG-01: No Plugin Format

**Detect**: Project distributes Claude Code tools via `install.sh` or manual file copy, without `.claude-plugin/plugin.json`
**Where**: Project root
**Recommend**: Add plugin manifest for marketplace compatibility and standardized installation
**Impact**: High — enables marketplace distribution, standard lifecycle
**Effort**: Medium

## P-CONFIG-02: Hardcoded Paths in Hooks

**Detect**: Hook commands containing hardcoded absolute paths (e.g., `/Users/...`, `/home/...`) instead of `${CLAUDE_PLUGIN_ROOT}`
**Where**: Hook configuration files, scripts referenced by hooks
**Recommend**: Replace with `${CLAUDE_PLUGIN_ROOT}` for portability
**Impact**: Medium — breaks on other machines
**Effort**: Low

## P-CONFIG-03: Missing Plugin Settings Support

**Detect**: Plugin with configurable behavior (checking env vars, reading config files) but no `.claude/plugin-name.local.md` settings support
**Where**: Plugin root
**Recommend**: Add settings support via `.claude/plugin-name.local.md` with YAML frontmatter
**Impact**: Low — enables per-project customization
**Effort**: Medium

---

## P-MCP-01: Stdio-Only MCP

**Detect**: `.mcp.json` contains only `"command"` type servers, no `"type": "sse"`, `"http"`, or `"ws"` entries
**Where**: `.mcp.json`
**Recommend**: Consider remote MCP servers for hosted services (reduces local process overhead)
**Impact**: Low — informational
**Effort**: Varies

## P-MCP-02: No Environment Variables in MCP

**Detect**: `.mcp.json` contains hardcoded tokens or API keys instead of `${ENV_VAR}` references
**Where**: `.mcp.json`
**Recommend**: Use environment variable references for secrets
**Impact**: High — security risk
**Effort**: Low

---

## P-STRUCT-01: Large CLAUDE.md

**Detect**: Root `CLAUDE.md` exceeding 200 lines
**Where**: `CLAUDE.md`
**Recommend**: Extract sections to child CLAUDE.md files or knowledge references. Use `/optimize-context` from claude-token-optimizer.
**Impact**: Medium — reduces base context load
**Effort**: Medium (complementary tool available)

## P-STRUCT-02: Inline Agent Definitions in CLAUDE.md

**Detect**: CLAUDE.md contains sections describing agent-like behavior ("When doing X, you should Y") that could be agent files
**Where**: `CLAUDE.md`
**Recommend**: Extract to `agents/*.md` with proper frontmatter
**Impact**: Medium — better separation of concerns, model-invocable
**Effort**: Medium
