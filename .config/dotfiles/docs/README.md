# Dotfiles Documentation

## Navigation

- **[System Context & Guide](../CLAUDE.md)** - Complete system documentation
- **[Architecture Decisions](adr/)** - Why things are the way they are
- **[Change History](CHANGELOG.md)** - What's changed recently
- **[Issue Investigations](issues/)** - Deep-dives into solved problems
- **[Future Plans](roadmap/)** - Features being planned
- **[Bootstrap Details](../bootstrap/README.md)** - Setup system architecture

## When to Document

**Create an ADR when:**
- Choosing between multiple valid technical approaches
- Making a decision you might question or revisit later
- Changing something fundamental to the system

**Create an issue doc when:**
- A problem takes >1 hour to solve
- The solution is non-obvious
- You might encounter it again

**Update CLAUDE.md when:**
- Adding new tools or workflows
- Discovering important gotchas
- Learning something future-you needs

**For everything else:** Clear commit messages are sufficient

## Finding Documentation

```bash
# Search all documentation
grep -r "search term" ~/.config/dotfiles/docs/

# Find ADRs about specific topics
grep -l "tmux" ~/.config/dotfiles/docs/adr/*.md

# View recent changes
head -50 ~/.config/dotfiles/docs/CHANGELOG.md
```

## Documentation Philosophy

This is personal dotfiles, not enterprise software. We document:
- **The "why"** - So we remember our reasoning
- **The non-obvious** - So we don't rediscover solutions
- **The important** - So we don't break things

We don't document:
- **The obvious** - Standard configurations
- **The temporary** - Experiments and trials
- **The trivial** - Minor tweaks and formatting

Keep it simple. Keep it valuable. Keep it maintainable.