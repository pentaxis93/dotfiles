# ZFS Time Machine & Data Integrity System

## Ultra-Zen Philosophy
**"Storage becomes a time machine; every moment preserved, every change reversible, integrity guaranteed"**

## Architecture
- **ZFS Pool** - `zpcachyos` with automatic snapshots and integrity checking
- **Automated Snapshots** - Layered time retention from 15-minute to monthly intervals
- **Automated Scrubbing** - Monthly integrity verification with checksum validation
- **Fish Functions** - Semantic snapshot management commands
- **Copy-on-Write** - Snapshots consume zero space initially, growing only with changes

## Current Pool Structure
```
zpcachyos (236G pool)
├── ROOT/cos/home              - User files with snapshot protection
│   ├── videos                 - Transient: snapshots disabled
│   ├── downloads              - Transient: snapshots disabled
│   ├── cache                  - Transient: XDG cache (~/.cache)
│   ├── gradle                 - Transient: Gradle build cache (~/.gradle)
│   ├── bun                    - Transient: Bun runtime + cache (~/.bun)
│   ├── npm                    - Transient: npm package cache (~/.npm)
│   └── rustup                 - Transient: Rust toolchains (~/.rustup)
├── ROOT/cos/root              - System files with rollback capability
├── ROOT/cos/varcache          - Package cache (snapshots disabled)
└── ROOT/cos/varlog            - System logs (snapshots disabled)
```

## Snapshot Inclusion Policy

Not all data deserves the time machine. Two categories of dataset exist:

**Snapshotted (the witnesses):**
- `home`, `root` — Configs, code, documents. Irreplaceable. Worth preserving every 15 minutes.

**Excluded (the unwitnessed):**
- `varcache`, `varlog` — System ephemera, regenerable from sources.
- `home/videos`, `home/downloads` — Transient flow. Large files in transit.
- `home/cache`, `home/gradle`, `home/bun`, `home/npm`, `home/rustup` — Toolchain caches and regenerable installations. Recreated on demand by `cargo`, `bun`, `npm`, `gradle`, `rustup`.

The exclusion is enforced via `com.sun:auto-snapshot=false`. The `zfs-auto-snapshot` daemon honours this property and skips the dataset entirely.

### Why Transient Paths Need Their Own Datasets

Snapshots are copy-on-write: deletion in the live filesystem does not free blocks if any snapshot still references them. A file downloaded at 09:00, snapshotted at 09:15, deleted at 09:16 — the blocks remain pinned by the 09:15 snapshot until that snapshot is destroyed or ages out per retention policy.

For directories like `~/Videos` and `~/Downloads`, where 10–100GB of files routinely pass through, this turns the time machine into a leak. A separate dataset with `auto-snapshot=false` lets these directories live on the same pool with the same fragmentation/compression benefits, but without the snapshot witness — deletion frees space immediately.

## Automated Snapshot Schedule

Time is layered - recent history in fine detail, distant past in broader strokes:

- **Frequent**: Every 15 minutes, keep 4 (last hour)
- **Hourly**: Every hour, keep 24 (last day)
- **Daily**: Every day, keep 31 (last month)
- **Weekly**: Every week, keep 8 (last 2 months)
- **Monthly**: Every month, keep 12 (last year)

Snapshots are named automatically: `@auto-2025-09-30-15h00`

## Data Integrity Guarantee

**Monthly Scrub**: Automated checksum verification of entire pool
- Detects silent data corruption
- Auto-repairs with redundancy (when available)
- Runs on systemd timer: `zfs-scrub-monthly@zpcachyos.timer`

Check scrub status: `zfsstatus`

## Snapshot Management Functions

### `zsnap <dataset> <name>` - Create Manual Snapshot

Create a named snapshot for important moments:

```bash
zsnap zpcachyos/ROOT/cos/home before-upgrade
zsnap zpcachyos/ROOT/cos/home before-cleanup
zsnap zpcachyos/ROOT/cos/root pre-systemd-changes
```

**Safety**: Read-only operation. Cannot destroy data.

**What it does**: Runs `zfs snapshot <dataset>@<name>` transparently.

### `zlist [dataset]` - View Snapshot Timeline

List all snapshots or filter by dataset:

```bash
zlist                              # All snapshots across all datasets
zlist zpcachyos/ROOT/cos/home     # Only /home snapshots
```

**Output shows**:
- Snapshot name and age
- Space consumed (changes since snapshot)
- Creation timestamp

**Safety**: Pure read operation. Just displays information.

### `zclean [days]` - Prune Old Auto-Snapshots

Interactive cleanup of old automatic snapshots (default: 90 days):

```bash
zclean       # Clean auto-snapshots older than 90 days
zclean 30    # More aggressive: 30 days
```

**Safety mechanisms**:
- Only touches `@auto-*` snapshots (manual snapshots ignored)
- Shows complete list before acting
- Requires typing "yes" to confirm
- Can be cancelled at any time

**What it does**:
1. Finds snapshots matching `@auto-*` pattern
2. Filters by age threshold
3. Shows list with space usage
4. Requires explicit confirmation
5. Only then runs `zfs destroy` on each

### `zfsstatus` - Pool Health Summary

Comprehensive health check showing:
- Pool status and errors
- Capacity and fragmentation
- Recent scrub results
- Snapshot count and recent snapshots

```bash
zfsstatus
```

**Safety**: Read-only health check.

## Time Travel: Accessing Snapshots

The most powerful feature - **read-only time travel** through `.zfs/snapshot/`:

### Manual Snapshots
```bash
# You created: zsnap zpcachyos/ROOT/cos/home before-cleanup

# Access old files directly (read-only)
ls /home/.zfs/snapshot/before-cleanup/pentaxis93/.config/
cp /home/.zfs/snapshot/before-cleanup/pentaxis93/.bashrc ~/.bashrc

# Compare current vs snapshot
diff ~/.config/foo.conf /home/.zfs/snapshot/before-cleanup/pentaxis93/.config/foo.conf
```

### Automatic Snapshots
```bash
# Find available auto-snapshots
ls /home/.zfs/snapshot/

# Access yesterday's files
ls /home/.zfs/snapshot/auto-2025-09-29-15h00/pentaxis93/

# Restore a single file from yesterday
cp /home/.zfs/snapshot/auto-2025-09-29-15h00/pentaxis93/important.txt ~/
```

### Why This Approach?

**Selective restore** instead of full rollback:
- ✅ Copy specific files back
- ✅ Compare before/after
- ✅ No risk of destroying current work
- ✅ Read-only access prevents accidents

**Full rollback** (use with extreme caution):
```bash
# This DESTROYS all changes since snapshot!
# Only use when absolutely necessary
zfs rollback zpcachyos/ROOT/cos/home@before-cleanup
```

Prefer the `.zfs/snapshot/` approach for safety.

## Understanding Snapshot Space Usage

**Copy-on-Write Magic**: Snapshots don't copy data - they reference it.

```bash
# Create snapshot (instant, 0 bytes initially)
zsnap zpcachyos/ROOT/cos/home clean-state

# Modify 1GB of files
# Snapshot now shows ~1GB used (old versions it preserves)

# Check space usage
zlist zpcachyos/ROOT/cos/home
```

**Space consumption**:
- New snapshot: 0 bytes (just references)
- As you modify files: snapshot grows (preserves old blocks)
- Delete snapshot: space freed (if no other snapshots need those blocks)

This is why hundreds of snapshots can exist with minimal space cost.

## Manual Recovery Procedures

### Recover Accidentally Deleted File
```bash
# File deleted: ~/Documents/important.pdf

# Find recent snapshot
ls /home/.zfs/snapshot/ | tail -5

# Check if file exists in snapshot
ls /home/.zfs/snapshot/auto-2025-09-30-14h00/pentaxis93/Documents/

# Restore it
cp /home/.zfs/snapshot/auto-2025-09-30-14h00/pentaxis93/Documents/important.pdf ~/Documents/
```

### Recover from Bad Config Change
```bash
# Broke Helix config

# Find snapshot before change
zlist zpcachyos/ROOT/cos/home | grep -B5 "$(date +%Y-%m-%d)"

# Access old config
cat /home/.zfs/snapshot/auto-2025-09-30-13h00/pentaxis93/.config/helix/config.toml

# Restore if good
cp /home/.zfs/snapshot/auto-2025-09-30-13h00/pentaxis93/.config/helix/config.toml ~/.config/helix/
```

### Recover Entire Directory
```bash
# Accidentally deleted ~/Videos/project/

# Find snapshot
ls /home/.zfs/snapshot/auto-2025-09-30-12h00/pentaxis93/Videos/

# Restore whole directory
cp -r /home/.zfs/snapshot/auto-2025-09-30-12h00/pentaxis93/Videos/project ~/Videos/
```

## Advanced Capabilities

### Create Clone (Writable Snapshot)
```bash
# Clone a snapshot for testing
zfs clone zpcachyos/ROOT/cos/home@clean-state zpcachyos/test-environment

# Mount at /mnt/test-env
zfs set mountpoint=/mnt/test-env zpcachyos/test-environment

# Test changes safely, destroy when done
zfs destroy zpcachyos/test-environment
```

### Send/Receive (Backup/Replication)
```bash
# Backup to external drive
zfs send zpcachyos/ROOT/cos/home@backup | pv | zfs receive backup-pool/home

# Incremental backup (only changes)
zfs send -i @last-backup zpcachyos/ROOT/cos/home@new-backup | zfs receive backup-pool/home
```

## Configuration Files
- **Package**: `home/.chezmoidata/packages.yaml` - zfs-auto-snapshot
- **Timer Setup**: `home/run_once_setup-zfs-automation.sh.tmpl` - Snapshot timer + monthly scrub
- **Snapshot Exclusions**: `home/run_once_configure-zfs-snapshots.sh.tmpl` - Disables snapshots on `varcache`, `varlog`
- **Transient Datasets**: `home/run_once_setup-zfs-transient-datasets.sh.tmpl` - Creates dedicated snapshot-free datasets for `~/Videos` and `~/Downloads`
- **Functions**: `home/dot_config/fish/functions/z*.fish.tmpl` - Management commands

### Adding More Transient Paths

Additional candidates for future transient datasets:
- `~/.pub-cache` — Dart/Flutter package cache (~573M)
- `~/.dartServer` — Dart analysis server cache (~568M)
- `~/Android` / `~/fvm` — Android SDK and Flutter version manager (only if you don't mind redownloading SDKs)

To extend the architecture, add a line to `run_once_setup-zfs-transient-datasets.sh.tmpl`:
```bash
ensure_transient_dataset ".pub-cache" "pub-cache"
```
The function is idempotent and refuses to migrate existing content automatically — manual migration steps are emitted when a target directory has data. For systems with existing content, follow the procedure printed by the script.

### Migration of Existing Content

When the script encounters a target with content (Case 3), it prints exact commands to migrate. The general shape is:

```bash
mv ~/X ~/X.migrate                    # metadata-only within parent dataset
sudo zfs create -o mountpoint=~/X \
                -o com.sun:auto-snapshot=false \
                zpcachyos/ROOT/cos/home/x
sudo chown $(id -un):$(id -gn) ~/X
mv ~/X.migrate/* ~/X.migrate/.[!.]* ~/X/    # cross-dataset copy
rmdir ~/X.migrate
```

The cross-dataset move is the only step that consumes pool space (transiently up to the size of the migrated content). Reclaim snapshot space first via `zclean` if the pool is tight.

## ZFS Properties (Current)
- **Compression**: zstd (intelligent space savings)
- **Checksums**: sha256 (automatic integrity verification)
- **Dedup**: off (performance over deduplication)
- **Recordsize**: 128K (balanced for mixed workloads)

## Benefits Summary

**Time Machine**:
- 15-minute granularity for recent changes
- Year-long retention of monthly snapshots
- Instant, zero-cost snapshot creation
- Selective file restoration

**Data Integrity**:
- Every block checksummed automatically
- Monthly scrubs detect silent corruption
- Copy-on-write prevents write holes
- Atomic operations prevent partial writes

**Operational Safety**:
- Transparent functions (see exact commands)
- Interactive confirmations for destructive ops
- Manual snapshots before risky changes
- Read-only time travel via `.zfs/snapshot/`

---

*"The river flows forward, but ZFS remembers every drop. Walk backward through time whenever wisdom requires it."*
