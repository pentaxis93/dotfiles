# YubiKey Touch Detector

## Ultra-Zen Philosophy
**"The key still demands its touch; we restore the voice the agent took away."**

## The Problem It Solves

SSH authentication to the VPSes uses a FIDO2 hardware key (`ed25519-sk`, bound to the
YubiKey). Every connection requires a physical touch — the key blinks, you tap it, the
circuit completes.

There are two ways that touch gets requested, and they differ in one crucial respect:

- **`ssh` signs from a key file on disk** → the interactive client holds a terminal and
  prints `Confirm user presence for key …`. The touch is *announced*.
- **`ssh-agent` signs** → the touch is still enforced, but the agent is a daemon with no
  controlling terminal. It cannot print. The key blinks *unannounced*.

When agent forwarding to `babbie` was introduced (so the agent could carry the key for
onward git/SSH auth — see SSH config `ForwardAgent yes`), the hardware key moved into the
agent as a resident key with no on-disk handle. From that point **every** signature is
agent-mediated, and the textual prompt vanished. The terminal appeared to block silently;
only the blink betrayed that a touch was wanted.

### The tension worth understanding
A single key cannot both be *forwarded by the agent* and *print ssh's native file-based
prompt* — forwarding requires the key in the agent, and a key in the agent signs
silently. You cannot have both for one key. The resolution is not to fight the agent but
to add an external observer that watches the key itself.

> Note: `kitten ssh` and the Kitty migration are unrelated. The prompt is suppressed by
> *who signs* (the agent), not by the terminal or terminfo transmission.

## Architecture
- **yubikey-touch-detector** — a small daemon (maximbaz) that watches for the YubiKey
  entering its "waiting for touch" state across **U2F/FIDO2 and GPG** operations
- **libnotify notification** — fires a desktop notification while the key awaits a touch,
  restoring the cue for `ssh`, and as a bonus covering `git` over SSH and `sudo`-u2f
- **systemd user service** — package-shipped unit, enabled persistently (matches how
  `ssh-agent`, `tor`, and `goosevpn` are managed in this repo)
- **Notification-only** — no Waybar indicator; a touch lasts only a second or two, so the
  notification is the workhorse. The detector's `.socket` remains available should a
  Waybar reader ever be wanted

## Configuration Files
- **Service config**: `home/dot_config/yubikey-touch-detector/service.conf` →
  `~/.config/yubikey-touch-detector/service.conf` — sets
  `YUBIKEY_TOUCH_DETECTOR_LIBNOTIFY=true` (read by the shipped unit via `EnvironmentFile`)
- **Service enablement**: `home/run_once_setup-yubikey-touch-detector.sh.tmpl` —
  `daemon-reload` + `systemctl --user enable --now yubikey-touch-detector.service`,
  gated `{{ if not .is_vps }}`
- **Package**: `home/.chezmoidata/packages.yaml` — `yubikey-touch-detector` under
  `cachyos.aur` (System & Security grouping)
- **Related — SSH client**: `home/private_dot_ssh/private_config` — the `ForwardAgent yes`
  on `babbie` that makes the key agent-resident, and `IdentityFile ~/.ssh/id_ed25519_sk`
  with `IdentitiesOnly yes` on every host
- **Related — ssh-agent**: `home/dot_config/systemd/user/ssh-agent.service.tmpl` — the
  systemd user agent the sk-key is loaded into (`ssh-add ~/.ssh/id_ed25519_sk`)

## Why the `.service`, not the `.socket`
The package ships both `yubikey-touch-detector.service` and `.socket`. Socket activation
starts the daemon when a consumer (e.g. Waybar) connects to the socket. With
notification-only there is no consumer — so socket activation would never start the
daemon, and no notifications would fire. Enabling the `.service` directly runs the daemon
persistently from login, watching the key on its own.

## Keeping Agents Off the Key

The detector restored the *cue*. A second, deeper problem remained: the key is for
the human, yet **AI agents** (Claude Code, Codex) running in the same session would
trigger it. An agent's `git fetch` or `ssh` loaded `id_ed25519_sk` exactly as the
human's would, and the terminal blocked on a PIN/touch prompt the agent could neither
satisfy nor explain — a hijack.

The resolution is to give the two callers *different keys* and route by who is asking:

- **Human** → the YubiKey (`~/.ssh/id_ed25519_sk`), exactly as before.
- **AI agent** → a passphraseless software deploy key (`~/.ssh/id_ed25519`), with
  agent access and forwarding disabled. The hardware key is unreachable on this path,
  so no PIN/touch is ever demanded.

### How the caller is identified
`~/.ssh/agent-context` (`home/private_dot_ssh/executable_agent-context`) is a probe
that exits 0 inside an agent. It detects in two layers — *a marker is a claim, ancestry
is a fact*:

1. **Environment markers** each agent stamps onto the processes it spawns
   (`CLAUDECODE`, `AI_AGENT`, `CODEX_HOME`, …). A human's interactive shell carries none.
2. **Process ancestry** — walks `/proc` for the agent's own process (`comm` =
   `claude`/`codex`). This holds even when an agent advertises no variable, so Codex is
   caught structurally regardless of its env. A new agent is taught by adding one line.

`~/.ssh/config` calls the probe from two mutually-exclusive `Match exec` blocks placed
*before* every `Host` block (for `IdentityFile`/`IdentityAgent`/`ForwardAgent` the first
value obtained wins, so the gate decides identity before any host default). The agent
branch sets `IdentitiesOnly yes` + `IdentityAgent none`, guaranteeing it can reach *only*
the software key even for unlisted hosts. **Fails closed:** if `id_ed25519` is absent the
agent is denied (`publickey`), never fallen back to the YubiKey.

### Relationship to forwarding
This narrows the `ForwardAgent yes` on `babbie` to humans only — agents get
`ForwardAgent no`. The forwarding tension above (a forwarded key signs silently) is now
moot for agents, which never touch the hardware key at all.

### The software key
`~/.ssh/id_ed25519` is a per-host secret, deliberately **not** chezmoi-managed (it must
never enter the repo). `home/run_once_generate-agent-softkey.sh.tmpl` creates it if absent
(idempotent — regenerating would orphan already-registered public keys). Its **public**
half must be authorized by hand on each remote agents reach (GitHub account keys; the
`core` user's `authorized_keys` on babbie/weforge; the `git` user's on git.weforge.build).

## Machine Scope
- **Desktop / laptop** (`mani`, `oreb`): full stack — AUR package, `service.conf`,
  enabled service. Notifications require a running notification daemon (already present;
  the transmission/VPN flows use `notify-send`)
- **VPS** (`babbie`): excluded — the AUR list does not apply on Debian, and the config
  directory and run-once script are listed in `.chezmoiignore` under the VPS block

## Usage
The detector is invisible until the key is touched. There is nothing to invoke:

```bash
ssh babbie          # key blinks → "Waiting for YubiKey touch" notification appears → tap
git push            # (over SSH to a sk-authenticated remote) → same cue
```

Management, if ever needed:
```bash
systemctl --user status yubikey-touch-detector.service   # health
journalctl --user -u yubikey-touch-detector -f           # live log
```

## Verification
```bash
chezmoi apply -v
systemctl --user status yubikey-touch-detector.service   # → active (running)
ssh babbie                                                # → notification fires on blink
```
sk-key touches travel the U2F path the detector watches, so a notification appearing
during `ssh babbie` is the true confirmation the cue is restored. The agent is untouched:
`ssh-add -l` still lists the sk-key, and agent forwarding to `babbie` still functions.

---

*"The agent signs in silence; the detector lends it a voice — and the key, as ever, waits
for the touch that proves a human is present."*
