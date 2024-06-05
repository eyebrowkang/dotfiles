#!/bin/bash

# ============================================================
# Function: 安装docker
# Source: https://docs.docker.com/engine/install/debian
# ============================================================

# uninstall docker
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do apt remove $pkg; done
# Add Docker's official GPG key:
apt update
apt install -y ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# add user to docker group
read -p "请输入用户名：" ROOTLESS_USER

if [[ -n "$ROOTLESS_USER" ]]; then
    usermod -aG docker $ROOTLESS_USER
    echo "用户 $ROOTLESS_USER 已添加至docker group"
fi

