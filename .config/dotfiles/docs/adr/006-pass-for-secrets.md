# ADR-006: Pass for API Keys, Bitwarden for Web Passwords

Date: 2025-09-19

## Context
MCP servers need API keys with long-lived sessions. Bitwarden CLI's 30-minute timeout caused frequent re-authentication, breaking automation flows.

## Decision
Use pass (Unix password store) for all API keys and automation secrets. Keep Bitwarden CLI only for web passwords.

## Why
- GPG agent caches for 8-24 hours vs Bitwarden's 30 minutes
- API keys never visible to Claude Code (security boundary)
- No session management complexity in scripts
- Clean separation of concerns: automation vs web passwords
- Minimal dependencies (no Electron, no GNOME libraries)

## Consequences
- Must maintain two password managers with clear boundaries
- Users need GPG key for pass initialization
- API keys migrate from Bitwarden to pass
- Simpler MCP wrapper scripts without session handling
- Better developer experience with "unlock once per day" workflow