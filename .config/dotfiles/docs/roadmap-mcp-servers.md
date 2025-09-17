# MCP Server Configuration Roadmap

## Project: Global MCP Server Setup for Claude Code
**Date Created**: 2025-01-17
**Status**: Planning Complete, Ready for Implementation

---

## Executive Summary

Configure two Model Context Protocol (MCP) servers globally for Claude Code:
1. **Context7** - Documentation lookup service (HTTP-based)
2. **Zen** - Multi-model AI collaboration platform (Python-based, requires OpenRouter API key)

Using official Claude Code CLI commands with bootstrap automation to ensure portability across dotfiles.

---

## Architecture Decision

After analyzing multiple approaches:
- ❌ Direct config file editing (unsupported, may break)
- ❌ Pure CLI wizard (not automatable)
- ✅ **Hybrid approach**: CLI commands + bootstrap automation + dotfiles tracking

This balances official support with automation needs.

---

## Implementation Checklist

### Phase 1: Prerequisites
- [ ] Install `uv` package manager for Python
- [ ] Verify Python 3.10+ is installed
- [ ] Ensure Claude Code is installed and working

### Phase 2: Zen Server Installation
- [ ] Clone Zen MCP server to `~/.local/zen-mcp-server/`
- [ ] Run `./run-server.sh` to set up Python environment
- [ ] Create `.env.example` template file (tracked in dotfiles)
- [ ] Set up secure API key storage (see Security section)

### Phase 3: MCP Server Configuration
- [ ] Configure Context7 with `claude mcp add --scope user`
- [ ] Configure Zen with `claude mcp add --scope user`
- [ ] Verify with `claude mcp list`

### Phase 4: Automation & Documentation
- [ ] Create `~/.local/bin/setup-claude-mcp.sh` bootstrap script
- [ ] Update main `~/.local/bin/bootstrap.sh`
- [ ] Add MCP permissions to `~/.claude/settings.json`
- [ ] Update CLAUDE.md with complete documentation

### Phase 5: Testing & Finalization
- [ ] Test MCP servers with `/mcp` command in Claude Code
- [ ] Track configuration files in dotfiles
- [ ] Commit all changes

---

## Security Architecture

### API Key Storage Options (OpenRouter Required for Zen)

#### Option 1: Fish Universal Variables (Recommended)
```fish
set -Ux OPENROUTER_API_KEY "sk-or-v1-..."
```
- **Pros**: Encrypted, persistent, never in git
- **Cons**: Fish-specific
- **Location**: `~/.config/fish/fish_variables`

#### Option 2: Local .env File
```bash
cd ~/.local/zen-mcp-server
echo "OPENROUTER_API_KEY=sk-or-v1-..." > .env
```
- **Pros**: Standard format, portable
- **Cons**: Must ensure .gitignore
- **Location**: `~/.local/zen-mcp-server/.env`

#### Security Rules
1. **NEVER** commit API keys to git
2. **ALWAYS** use `.env.example` as template (tracked)
3. **ALWAYS** verify `.env` is in `.gitignore`
4. **Bootstrap script** checks for API key presence

---

## File Structure

```
~/.config/dotfiles/
├── docs/
│   └── roadmap-mcp-servers.md          # This file
├── CLAUDE.md                            # Updated with MCP docs
└── bootstrap/
    └── (existing package lists)

~/.local/
├── bin/
│   ├── bootstrap.sh                     # Updated main bootstrap
│   └── setup-claude-mcp.sh             # New MCP setup script
└── zen-mcp-server/                     # Cloned repo
    ├── .env                             # API keys (NOT tracked)
    ├── .env.example                     # Template (tracked)
    └── run-server.sh                    # Zen's setup script

~/.claude/
├── settings.json                        # MCP permissions (tracked)
└── .json                                # MCP configuration (tracked)
```

---

## Commands Reference

### Installation Commands
```bash
# Install uv package manager
curl -LsSf https://astral.sh/uv/install.sh | sh

# Clone Zen MCP server
cd ~/.local
git clone https://github.com/BeehiveInnovations/zen-mcp-server.git

# Install Zen dependencies
cd zen-mcp-server
./run-server.sh
```

### Configuration Commands
```bash
# Add Context7 globally (no API key needed)
claude mcp add context7 https://mcp.context7.com/mcp \
  --scope user \
  --transport http

# Add Zen globally (requires API key in environment)
claude mcp add zen ~/.local/zen-mcp-server/run-server.sh \
  --scope user \
  --transport stdio \
  -e OPENROUTER_API_KEY="${OPENROUTER_API_KEY}"

# Verify configuration
claude mcp list
```

### Dotfiles Commands
```bash
# Track configurations
dots add ~/.claude.json
dots add ~/.claude/settings.json
dots add ~/.local/bin/setup-claude-mcp.sh
dots add ~/.local/zen-mcp-server/.env.example
dots add ~/.config/dotfiles/CLAUDE.md
dots add ~/.config/dotfiles/docs/roadmap-mcp-servers.md

# Commit
dots commit -m "Add global MCP servers with secure API configuration"
```

---

## Bootstrap Script Logic

The `setup-claude-mcp.sh` script will:

1. **Check Prerequisites**
   - Verify `uv` is installed
   - Check Python version

2. **Install Zen if needed**
   - Clone repository
   - Run setup script
   - Create .env from template

3. **Validate API Key**
   - Check Fish universal variables
   - Check .env file
   - Check environment
   - Provide clear guidance if missing

4. **Configure MCP Servers**
   - Skip if already configured
   - Add with proper parameters
   - Verify successful addition

5. **Provide User Feedback**
   - Clear success/failure messages
   - Next steps if manual intervention needed

---

## API Key Acquisition

### Getting an OpenRouter API Key:
1. Visit [https://openrouter.ai](https://openrouter.ai)
2. Create an account
3. Add credits (minimum $5)
4. Generate key at [https://openrouter.ai/keys](https://openrouter.ai/keys)
5. Save key securely (see Security Architecture)

### What OpenRouter Provides:
- Access to 100+ AI models
- Claude (Anthropic)
- GPT-4 (OpenAI)
- Gemini (Google)
- Llama (Meta)
- Many specialized models

---

## MCP Server Capabilities

### Context7 Tools
- `resolve-library-id`: Find library/framework documentation
- `get-library-docs`: Retrieve specific documentation

### Zen Tools
- **Planning**: `planner`, `consensus`
- **Analysis**: `codereview`, `debug`, `thinkdeep`, `challenge`
- **Development**: `testgen`, `refactor`
- **Communication**: `chat`, `listmodels`

---

## Troubleshooting Guide

### Common Issues

#### MCP servers not showing in `/mcp`:
1. Restart Claude Code
2. Check `claude mcp list` output
3. Verify API key is set (for Zen)

#### API key not found:
1. Check Fish: `echo $OPENROUTER_API_KEY`
2. Check .env: `cat ~/.local/zen-mcp-server/.env`
3. Set using preferred method (see Security Architecture)

#### Zen server fails to start:
1. Check Python version: `python3 --version` (needs 3.10+)
2. Check uv installed: `which uv`
3. Re-run setup: `cd ~/.local/zen-mcp-server && ./run-server.sh`

#### Permission denied errors:
1. Check file permissions
2. Ensure scripts are executable: `chmod +x setup-claude-mcp.sh`

---

## Success Criteria

- [ ] Both MCP servers appear in `/mcp` command output
- [ ] Context7 can fetch library documentation
- [ ] Zen can access OpenRouter models
- [ ] Configuration persists after Claude Code restart
- [ ] Bootstrap script runs without errors on fresh system
- [ ] No API keys in git history
- [ ] Documentation is complete and accurate

---

## Future Enhancements

1. **Additional MCP Servers**
   - GitHub MCP server for repository operations
   - Memory server for persistent context
   - Filesystem server for advanced file operations

2. **API Key Management**
   - Consider using system keyring for enhanced security
   - Implement key rotation reminders

3. **Monitoring**
   - Add usage tracking for API costs
   - Create alerts for rate limits

---

## References

- [Claude Code MCP Documentation](https://docs.claude.com/en/docs/claude-code/mcp)
- [Context7 GitHub](https://github.com/upstash/context7)
- [Zen MCP Server GitHub](https://github.com/BeehiveInnovations/zen-mcp-server)
- [OpenRouter](https://openrouter.ai)
- [MCP Server Configuration Article](https://scottspence.com/posts/configuring-mcp-tools-in-claude-code)

---

## Notes

- This roadmap represents the consensus after analyzing official documentation, community practices, and security requirements
- The hybrid approach (CLI + bootstrap) provides the best balance of official support and automation
- API key security is paramount - multiple safeguards are implemented
- All configuration is designed to be portable via dotfiles while keeping secrets local

---

*Last Updated: 2025-01-17*
*Status: Ready for Implementation*