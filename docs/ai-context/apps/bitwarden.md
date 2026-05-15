# Secrets Management with Bitwarden

## Ultra-Zen Philosophy
**"Secrets flow from vault to configuration through semantic templates"**

## Architecture
- **Bitwarden CLI** (`bw`) - Password manager for secure secret storage
- **Chezmoi Templates** - Reference secrets without storing plaintext
- **Zsh Functions** - Semantic wrapper functions for vault operations
- **Auto-lock Security** - Vault locks automatically on terminal exit

## Configuration
- **Vault Config**: `home/dot_config/chezmoi/chezmoi.toml.tmpl` - Enables auto-unlock
- **Template Helpers**: `home/.chezmoitemplates/bitwarden-*.tmpl` - Reusable secret retrieval
- **Zsh Integration**: Custom autoload functions with semantic aliases (`bwu`, `bwc`, `bwg`)

## Usage Patterns
```go-template
# SSH Private Key
{{ template "bitwarden-note.tmpl" "ssh-private-key" }}

# Password Field
{{ template "bitwarden-password.tmpl" "github-pat" }}

# Custom Fields
{{ (bitwardenFields "item" "api-keys").api_key.value }}
```

## Security Guarantees
- Vault remains encrypted at rest (`~/.config/Bitwarden CLI/data.json`)
- Session keys are ephemeral (environment variable only)
- No secrets in git repository (only template references)
- Auto-lock on terminal exit prevents session persistence

## Example Files
- `home/private_dot_ssh/private_id_rsa.tmpl.example` - SSH key management
- `home/private_dot_aws/credentials.tmpl.example` - AWS credentials
- `home/dot_config/env.tmpl.example` - Environment variables with secrets

## Secure Secrets Architecture

### Isolated Secrets Directory
**"Secrets dwell in their own realm, beyond the reach of wandering eyes"**

- **Secrets Directory**: `~/.local/state/secrets/` - All secrets outside project paths
- **Auto-loading**: Zsh conf.d loads secrets into environment on shell startup
- **Environment Variables**: Secrets available as `GOOSE_VPN_USER`, `GOOSE_VPN_PASS`, etc.

### Directory Structure
```
~/.local/state/secrets/
├── openvpn/          # VPN credentials
│   └── goosevpn-auth
├── env/              # Environment variable files
│   └── vpn-config    # VPN configuration vars
└── ssh/              # Future: SSH keys
```

### Security Benefits
- Secrets isolated from project directories and Git repositories
- Single location for all sensitive data
- Foundation for future enhancements (encryption, systemd-creds)
- Works around Claude Code's broken deny permissions