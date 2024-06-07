#!/bin/bash

# ============================================================
# Function: 备份和恢复docker volume
# Note: 以root权限执行
# Crontab Example: 0 3 * * * /backup/docker_volume_backup_restore.sh backup volume_name
# ============================================================

# Check if at least two arguments are provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 {backup|restore} VOLUME_NAME [NEW_VOLUME_NAME]"
    exit 1
fi

# 获取脚本所在目录
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# 打印脚本所在目录
echo "The script is located in: $SCRIPT_DIR"

# Assign arguments to variables
ACTION=$1
VOLUME_NAME=$2
NEW_VOLUME_NAME=$3
BACKUP_DIR="${SCRIPT_DIR}/volume"
BACKUP_FILE="${BACKUP_DIR}/${VOLUME_NAME}_backup.tar"

# Ensure the backup directory exists
mkdir -p ${BACKUP_DIR}

# Function to perform backup
backup_volume() {
    echo "Backing up volume ${VOLUME_NAME} to ${BACKUP_FILE}..."
    docker run --rm \
        -v ${VOLUME_NAME}:/volume-data \
        -v ${BACKUP_DIR}:/backup \
        alpine \
        sh -c "cd /volume-data && tar cf /backup/$(basename ${BACKUP_FILE}) ."

    echo "Backup of ${VOLUME_NAME} completed: ${BACKUP_FILE}"
}

# Function to perform restore
restore_volume() {
    if [ -z "${NEW_VOLUME_NAME}" ]; then
        echo "Error: NEW_VOLUME_NAME is required for restore action."
        echo "Usage: $0 restore VOLUME_NAME NEW_VOLUME_NAME"
        exit 1
    fi

    echo "Restoring volume ${VOLUME_NAME} from ${BACKUP_FILE} to ${NEW_VOLUME_NAME}..."
    docker volume create ${NEW_VOLUME_NAME}

    docker run --rm \
        -v ${NEW_VOLUME_NAME}:/volume-data \
        -v ${BACKUP_DIR}:/backup \
        alpine \
        sh -c "cd /volume-data && tar xf /backup/$(basename ${BACKUP_FILE})"

    echo "Restoration of ${NEW_VOLUME_NAME} completed from ${BACKUP_FILE}"
}

# Determine the action to perform
case "${ACTION}" in
    backup)
        backup_volume
        ;;
    restore)
        restore_volume
        ;;
    *)
        echo "Invalid action: ${ACTION}"
        echo "Usage: $0 {backup|restore} VOLUME_NAME [NEW_VOLUME_NAME]"
        exit 1
        ;;
esac

