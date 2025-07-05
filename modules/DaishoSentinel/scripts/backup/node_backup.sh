#!/bin/bash

set -e  # Abort on any unexpected error

# ===============================================================
#  DaishoSentinel - Node Backup Script (Anonimized Version)
#  Author: Daisho Team
#  Description: Performs a dual backup from local system to
#               1) SMB remote snapshot node
#               2) Local USB disk
# ===============================================================

# ==== CONFIGURATION ====

DATE=$(date +"%Y%m%d_%H%M%S")
LOG="$HOME/logs/daisho_logs/node_backup_$DATE.log"
EXCLUDE="$HOME/.node_backup.exclude"

# SMB Backup
MOUNT_POINT="/mnt/daisho_snapshots"
DESTINATION="$MOUNT_POINT/node_backup"
SAMBA_SOURCE="//<INTERNAL_IP>/Snapshots"
CREDENTIALS_FILE="$HOME/.smbcredentials"

# USB Backup
USB_MOUNT="/media/<user>/usb_backups"
USB_DEST="$USB_MOUNT/node_backup"

# Ensure log directory exists
mkdir -p "$HOME/daisho_logs"

# ==== MOUNT SMB SHARE ====

echo "Mounting SMB snapshot share..."

if ! mountpoint -q "$MOUNT_POINT"; then
    sudo mount -t cifs "$SAMBA_SOURCE" "$MOUNT_POINT" \
        -o credentials="$CREDENTIALS_FILE",vers=3.0,uid=$(id -u),gid=$(id -g)
    if [ $? -ne 0 ]; then
        echo "Error mounting SMB share." | tee -a "$LOG"
        notify-send "Daisho Backup" "Error mounting SMB share."
        exit 1
    fi
else
    echo "SMB share already mounted."
fi

# ==== VERIFY ACCESS TO DESTINATION ====

if [ ! -d "$DESTINATION" ]; then
    echo "Creating backup destination $DESTINATION"
    mkdir "$DESTINATION" || {
        echo "Failed to create $DESTINATION. Check permissions." | tee -a "$LOG"
        notify-send "Daisho Backup" "Error creating backup destination."
        sudo umount "$MOUNT_POINT"
        sudo sh -c 'echo 1 > /proc/sys/vm/drop_caches'
        exit 1
    }
fi

if [ ! -w "$DESTINATION" ]; then
    echo "No write permissions on $DESTINATION" | tee -a "$LOG"
    notify-send "Daisho Backup" "Write permission denied."
    sudo umount "$MOUNT_POINT"
    sudo sh -c 'echo 1 > /proc/sys/vm/drop_caches'
    exit 1
fi

# ==== RSYNC TO SMB DESTINATION ====

echo "Starting incremental backup to SMB..." | tee -a "$LOG"

rsync -aAXv --delete \
    --exclude-from="$EXCLUDE" \
    /home /etc /opt /usr/local /var/log "$DESTINATION" 2>>"$LOG" | tee -a "$LOG"

RSYNC_CODE=${PIPESTATUS[0]}

# ==== UNMOUNT SMB ====

echo "Unmounting SMB snapshot share..."
sudo umount "$MOUNT_POINT"

# ==== USB BACKUP ====

echo "Checking USB backup device..." | tee -a "$LOG"

if [ ! -d "$USB_MOUNT" ]; then
    echo "Creating USB mount point $USB_MOUNT..." | tee -a "$LOG"
    sudo mkdir -p "$USB_MOUNT"
fi

if ! mountpoint -q "$USB_MOUNT"; then
    echo "USB not mounted. Attempting to mount /dev/sdb1..." | tee -a "$LOG"
    if ! sudo mount -t ext4 /dev/sdb1 "$USB_MOUNT"; then
        echo "Failed to mount /dev/sdb1. Skipping USB backup." | tee -a "$LOG"
        notify-send "Daisho USB Backup" "Mount failed. Skipping."
        USB_AVAILABLE=false
    else
        echo "USB mounted at $USB_MOUNT." | tee -a "$LOG"
        USB_AVAILABLE=true
    fi
else
    echo "USB already mounted." | tee -a "$LOG"
    USB_AVAILABLE=true
fi

if [ "$USB_AVAILABLE" = true ]; then
    echo "Starting USB backup to $USB_DEST..." | tee -a "$LOG"
    mkdir -p "$USB_DEST"

    rsync -aAXv --delete \
        --exclude-from="$EXCLUDE" \
        /home /etc /opt /usr/local /var/log "$USB_DEST" 2>>"$LOG" | tee -a "$LOG"

    echo "USB backup completed." | tee -a "$LOG"
    notify-send "Daisho USB Backup" "Backup completed successfully."
fi

# ==== RSYNC RESULT ANALYSIS ====

if [ "$RSYNC_CODE" -eq 0 ]; then
    echo "Sync completed successfully to SMB ($DESTINATION)" | tee -a "$LOG"
    notify-send "Daisho Backup" "SMB backup completed without errors."

elif [ "$RSYNC_CODE" -eq 23 ]; then
    echo "Sync completed with warnings (some files skipped)." | tee -a "$LOG"
    echo "" >> "$LOG"
    echo "Summary of files not backed up due to permission issues:" >> "$LOG"
    echo "--------------------------------------------------------" >> "$LOG"

    grep -E "Permission denied|failed to open|failed to stat|failed to read|opendir.*failed" "$LOG" | \
    awk -F'rsync: \\[sender\\] ' '{print $2}' | \
    awk -F'[:]' '{printf "• %-60s %s\n", $1, $2}' >> "$LOG"

    TOTAL_SKIPPED=$(grep -cE "Permission denied|failed to open|failed to stat|failed to read|opendir.*failed" "$LOG")

    echo "--------------------------------------------------------" >> "$LOG"
    echo "* Total skipped items: $TOTAL_SKIPPED" >> "$LOG"

    notify-send "Daisho Backup" "Finished with $TOTAL_SKIPPED skipped items."

else
    echo "Critical error during rsync (code $RSYNC_CODE)" | tee -a "$LOG"
    notify-send "Daisho Backup" "rsync failed with code $RSYNC_CODE. Check logs."
    exit 1
fi

# ==== CLEANUP ====

sudo sh -c 'echo 1 > /proc/sys/vm/drop_caches'
