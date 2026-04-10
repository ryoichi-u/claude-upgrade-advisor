# Analysis Rules — Cross-Reference Logic

This document defines how to cross-reference release note entries with the user's Claude Code setup to generate recommendations.

## Cross-Reference Process

For each release note entry (from cached `releases.json`), perform the following:

### 1. Feature Entries (from `features[]`)

For each feature mentioned in a release:
1. Check `feature-catalog.md` for a matching entry
2. If found, apply the **Detection** logic against the user's files
3. If the detection matches (user is NOT using the feature), add to **Adopt** recommendations
4. If no detection match (user already uses it), skip

### 2. Deprecation Entries (from `deprecations[]`)

For each deprecation:
1. Check `feature-catalog.md` Deprecated Patterns table
2. Apply detection logic against user's files
3. If found, add to **Migrate** recommendations with the specified migration path

### 3. Breaking Changes (from `breaking[]`)

For each breaking change:
1. Parse the description for affected components (hooks, commands, settings, etc.)
2. Check if user's setup uses the affected component
3. If yes, add to **Alert** recommendations

### 4. Improvement Entries (from `improvements[]`)

For improvements, check if any existing pattern in `analysis-patterns.md` is relevant. If the improvement suggests a new best practice, scan for violations.

## Recommendation Format

Each recommendation should include:

```
{
  "category": "adopt|migrate|optimize|alert",
  "feature": "Feature name",
  "since": "vX.Y.Z",
  "impact": "high|medium|low",
  "effort": "low|medium|high",
  "files_affected": ["path/to/file1", "path/to/file2"],
  "current_state": "Description of what the user currently has",
  "recommended_state": "Description of what they should change to",
  "action_steps": ["Step 1", "Step 2"],
  "before_after": {
    "before": "code snippet showing current state",
    "after": "code snippet showing recommended state"
  }
}
```

## Priority Scoring

Rank recommendations by priority score:

| Factor | Weight |
|--------|--------|
| Impact: High | +3 |
| Impact: Medium | +2 |
| Impact: Low | +1 |
| Effort: Low | +3 |
| Effort: Medium | +2 |
| Effort: High | +1 |
| Category: Alert | +4 (always first) |
| Category: Migrate | +3 |
| Category: Adopt | +2 |
| Category: Optimize | +1 |

**Quick Wins** = Impact >= Medium AND Effort == Low (priority score >= 5)

## Grouping Rules

1. Group by category (Alert > Migrate > Adopt > Optimize)
2. Within each category, sort by priority score descending
3. Quick Wins section pulls the top items with Effort=Low from all categories
4. Limit to top 15 recommendations unless `--scope full` is specified

## Complementary Tool References

When specific recommendations overlap with capabilities of other tools, reference them:

| Pattern | Complementary Tool |
|---------|--------------------|
| P-STRUCT-01 (Large CLAUDE.md) | `/optimize-context` from claude-token-optimizer |
| Token consumption concerns | `/token-audit` from claude-token-optimizer |
| Unused tool registrations | `/tool-diet` from claude-token-optimizer |
| Oversized command files | `/prompt-slim` from claude-token-optimizer |
| Runtime data injection | `/context-guard` from claude-token-optimizer |
