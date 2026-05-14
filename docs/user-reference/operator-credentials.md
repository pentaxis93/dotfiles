# Operator Credentials

Reference for the credential and secrets infrastructure underlying
tesserine operator workflows.

**This doc does not contain secrets.** It describes the shape of the
system and the recovery paths. Secrets themselves live in Bitwarden.

---

## Storage architecture

Three storage layers, each with its own scope and audience.

### Personal vault (Bitwarden)

Personal credentials (banks, retail, identity, family). Vault membership
identifies it as personal scope.

- KDF: Argon2id with Bitwarden's UI defaults
- 2FA: TOTP (Authenticator app) + email; YubiKey (FIDO2) pending hardware arrival
- Custodial entries for Mom and Ruth's accounts live here under suffix naming

### Operator vault (Bitwarden — pentaxis93 organization)

Credentials consumed by operator workflows. Vault membership identifies
it as operator scope. All entries in the Default collection.

Examples of what belongs here:
- API tokens for paid services (Anthropic, OpenRouter)
- SSH keys for production hosts
- OAuth credentials for operator-side integrations
- The Secrets Manager machine account token

### Secrets Manager (Bitwarden — pentaxis93 organization)

Runtime secrets consumed by execution hosts. Distinct from the Password
Manager vault (different product within the same Bitwarden org).

- Projects named by host (e.g. `babbie`)
- Secret keys in environment-variable format (e.g. `AGENTD_ANTHROPIC_KEY`)
- Accessed by execution hosts via machine account token
- The token itself is stored in the operator Password Manager vault as a
  recovery substrate, in addition to being installed on the host

---

## Naming convention

Friction-aligned: accept Bitwarden's auto-save defaults; minimal
disambiguation only where needed.

- **Entry name** = whatever Bitwarden's auto-save proposes when saving a
  new credential. No manual cleanup, no Title-Casing, no subdomain
  stripping. The names will be domain-style (e.g. `comerica.com`,
  `accounts.hioscar.com`) — that's fine. URI auto-matching is the actual
  lookup mechanism; entry names are purely organizational.
- **Multi-account services**: default name + ` - {Label}` suffix to
  disambiguate. Minimal transformation:
  - `google.com - Primary`, `google.com - Honey`, `google.com - Mom`,
    `google.com - Ruth`
  - `github.com - Operator`, `github.com - Personal` (if multiple)
- **Custom fields (Hidden type)** for related secondary secrets within an
  entry: backup codes, recovery codes, secondary credentials
- **URIs** do URL auto-matching for browser/app fill
- **No folders.** Bitwarden's URI auto-matching is the actual lookup
  mechanism; folders not load-bearing
- **Existing Title-Case entries** (`Comerica`, `Facebook`, etc.) from
  prior reorganization persist where they are. Migrate-on-touch: rename
  to default style if you happen to be editing an entry for other
  reasons. No dedicated bulk migration.
- **Canonical reference form** (documentation only, never appears in
  Bitwarden itself): `<scope>/<subject>/<purpose>`
  - Examples: `operator/babbie/ssh-core`, `personal/google/primary/login`
  - Scope words `personal` / `operator` appear only in references; never
    as folder names, prefixes, or anywhere in Bitwarden UI

---

## Operator infrastructure

### babbie (development VPS)

- **Provider**: OVHcloud
- **OS**: Fedora CoreOS
- **User**: `core`
- **Authentication**: SSH key (entry in operator vault)

Components installed on babbie:

| Component | Path |
|---|---|
| bws CLI (v2.0.0+) | `~/.local/bin/bws` |
| Secrets Manager token | `/var/lib/tesserine/config/secrets-manager.token` (mode 0600, owner core) |
| Secrets loader script | `~/.local/bin/agentd-secrets-loader` |
| agentd Quadlet | `~/.config/containers/systemd/agentd.container` |
| credentials.env (loader output) | `/var/lib/agentd/credentials.env` (mode 0600) |

### Secret flow per agentd start

1. systemd ExecStartPre invokes `agentd-secrets-loader`
2. Loader reads the Secrets Manager token from its file
3. Loader calls `bws` with the token; fetches all secrets for project=`babbie`
4. Loader writes `credentials.env` in env-file format (decoded UTF-8 values)
5. Podman starts agentd container with `--env-file credentials.env`

### When a secret rotates

1. Update the value in Bitwarden Secrets Manager (web UI or `bws` CLI)
2. Restart agentd: `systemctl --user restart agentd`
3. Loader fetches the new value on restart; no manual key handling needed

### Operator-critical accounts — 2FA state

| Account | 2FA methods registered |
|---|---|
| Bitwarden | TOTP (Authenticator) + email; YubiKey FIDO2 pending |
| Google primary | Authenticator + Google Prompt + Passkey + backup codes |
| Google honey | Authenticator + Google Prompt + Passkey + backup codes |

Backup codes stored as Hidden custom fields on the respective Bitwarden
entries. GitHub, OVH, Anthropic, OpenRouter 2FA inventory pending.

---

## Recovery procedures

### Lost master password

- Paper backup in physical secure storage (see global recovery substrate
  workshop — pending)
- Without paper backup: account recovery email path via the
  Bitwarden-registered email (primary Gmail, which is hardened)

### Lost YubiKey (post-arrival)

Alternative 2FA methods remain available on every account:
- Bitwarden: TOTP + email
- Google accounts: Authenticator + Google Prompt + Passkey + backup codes

Re-register a replacement YubiKey when obtained; remove the lost key's
registration on each account.

### Lost phone

1. From any signed-in browser: `https://android.com/find` → locate, ring,
   lock, or wipe
2. Contact carrier to suspend the SIM (Telekom in Hungary; appropriate
   US carrier in Scottsdale)
3. Access backup codes for Google accounts from Bitwarden on laptop
4. If compromise suspected (vs simple loss): reset Google passwords from
   laptop within the unlock window

### Babbie host failure

If babbie becomes unrecoverable:

1. Provision new VPS (FCOS or equivalent)
2. Restore SSH key from operator vault
3. Restore Secrets Manager token from operator vault entry
4. Re-deploy agentd Quadlet + loader script from this dotfiles repo
5. If the project name in Secrets Manager differs (new host name), update
   the project; populate with new host's secrets

### Secrets Manager token compromise

1. Revoke compromised token in Bitwarden Secrets Manager
2. Generate a replacement token via the machine account
3. Update the token file on babbie: `/var/lib/tesserine/config/secrets-manager.token`
4. Update the operator vault entry with the new token value
5. `systemctl --user restart agentd`

---

## Disciplines

### Migrate-on-touch

When reaching for a credential in any non-Bitwarden store (Firefox
passwords, LastPass, Google Password Manager, etc.):

1. Look it up in the legacy store
2. Create a Bitwarden entry under the naming convention above
3. Verify the entry works
4. Delete from the legacy store

This drains legacy stores over time without requiring bulk migration
upfront.

### New credentials → Bitwarden first

When creating any new account:

1. Bitwarden generates the password (random, strong)
2. Account creation uses that generated password
3. 2FA enrolled if the service supports it
4. Backup codes saved as Hidden custom field on the Bitwarden entry

### Operator vs personal scope decision

When in doubt about which vault: who consumes the credential?

- A workflow you run as operator: operator vault
- A personal account you use as yourself: personal vault

The personal/operator distinction is about *consumers*, not subjects. An
account that's both personal and operator (e.g., a Google account that's
your personal mail AND the identity behind operator-side OAuth) lives in
the personal vault.

### Physical-access secrets stay physical

Phone PIN and SIM PIN are NOT stored in Bitwarden. They protect physical
access to the device; the vault protects digital secrets. Keeping them in
different security domains is intentional defense-in-depth. Recovery for
these (inheritance / catastrophic-memory-loss scenarios) belongs to
physical paper backup in the global recovery substrate.

---

## What this doc is NOT

- Not the secrets themselves. Secrets live in Bitwarden.
- Not exhaustive personal hygiene. Personal hygiene has its own work.
- Not crypto. Crypto hygiene has its own module.
- Not email hygiene. Email is its own workshop.
- Not estate planning. Inheritance/death recovery is part of the global
  recovery substrate workshop.

---

## Update discipline

This doc reflects the operator credential architecture established
through the Operator Secrets Workshop (May 8–12, 2026). Update when:

- Storage architecture changes (new vault layer, new platform)
- New operator-critical accounts come online
- Recovery procedures change (e.g., YubiKey registered, paper backup
  storage established)
- Hosts added or removed
- Secrets Manager projects added or removed
