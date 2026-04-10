# Claude Code Feature Catalog

This catalog maps Claude Code versions to their key features and changes. It serves as a seed dataset for the upgrade advisor. The advisor also fetches live release notes to augment this catalog.

## How to Use This Catalog

Each entry describes:
- **Version**: The Claude Code version that introduced the feature
- **Feature**: Name of the feature or change
- **Category**: Which part of Claude Code it affects
- **Detection**: How to determine if the user's setup does NOT use this feature
- **Impact**: Why adopting this feature matters
- **Effort**: Estimated migration effort

## Feature Table

| Version | Feature | Category | Detection | Impact | Effort |
|---------|---------|----------|-----------|--------|--------|
| 1.0.33+ | Plugin system with marketplace | plugins | No `.claude-plugin/plugin.json` in shareable tools | Distribute tools via marketplace instead of manual install | Medium |
| 1.0.33+ | Skills directory format (SKILL.md + references/) | skills | Uses `commands/*.md` without `skills/*/SKILL.md` | Better organization, progressive disclosure, reference support | Medium |
| 1.0.30+ | Prompt-based hooks | hooks | `hooks.json` uses only `"type": "command"`, no `"type": "prompt"` | Simpler validation logic using LLM judgment | Low |
| 1.0.30+ | SubagentStop hook event | hooks | No `SubagentStop` handlers in hooks config | Validate subagent outputs before returning | Low |
| 1.0.28+ | `${CLAUDE_PLUGIN_ROOT}` variable | scripts | Hardcoded absolute paths in hook commands or scripts | Portability across installations | Low |
| 1.0.25+ | Agent definitions (agents/*.md) | agents | No `agents/` directory for custom subagent types | Define specialized agents with tools/model constraints | Medium |
| 1.0.25+ | Agent `<example>` blocks in description | agents | Agent `.md` files without `<example>` blocks | Better model-invocation triggering accuracy | Low |
| 1.0.22+ | `allowed-tools` frontmatter in commands | commands | Command `.md` files without `allowed-tools` in frontmatter | Reduce permission prompts, faster execution | Low |
| 1.0.22+ | `model` override in commands/agents | commands | All commands use default model | Use cheaper models (sonnet/haiku) for simple tasks | Low |
| 1.0.20+ | SessionStart / SessionEnd hook events | hooks | No `SessionStart` or `SessionEnd` handlers | Load context on start, cleanup on end | Low |
| 1.0.20+ | PreCompact hook event | hooks | No `PreCompact` handler | Preserve critical info before context compaction | Low |
| 1.0.18+ | `argument-hint` frontmatter | commands | Commands with arguments but no `argument-hint` | Better discoverability in `/help` output | Low |
| 1.0.15+ | Plugin settings via `.claude/plugin-name.local.md` | plugins | Plugin with configurable behavior but no settings support | User-customizable plugin behavior per project | Medium |
| 1.0.12+ | MCP server types: SSE, HTTP, WebSocket | mcp | `.mcp.json` using only stdio servers | Connect to remote/hosted MCP services | Medium |
| 1.0.10+ | `disable-model-invocation` frontmatter | commands | User-only commands without `disable-model-invocation: true` | Prevent unintended auto-triggering of commands | Low |
| 1.0.8+ | `context: fork` in command frontmatter | commands | Long-running commands without `context: fork` | Isolate command execution context | Low |

## Deprecated Patterns

| Deprecated Since | Pattern | Detection | Migration |
|------------------|---------|-----------|-----------|
| 1.0.33 | Standalone command files for distribution | `commands/*.md` distributed via git clone + install.sh | Convert to plugin format with `.claude-plugin/plugin.json` |
| 1.0.30 | Command-only hooks for validation | All hooks use `"type": "command"` for input validation | Use `"type": "prompt"` for context-dependent validation |
| 1.0.25 | Inline agent instructions in CLAUDE.md | CLAUDE.md contains agent behavior descriptions | Extract to `agents/*.md` with proper frontmatter |
| 1.0.22 | Unrestricted tool access in commands | Commands without `allowed-tools` frontmatter | Add `allowed-tools` to limit scope |
| 1.0.15 | Flat commands directory (no skills) | `commands/*.md` with inline reference content | Migrate to `skills/*/SKILL.md` + `references/` |

## Best Practices (Version-Independent)

| Practice | Detection | Recommendation |
|----------|-----------|----------------|
| Progressive disclosure | SKILL.md > 3000 words without references/ | Move detailed content to references/ subdirectory |
| Lean command definitions | Command files > 100 lines | Compress or extract to skill format |
| Tool scoping | Commands using broad tool permissions | Restrict to minimum required tools via allowed-tools |
| Model selection | All commands default to opus | Use sonnet for simple tasks, haiku for trivial |
| Hook timeout | Hooks without explicit timeout | Add timeout to prevent session blocking |
| Cache awareness | Scripts making repeated API calls | Implement caching for external data |
