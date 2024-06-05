#!/bin/bash

# ============================================================
# Function: 设置服务器自动备份
# ============================================================

WEBDAV_NAME=backup
WEBDAV_URL=
WEBDAV_USER=
WEBDAV_PASS=
RESTIC_PASS=
CUSTOM_REPO_PATH=
BACKUP_SCRIPT_URL=

RESTIC_BASE_DIR="/root/restic"
BACKUP_SCRIPT_PATH="$RESTIC_BASE_DIR/backup.sh"
RESTIC_LOG_PATH="/var/log/restic"

export RESTIC_REPOSITORY="rclone:$WEBDAV_NAME:$CUSTOM_REPO_PATH"
export RESTIC_PASSWORD_FILE="$RESTIC_BASE_DIR/restic_pass"


if [[ -z "$CUSTOM_REPO_PATH" ]]; then
    echo "请设置 CUSTOM_REPO_PATH 变量"
    exit 1
fi

# 配置 rclone
mkdir -p "/root/.config/rclone"

cat <<EOF > "/root/.config/rclone/rclone.conf"
[$WEBDAV_NAME]
type = webdav
url = $WEBDAV_URL
vendor = other
user = $WEBDAV_USER
pass = $WEBDAV_PASS

EOF

# 配置restic
mkdir -p $RESTIC_BASE_DIR
mkdir -p $RESTIC_LOG_PATH

echo $RESTIC_PASS > $RESTIC_PASSWORD_FILE
chmod 400 $RESTIC_PASSWORD_FILE

rclone listremotes && restic init

if [[ -n "$BACKUP_SCRIPT_URL" ]]; then
    curl --location --output $BACKUP_SCRIPT_PATH $BACKUP_SCRIPT_URL

    chmod 700 $BACKUP_SCRIPT_PATH

    echo "请修改 $BACKUP_SCRIPT_PATH 中的 CUSTOM_REPO_PATH 变量为 $CUSTOM_REPO_PATH"

    echo "添加以下cron job启用每日备份"
    echo "30 3 * * * $BACKUP_SCRIPT_PATH daily"
    echo "添加以下cron job启用每周备份"
    echo "0 4 * * 6 $BACKUP_SCRIPT_PATH weekly"
fi

echo "备份工作初始化成功"

