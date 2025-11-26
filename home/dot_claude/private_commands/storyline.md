---
name: storyline
description: Analyze uncommitted changes and execute a Zen commit strategy
model: haiku
---

# Storyline Commit Strategy

Analyze all uncommitted changes, understand the intent behind them, and create atomic, meaningful commits following the Zen principle: *"Each commit should tell a single story, complete and self-contained."*

## Workflow

1. **Discover Changes**: Examine all uncommitted modifications using git status and git diff
2. **Understand Intent**: Analyze the changes to comprehend what was accomplished
3. **Identify Logical Groups**: Find related changes that tell a coherent story together
4. **Plan Commit Strategy**: Design atomic commits that each serve a single purpose
5. **Execute Commits**: Create the commits with clear, intentional messages

## Core Principles

### The "Complete Feature" Rule

**A commit is complete only when it includes ALL of:**
- Implementation (code, configs, scripts)
- Documentation (CLAUDE.md, README.md, inline docs)
- Tests (if applicable)

**NEVER** create separate commits for:
- ❌ "Add feature" → "Document feature"
- ❌ "Implement X" → "Update docs for X"
- ❌ Any code change → standalone `docs:` commit

**Documentation synchronization is not optional** - code and docs are integral parts of the same logical change.

### What is "One Thing"?

An atomic commit represents **one user-facing capability or one conceptual change**:

✅ **Good atomic boundaries:**
- One feature with all its parts (implementation + Fish functions + docs)
- One bug fix (root cause + fix + affected docs)
- One refactoring (code change + updated docs)
- One configuration enhancement (config + docs)

❌ **Bad atomic boundaries:**
- Mixing unrelated features in one commit
- Implementation without documentation
- Multiple unrelated file type changes (except when naturally coupled)

### Commit Philosophy

- **Atomic Commits**: Each commit is complete, self-contained, and leaves system working
- **Semantic Messages**: Use conventional prefixes (feat, fix, refactor, docs, style, test, chore)
- **Intent Over Implementation**: Messages explain *why*, not just *what*
- **Logical Progression**: Commits build upon each other in a sensible order
- **Single Responsibility**: One conceptual change per commit

## Examples

### ✅ **Good: Complete Atomic Commits**

```
feat(zfs): add time machine with automated snapshots

Implement comprehensive ZFS snapshot automation system including:
- Layered retention: 15min → hourly → daily → weekly → monthly
- Fish functions: zsnap, zlist, zclean, zfsstatus
- Monthly integrity scrubs for data protection
- Documentation updates to CLAUDE.md and README.md

Benefits: Year-long retention, automated integrity verification,
selective dataset snapshotting.
```

Notice how this **includes implementation, user interface, AND documentation** as one complete feature.

```
fix(transmission): restore VPN binding after network change

Root cause: Network restart cleared bind-address-ipv4 setting.

Fix: Add vpn-check to transmission-vpn-bind script with automatic
rebind on network events. Update transmission.md with recovery
procedure.
```

Again: **fix + docs together**.

```
refactor(fish): extract VPN status check into reusable function

Extract repeated VPN detection logic from vpc/transmission-vpn-bind
into shared vpn-status function. Update CLAUDE.md to reflect new
reusable component architecture.

No behavior change, improves maintainability.
```

Even pure refactoring **includes doc updates**.

### ❌ **Bad: Incomplete or Mixed Commits**

```
# WRONG: Implementation without docs
feat(zfs): add automated snapshots
(Missing: Fish functions, CLAUDE.md updates, README.md updates)

# WRONG: Docs separated from code
docs: update CLAUDE.md with ZFS commands
(Should be part of feat(zfs) commit above)

# WRONG: Multiple unrelated changes
feat: add ZFS snapshots and improve waybar scroll sensitivity
(Should be two commits: feat(zfs) and refactor(waybar))

# WRONG: Incomplete feature
feat(zfs): add automation scripts
(Missing: Fish management functions that make it usable)
```

## Special Considerations

- **Tightly coupled changes stay together**: If two systems depend on each other, commit them together
- **Unrelated changes separate**: If changes serve different purposes, split them even if touching same files
- **Use `git add -p`**: For splitting changes within a single file
- **Tests pass after each commit**: Each commit should leave the system working
- **Documentation is not optional**: Every code change that affects user behavior needs matching docs

## Decision Framework

When uncertain whether to split or combine commits, ask:

1. **Can each commit stand alone?** If removing one breaks the other, they belong together.
2. **Do they serve the same user-facing purpose?** Same feature = same commit.
3. **Would documentation explain them separately?** If docs treat them as separate topics, split them.
4. **Does the code change affect documented behavior?** Then docs MUST be in the same commit.

## The Anti-Pattern: Standalone `docs:` Commits

**NEVER do this:**
```bash
git commit -m "feat(zfs): add snapshot automation"
git commit -m "docs: update CLAUDE.md with ZFS commands"  # WRONG!
```

**ALWAYS do this:**
```bash
git commit -m "feat(zfs): add snapshot automation

Includes documentation updates to CLAUDE.md and README.md"
```

The `docs:` prefix should **only** be used for:
- Pure documentation improvements (typo fixes, clarity improvements)
- Documentation infrastructure changes (new doc templates, organization)
- Documentation that doesn't relate to a specific code change

---

*Remember: A feature isn't done until it's documented. The git history should tell a complete story, not require reading between commits.*
