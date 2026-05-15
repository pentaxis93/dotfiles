# Zsh - Login Shell (oreb only)

## Scope

Login shell on **oreb** only. Mani and babbie continue with their existing
shells; the zsh config files are excluded on those hosts via
`.chezmoiignore`.

Fish remains installed everywhere and its configs remain deployed —
inert when not invoked from a fish session. This preserves:

- 7 `home/dot_local/bin/executable_*.tmpl` scripts with
  `#!/usr/bin/env fish` shebangs (waybar widgets, magnet handler, etc.)
- Helix's `shell = ["fish", "-c"]` (`home/dot_config/helix/config.toml.tmpl`)
- Rollback to fish-as-login-shell with a single `chsh -s /usr/bin/fish`

## Architecture

- **Bare zsh** — no framework (oh-my-zsh, prezto, powerlevel10k all rejected
  on YAGNI grounds).
- **`zsh-autosuggestions` + `zsh-syntax-highlighting`** — the two fish
  ergonomics worth keeping, as small standalone Arch packages that source
  in two lines.
- **`vcs_info`** — built into zsh; provides git branch in prompt without
  external dependencies.
- **`bindkey -v`** — built-in vi mode. Helix-native overrides (`ge`/`gh`/`gl`)
  not yet ported — can be added later if they earn their place.
- **`AddKeysToAgent yes`** in `~/.ssh/config` — lazy-loads the ssh key on
  first auth, into a systemd-socket-activated `ssh-agent`. No
  shell-startup spawn loop, no eager-load cost.

## Files

| File | Target | Purpose |
|---|---|---|
| `home/dot_zshenv.tmpl` | `~/.zshenv` | Sets `ZDOTDIR` and `SSH_AUTH_SOCK` |
| `home/dot_config/zsh/dot_zshrc.tmpl` | `~/.config/zsh/.zshrc` | Interactive shell config |
| `home/run_once_set-zsh-as-login-shell.sh.tmpl` | (script) | `chsh -s /usr/bin/zsh` once |
| `home/run_once_enable-ssh-agent-socket.sh.tmpl` | (script) | `systemctl --user enable ssh-agent.socket` |
| `home/private_dot_ssh/private_config` | `~/.ssh/config` | `ForwardAgent`/`AddKeysToAgent` for agent flow |
| `home/.chezmoidata/packages.yaml` | — | Declares `zsh`/`zsh-autosuggestions`/`zsh-syntax-highlighting` |
| `home/.chezmoiignore` | — | Excludes zsh files from non-oreb hosts |

## ssh-agent topology

```
zsh starts → ~/.zshenv → SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-agent.socket
                                        │
user runs `ssh babbie`                  ▼
            ┌──────────────────────────────────────────────────┐
            │ ssh reads ~/.ssh/config:                         │
            │   Host *        AddKeysToAgent yes               │
            │   Host babbie   ForwardAgent yes                 │
            │ ↓                                                │
            │ first connect → systemd socket-activates         │
            │   ssh-agent.service → key added to agent         │
            │ ↓                                                │
            │ agent forwarded over SSH to babbie               │
            │ ↓                                                │
            │ babbie:`ssh -T git@github.com` uses oreb's key   │
            └──────────────────────────────────────────────────┘
```

The systemd units `ssh-agent.socket` and `ssh-agent.service` ship with the
`openssh` package — no separate install.

## Verification

Open a fresh Alacritty on oreb after `chezmoi apply`:

```sh
getent passwd "$USER" | cut -d: -f7   # /usr/bin/zsh
echo "$SSH_AUTH_SOCK"                  # /run/user/1000/ssh-agent.socket
test -S "$SSH_AUTH_SOCK"               # exit 0
ssh -T git@github.com                  # Hi pentaxis93!
ssh-add -l                             # 256 SHA256:... (ED25519)
ssh babbie -- ssh-add -l               # same fingerprint
```
