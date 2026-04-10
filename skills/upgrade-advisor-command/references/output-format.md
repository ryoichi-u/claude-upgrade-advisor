# Output Format Specification

This document specifies the structure and formatting of the upgrade advisor report output.

## Report Structure

```markdown
# {report_title}

## {env_section}

| | |
|---|---|
| Claude Code | {version} |
| {releases_analyzed} | {from} — {to} ({count}) |
| {files_scanned} | {file_count} |
| Language | {language} |
| Cache | {cache_status} |

---

## {quick_wins_section}

> {quick_wins_description}

| # | {col_feature} | {col_impact} | {col_action} |
|---|---|---|---|
| 1 | Feature name | High | One-line action description |
| 2 | Feature name | Medium | One-line action description |

---

## {new_features_section}

| # | {col_feature} | {col_since} | {col_impact} | {col_effort} | {col_action} |
|---|---|---|---|---|---|
| 1 | Feature | vX.Y.Z | High | Low | Brief action |

### Detail: {feature_name}

**Current**: Description of current state
**Recommended**: Description of target state
**Files**: `path/to/file`

<details>
<summary>Before / After</summary>

**Before:**
```yaml
old configuration
```

**After:**
```yaml
new configuration
```

</details>

---

## {deprecations_section}

| # | {col_pattern} | {col_file} | {col_deprecated_since} | {col_migration} |
|---|---|---|---|---|
| 1 | Pattern name | `file/path` | vX.Y.Z | Migration action |

---

## {config_section}

| # | {col_area} | {col_current} | {col_recommended} | {col_rationale} |
|---|---|---|---|---|
| 1 | Area | Current state | Recommended | Why |

---

## {summary_section}

- {adopt_count} new features to adopt
- {migrate_count} deprecated patterns to migrate
- {optimize_count} configuration improvements
- {alert_count} breaking change alerts

{msg_offer_apply}

---

{msg_complement}
```

## Formatting Rules

1. Use the i18n template labels for all headers and messages
2. Technical terms (CLAUDE.md, hooks, settings.json, allowed-tools, etc.) remain in English regardless of output language
3. File paths are always shown as-is with backtick formatting
4. Before/After examples use fenced code blocks with appropriate language tags
5. Keep table cells concise (< 50 chars); use detail sections for longer explanations
6. Quick Wins section appears first for immediate actionability
7. Use `<details>` blocks for verbose before/after examples to keep the report scannable
8. Number all recommendations for easy reference when the user says "apply #3"
