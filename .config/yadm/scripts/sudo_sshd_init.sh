#!/bin/bash

# ============================================================
# Function: 修改ssh默认端口；禁用ssh密码登录；
# Source: https://docs.docker.com/engine/install/debian
# ============================================================

# 生成10000到65535之间的随机端口号
RANDOM_PORT=$(shuf -i 10000-65535 -n 1)

# 修改sshd配置文件
SSHD_CONFIG="/etc/ssh/sshd_config"

# 备份当前的sshd配置文件
cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak"

# 修改端口号
sed -i "s/^#Port [0-9]*/Port $RANDOM_PORT/" "$SSHD_CONFIG"
sed -i "s/^Port [0-9]*/Port $RANDOM_PORT/" "$SSHD_CONFIG"

# 确保配置文件中包含禁用密码登录的设置
if grep -q "^PasswordAuthentication no" "$SSHD_CONFIG"; then
    echo "SSH密码登录默认为禁用"
elif grep -q "^PasswordAuthentication yes" "$SSHD_CONFIG"; then
    sed -i "s/^PasswordAuthentication yes/PasswordAuthentication no/" "$SSHD_CONFIG"
else
    echo "PasswordAuthentication no" >> "$SSHD_CONFIG"
fi

# 重启sshd服务以应用更改
systemctl restart sshd
systemctl status sshd

# 输出新的端口号
echo "sshd的端口已修改为: $RANDOM_PORT"
echo "SSH密码登录已禁用"

