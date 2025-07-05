# node_backup.sh

**Purpose**:
Dual-backup script for DaishoSentinel nodes. Performs an incremental rsync to:
- Remote SMB snapshot server (`<INTERNAL_IP>/Snapshots`)
- Local USB drive (`/dev/sdb1` mounted on `/media/<user>/usb_backups`)

**Used by**:
- DaishoSentinel module nodes

**Important**:
- Do not hardcode credentials. Use `$HOME/.smbcredentials`.
- Replace `<INTERNAL_IP>`, `<user>` and device names as per your lab setup.
- Exclusion rules defined in `$HOME/.node_backup.exclude`.

**Warning**:
Requires `sudo` to mount and access system directories.

**Log Output**:
- Located in `$HOME/logs/daisho_logs/`
