# Zsh — Interactive Shell

## Ultra-Zen Philosophy
**"The shell becomes a sanctuary; commands flow with intention, prompts speak with restraint."**

## Architecture
- **Zsh** — Interactive shell installed via OS package manager
- **Oh-My-Zsh** — Plugin framework, git-cloned to `~/.oh-my-zsh` by run_once
- **robbyrussell theme** — The default oh-my-zsh prompt: `➜ dir git:(branch) ✗`
- **Universal trio of extensions** — git-cloned alongside oh-my-zsh:
  - `zsh-autosuggestions` — fish-style suggestions from history
  - `zsh-syntax-highlighting` — valid/invalid command coloring
  - `zsh-completions` — additional completion definitions
- **systemd-managed ssh-agent** — uniform across CachyOS and Debian
- **Kitty-aware SSH on oreb** — interactive `ssh` from plain Kitty routes
  through `kitten ssh`; local Zellij panes and non-Kitty shells keep OpenSSH
- **No vi-mode mode indicators** — by design; pure robbyrussell prompt

## Configuration files
- **Main config**: `home/dot_zshrc.tmpl` → `~/.zshrc` (templated for machine-type, semantic colors, PATH)
- **Aliases**: `home/dot_config/zsh/aliases.zsh.tmpl` → `~/.config/zsh/aliases.zsh`
- **Autoload functions**: `home/dot_config/zsh/functions/*` → `~/.config/zsh/functions/*` (`ssh` is host-gated to oreb)
- **conf.d hooks**: `home/dot_config/zsh/conf.d/*.zsh.tmpl`
  - `00-secrets.zsh.tmpl` — loads env files from `~/.local/state/secrets/env/`
  - `10-transmission-vpn.zsh.tmpl` — VPN killswitch for transmission
  - `20-transmission-abbreviations.zsh.tmpl` — t* aliases
- **ssh-agent service**: `home/dot_config/systemd/user/ssh-agent.service.tmpl`
- **Installation**: `home/run_once_install-oh-my-zsh.sh.tmpl` (git-clones OMZ + plugins)
- **ssh-agent setup**: `home/run_once_setup-ssh-agent.sh.tmpl`
- **Package**: `zsh` declared in `home/.chezmoidata/packages.yaml` for both `cachyos.pacman` and `debian.apt`

## Function set
Ported one-to-one from fish. Each lives in `~/.config/zsh/functions/<name>` and is loaded via `autoload -Uz` from the zshrc. The semantic naming convention is preserved:

| Domain | Functions |
|---|---|
| VPN | `vpc`, `vpd`, `vps`, `vpn-connect`, `vpn-disconnect`, `vpn-status` |
| Tor | `torc`, `tord`, `tors`, `tor-connect`, `tor-disconnect`, `tor-status` |
| Transmission | `tstart`, `tstop`, `tpause`, `tresume`, `tadd`, `tclean`, `tlist`, `tstatus`, `tpurge`, `tremove`, `tui`, `transmission-auth` |
| Media | `mp`, `mpb`, `mpc`, `mps`, `mpsub` |
| Volume | `vol`, `volu`, `vold`, `volm`, `vols` |
| Bitwarden | `bw-copy`, `bw-generate`, `bw-help`, `bw-lock`, `bw-unlock` |
| WeeChat | `wcc`, `wcd`, `wcs` |
| ZFS | `zsnap`, `zlist`, `zclean`, `zfsstatus` |
| Vault | `vault-unlock`, `vault-lock`, `vault-eject`, `vault-status` (no short forms — `vlock` collides with `/usr/bin/vlock` from the kbd package). `vault-eject` adds power-off to `vault-lock`: unmount → lock → spin down the physical disk for safe unplugging |
| Browser | `qb`, `qbp`, `qbs` |
| OpenCode | `oca`, `occ`, `ocr` |
| File manager | `lf`, `lfcd` |
| Phone | `phone-mv` (adb pull-then-delete; single files move atomically, directories move file-by-file and resume seamlessly if interrupted — the phone's remaining contents are the to-do list) |
| Other | `ls` (lsd wrapper), `ssh` (oreb Kitty wrapper), `bt` (bluetui), `nmtui` (banner wrapper) |

## Aliases
Silent aliases (no inline expansion) port the 22 fish abbreviations. Defined in `~/.config/zsh/aliases.zsh`:

- Universal: `h='helix'`, `hx='helix'`, `lg='lazygit'`, `lc='lfcd'`
- GUI: `bwu`, `bwl`, `bwc`, `bwg`, `bws`, `bwlist`, `bwh`, `babbie`, `i`, `is`, `id`, `idl`, `idc`
- VPS: `p='pass'`, `ps='pass show'`, `pc='pass -c'`
- Transmission (conf.d/20): `taa`, `tc`, `tp`, `tr`, `tl`, `ts`

On oreb, `babbie` and `weforge` expand to `ssh <host>`. The host-gated
`ssh` function then chooses the transport:

- Plain Kitty window with a real TTY → `kitten ssh`, so the remote receives
  Kitty's terminfo before Zellij or other TUIs start.
- Local Zellij, non-Kitty terminals, non-TTY commands, or missing `kitten` →
  OpenSSH.

## SSH agent
Managed by a user-level systemd unit:
```
~/.config/systemd/user/ssh-agent.service  ← unit file
$XDG_RUNTIME_DIR/ssh-agent.socket         ← socket exposed at login
```
The zshrc exports `SSH_AUTH_SOCK` pointing at the socket. Keys are loaded manually with `ssh-add`.

```bash
systemctl --user status ssh-agent     # Check status
ssh-add ~/.ssh/id_ed25519_sk          # Add the hardware key
ssh-add -l                            # List loaded keys
```

### Human vs. agent identity
`~/.ssh/config` routes SSH auth by *who is calling*: the human gets the YubiKey
(`id_ed25519_sk`), AI agents (Claude Code, Codex) get a passphraseless software key
(`id_ed25519`) with the hardware key unreachable — so agents can no longer trip the
YubiKey's PIN/touch prompt and hijack the terminal. The split is decided by the
`~/.ssh/agent-context` probe (env markers + `/proc` ancestry). See
`docs/ai-context/apps/yubikey-touch.md` → *Keeping Agents Off the Key*.

## Vi mode
Not enabled. Robbyrussell is delivered as-is, with stock emacs-mode bindings.
If vi-mode is desired later, append `bindkey -v` to `dot_zshrc.tmpl` and add a `vi-mode` plugin or custom keymap. Mode indicators in the prompt would require extending the theme.

## Switching to zsh as login shell
After `chezmoi apply`, the user runs once:
```bash
chsh -s $(which zsh)
```
Then a new terminal session uses zsh. Not chezmoi-managed — login shell change requires user action.

## Verification
```bash
echo $SHELL                                # → /usr/bin/zsh
omz plugin list                            # → git, zsh-autosuggestions, ...
which vpc                                  # → vpn-connect (function)
systemctl --user status ssh-agent          # → active
echo $SSH_AUTH_SOCK                        # → /run/user/1000/ssh-agent.socket
zsh tests/test_ssh_wrapper.zsh           # → wrapper routing test
```

## Cross-machine notes
- **CachyOS (mani, oreb)**: `zsh` installed via pacman; oh-my-zsh + plugins via git clone
- **Debian (babbie)**: `zsh` installed via apt; oh-my-zsh + plugins via git clone
- The same `run_once_install-oh-my-zsh.sh` script handles both

## Why these specific choices?

### Pure robbyrussell, no mode indicator
The fish prompt rendered `[N]`/`[I]`/`[V]`/`[R]` indicators. Robbyrussell does not. Extending robbyrussell to preserve the indicators was offered but declined — pure theme honors its design.

### Plain aliases, not zsh-abbr
Fish `abbr` expanded inline before execution (visible). The user accepted the loss of that visibility in exchange for fewer plugin dependencies. Aliases expand silently.

### systemd ssh-agent, not the OMZ plugin
The OMZ `ssh-agent` plugin spawns a new agent per shell. The systemd user service runs one agent per login session, shared across all shells. Aligns with how `goosevpn` and `tor` are managed in this repo.

### Git-cloned plugins, not OS packages
Both Arch and Debian have apt/pacman packages for the three extensions, but the installed paths differ. Git-cloning to `$ZSH/custom/plugins/` produces a single path that works identically on both systems.

### `unalias ls` after oh-my-zsh
Oh-my-zsh's `lib/theme-and-appearance.zsh` unconditionally aliases `ls='ls --color=tty'` on Linux. Our autoload `ls` function delegates to `lsd`, which only accepts `always|auto|never` for `--color`. After alias expansion zsh forwards `--color=tty` into the function, into `lsd`, into an error. `dot_zshrc.tmpl` strips the alias with `unalias ls 2>/dev/null` immediately after the autoload block, leaving the broader `LSCOLORS`/`LS_COLORS` exports from the same lib file intact (other tools still need them). `ls` was the first autoload function shadowed by shell defaults; the oreb-only `ssh` wrapper is intentionally introduced as a command shadow with its own fallback to `command ssh`.

---

*"The shell does not give commands; it receives intentions."*
