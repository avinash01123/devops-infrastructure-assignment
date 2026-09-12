#!/bin/bash
set -o pipefail

# PostgreSQL Database Backup
# DevOps Trainee Assignment

BACKUP_DIR="/var/backups/db"
CONTAINER="devops-db"
DB_NAME="devopsdb"
DB_USER="devops"

DATE=$(date '+%Y%m%d')
BACKUP_FILE="${BACKUP_DIR}/db_backup_${DATE}.sql.gz"

mkdir -p "$BACKUP_DIR"

echo "Starting PostgreSQL backup..."

if docker exec "$CONTAINER" pg_dump \
    -U "$DB_USER" \
    -d "$DB_NAME" \
    | gzip > "$BACKUP_FILE"; then

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup successful: $BACKUP_FILE"

else

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] Database backup failed" >&2
    rm -f "$BACKUP_FILE"
    exit 1

fi

# Verify backup exists and is not empty
if [ -s "$BACKUP_FILE" ]; then
    echo "Backup size: $(du -h "$BACKUP_FILE" | cut -f1)"
else
    echo "[ERROR] Backup file is empty"
    rm -f "$BACKUP_FILE"
    exit 1
fi
