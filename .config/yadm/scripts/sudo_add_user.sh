#!/bin/bash

# ============================================================
# Function: 添加sudo用户
# ============================================================

# 设置用户名密码
read -p "请输入用户名：" USERNAME
read -p -s "请输入 $USERNAME 的密码：" PASSWORD
read -p -s "请再次输入密码：" PASSWORD_CONFIRM

# 检查两次输入的密码是否一致
if [[ "$PASSWORD" != "$PASSWORD_CONFIRM" ]]; then
    echo "两次输入的密码不一致，请重新运行脚本"
    exit 1
fi

# 创建用户并设置密码
useradd -m "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd

# 将用户添加到sudo组
usermod -aG sudo "$USERNAME"

echo "用户 $USERNAME 创建成功，并已赋予sudo权限"
