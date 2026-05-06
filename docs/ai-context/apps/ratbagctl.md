# Ratbagctl - Gaming Peripheral Configuration

## Ultra-Zen Philosophy
**"The mouse remembers what we declare; light yields to intention, written once into firmware"**

## Architecture
- **libratbag** - DBus daemon (`ratbagd`) and CLI (`ratbagctl`) for configuring gaming peripherals
- **Onboard Memory** - All settings written to the device's own NVRAM, not to host config files
- **DBus-Activated** - `ratbagd` is not a long-running service; dbus auto-activates it on demand
- **Hash-Tracked Declaration** - `run_once_*` script enforces our intent on fresh systems
- **Generalized** - Iterates every ratbagctl-known device, every LED — works for current G203 and any future Logitech/Roccat/etc. peripheral

## Configuration Files
- **Configuration Script**: `home/run_once_configure-logitech-rgb.sh.tmpl` - Silences all RGB on every peripheral
- **Package**: `home/.chezmoidata/packages.yaml` (line 139) - libratbag declared under cachyos.pacman

## What We Configure
**Every LED on every ratbagctl-known device → `mode: off`**

The G203 has one LED (the logo). Mode `off` extinguishes it completely — no breathing, no cycling, no static color. The setting is written to the mouse's onboard memory; the mouse remembers it through reboots, suspend, replugs, and use on other Linux/Windows hosts (until something else writes to LED 0).

## Why This Approach

### Where state actually lives
ratbagctl is a courier, not a database. It hands the daemon a setting via DBus; the daemon writes it to firmware once; the daemon goes quiet. There is no config file on disk to manage — the mouse *is* the config file. This is why our run-once script doesn't need to re-apply on every boot.

### Why declare it in the repo
Without the script, the mouse's RGB state lives only in firmware. Power-cycle the mouse hard enough, plug it into a Windows machine that runs Logitech G HUB, or have a competing tool touch LED 0, and the rainbow returns. The repo is silent on what *should* be true. The `run_once_*` script makes our intent durable: any fresh machine setup, any new replacement mouse, gets silenced automatically.

### Why iterate all devices
Today there is only the G203. Tomorrow there might be a keyboard, a different mouse, a headset. The script doesn't hardcode `warbling-mara` — it asks `ratbagctl list` what's there and silences whatever it finds. Future peripherals inherit the policy automatically.

## Usage

### Inspect current state
```bash
ratbagctl list                          # Show all known devices
ratbagctl <device-name> info            # Device capabilities (LED count, profiles, buttons)
ratbagctl <device-name> led 0 get       # Current LED 0 state
```

The `<device-name>` is the friendly identifier ratbagctl assigns (e.g., `warbling-mara` for the G203). Tab completion works.

### Manually re-apply (if state ever drifts)
```bash
ratbagctl <device-name> led 0 set mode off
```
Or just re-run the chezmoi script:
```bash
~/.local/share/chezmoi/home/run_once_configure-logitech-rgb.sh
```

### Reverse the policy (re-enable RGB)
The repo declares LEDs off. To flip that intent, edit the script to set a different mode (e.g., `static`, `cycle`, `breathing`) — the hash will change and the script will re-run on next `chezmoi apply`. Or, for a one-off:
```bash
ratbagctl <device-name> led 0 set mode static --color FF0000  # solid red
ratbagctl <device-name> led 0 set mode cycle --duration 8000  # rainbow
```

### Other ratbagctl operations
```bash
ratbagctl <device-name> dpi get                    # Current DPI
ratbagctl <device-name> dpi set 800                # Set DPI
ratbagctl <device-name> button 0 get               # Button mapping
ratbagctl <device-name> profile active get         # Active profile
```

## Machine Scope
- **Desktop / laptop** (`mani`, `oreb`): script runs (guarded by `not .is_vps`)
- **VPS** (`babbie`): script body is empty — no peripherals to configure

## Currently Configured Devices
| Device | Friendly Name | USB ID | LEDs | State |
|---|---|---|---|---|
| Logitech G203 Prodigy Gaming Mouse | `warbling-mara` | `046d:c084` | 1 (logo) | off |

## Troubleshooting

### `ratbagctl list` shows no devices
```bash
# Check if the device is plugged in
lsusb | grep -i logitech

# Try waking the daemon by hitting it
ratbagctl list

# If still empty, the device may not be supported by libratbag.
# Check: https://github.com/libratbag/libratbag/blob/master/data/devices/
```

### LED accepts mode but doesn't change
Some LEDs need a different command path (e.g., `set color` after `set mode static`). Check capabilities:
```bash
ratbagctl <device-name> led 0 capabilities
```

### "command failed" on `set mode off`
A few non-RGB status LEDs (e.g., DPI indicators) don't accept `off`. The script logs these and continues — they're not RGB lights anyway, so the directive doesn't apply.

---

*"Light obeys the firmware; firmware obeys the daemon; the daemon obeys the script — and the script obeys the repo."*
