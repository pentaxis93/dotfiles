# XDG Desktop Portal — Backend Routing

## Ultra-Zen Philosophy
**"The application knocks; the portal answers through the door that opens, not the one that has fallen."**

## The Problem It Solves

On Wayland, a sandboxed-or-not application does not draw its own file dialog,
"Open with…" chooser, or read the system theme. It asks **xdg-desktop-portal**,
which routes each request to a *backend* implementation. Niri is not GNOME and
not KDE, so the choice of backend is not automatic — it is configured.

The niri package ships `/usr/share/xdg-desktop-portal/niri-portals.conf` with:

```ini
[preferred]
default=gnome;gtk;
```

That `default` sends every interface not explicitly overridden — crucially
**FileChooser** — to `xdg-desktop-portal-gnome` *first*. On Niri there is no
GNOME session for that backend to attach to, and as of
`xdg-desktop-portal-gnome 50.0` (the 2026-05-21 update, built against
`glib2 2.88` / `gtk4 4.22`) it **crashes on startup with SIGABRT**. The portal
commits to the chosen backend and does not fall through to `gtk` when it dies.

The visible symptom: clicking a file-upload button in Firefox produced **no
dialog at all** — the request went to a backend that core-dumped. The same crash
silently disabled "Open with…" choosers and portal-based dark-mode detection.

> `xdg-desktop-portal-gnome` is not a chosen package — it arrives as a
> dependency of `cachyos-niri-settings` → `niri`. The dotfiles declare no portal
> packages.

## Architecture
- **xdg-desktop-portal** — the frontend; reads `*-portals.conf` at startup to map
  each `org.freedesktop.impl.portal.*` interface to a backend
- **xdg-desktop-portal-gtk** — the canonical, session-agnostic backend; serves
  FileChooser, AppChooser, Settings, Print, Notification, … Always healthy here
- **xdg-desktop-portal-gnome** — GNOME's backend; the *only* implementer of
  ScreenCast, Screenshot, RemoteDesktop, Background, Wallpaper, GlobalShortcuts,
  Clipboard, InputCapture, Usb. Currently crashing, but retained as the fallback
  for those gnome-only interfaces for when upstream recovers
- **Config precedence** — `$XDG_CONFIG_HOME/xdg-desktop-portal/` outranks
  `/usr/share/`. The highest-precedence `<desktop>-portals.conf` is used **whole**
  (configs are *not* merged), so our file must be self-contained

## Configuration Files
- **Routing override**: `home/dot_config/xdg-desktop-portal/niri-portals.conf` →
  `~/.config/xdg-desktop-portal/niri-portals.conf` — a plain (non-templated) file;
  identical on every Niri machine
- **Host gate**: `home/.chezmoiignore` — `.config/xdg-desktop-portal` excluded
  under the `{{ if .is_vps }}` block (headless VPS has no portal need)

## The Override

```ini
[preferred]
default=gtk;gnome;
org.freedesktop.impl.portal.Secret=gnome-keyring;
```

`gtk` becomes the default, so it answers FileChooser, AppChooser, Settings and
every other interface it implements. `gnome` remains second, still selected for
the interfaces only it provides. The `Secret=gnome-keyring` line is carried
forward verbatim from the upstream file (its backend is not installed, so the
line is a harmless no-op — the portal logs `Requested backend gnome-keyring does
not exist. Skipping...`, as it did before this change).

This is not merely a workaround for the crash. On a non-GNOME compositor, `gtk`
*is* the correct file chooser; the GNOME backend was only ever appropriate while
it happened to run. The crash revealed a latent misconfiguration; the override
corrects it.

## Verification

Confirm which backend owns each interface by reading the portal's own routing
log (verbose mode), without opening any dialog:

```bash
systemctl --user set-environment G_MESSAGES_DEBUG=all
systemctl --user restart xdg-desktop-portal.service
journalctl --user -u xdg-desktop-portal.service --since "10 seconds ago" \
  | grep "Using .* for"
systemctl --user unset-environment G_MESSAGES_DEBUG
systemctl --user restart xdg-desktop-portal.service   # restore clean state
```

The proof line:

```
Using gtk.portal for org.freedesktop.impl.portal.FileChooser (config)
```

The definitive end-to-end test is a real click: a file-upload button in Firefox
now opens the GTK file chooser.

## Machine Scope
- **Desktop / laptop** (`mani`, `oreb`): deployed — both run Niri
- **VPS** (`babbie`): excluded via `.chezmoiignore` — no graphical session

## Troubleshooting

### File dialog still does not appear
```bash
# Is the override deployed and read?
cat ~/.config/xdg-desktop-portal/niri-portals.conf
# Which backend is FileChooser using? (see Verification above) — expect gtk
# Is the gtk backend healthy?
systemctl --user is-active xdg-desktop-portal-gtk.service   # → active
```

### After a future update fixes xdg-desktop-portal-gnome
The override remains correct — `gtk` is the right FileChooser backend on Niri
regardless. ScreenCast / Screenshot / screen-sharing route to `gnome` and will
resume working automatically once that backend stops crashing. To return all
routing to the upstream default, delete this file and `chezmoi apply`.

### Errors that are expected (not regressions)
- `Failed to ReadAll() from Settings implementation: … gnome … startup job
  failed` — the Settings portal polls *all* backends and merges them; it still
  pings the crashing gnome backend. Harmless; gtk supplies the settings.
- `Requested backend gnome-keyring does not exist. Skipping...` — pre-existing;
  the Secret portal backend is not installed. Unrelated to file dialogs.

---

*"A portal is only as open as the backend behind it. Point the door at the room
that still stands."*
