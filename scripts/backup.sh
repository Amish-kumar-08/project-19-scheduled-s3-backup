
#!/bin/bash

# Project 19: Automated Linux System Log Backup

set -Eeuo pipefail

PROJECT_DIR="/home/clouduser/Desktop/project-19-scheduled-s3-backup"
BUCKET_NAME="project-19-scheduled-backup-590507089733"

BACKUP_DIR="$PROJECT_DIR/backups"
BACKUP_LOG="$PROJECT_DIR/backup.log"

TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_FILE="system-logs-$TIMESTAMP.tar.gz"

TEMP_LIST=$(mktemp)

# Record errors
trap 'echo "$(date): FAILED - Backup process encountered an error" >> "$BACKUP_LOG"; rm -f "$TEMP_LIST"' ERR
trap 'rm -f "$TEMP_LIST"' EXIT

mkdir -p "$BACKUP_DIR"

# Find actual readable Linux system logs
find /var/log -maxdepth 1 -type f -readable \
    \( -name 'syslog*' \
    -o -name 'auth.log*' \
    -o -name 'kern.log*' \
    -o -name 'cloud-init.log*' \
    -o -name 'cloud-init-output.log*' \
    -o -name 'dmesg*' \) \
    -printf '%f\0' > "$TEMP_LIST"

# Ensure logs were found
if [ ! -s "$TEMP_LIST" ]; then
    echo "$(date): FAILED - No readable system logs found" >> "$BACKUP_LOG"
    exit 1
fi

# Create compressed archive
tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
    -C /var/log \
    --null -T "$TEMP_LIST"

# Upload archive to S3
aws s3 cp "$BACKUP_DIR/$BACKUP_FILE" \
    "s3://$BUCKET_NAME/backups/$BACKUP_FILE"

# Record successful backup
echo "$(date): SUCCESS - Uploaded $BACKUP_FILE to S3" >> "$BACKUP_LOG"

echo "Backup completed: $BACKUP_FILE"

