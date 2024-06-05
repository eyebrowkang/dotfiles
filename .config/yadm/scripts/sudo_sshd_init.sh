#!/bin/bash

# ============================================================
# Function:
#   1. 修改ssh默认端口
#   2. 禁用ssh密码登录
#   3. 禁用Root登录
#   4. 配置fail2ban
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

# 禁用密码登录
if grep -q "^PasswordAuthentication no" "$SSHD_CONFIG"; then
    echo "SSH密码登录默认为禁用"
elif grep -q "^PasswordAuthentication yes" "$SSHD_CONFIG"; then
    sed -i "s/^PasswordAuthentication yes/PasswordAuthentication no/" "$SSHD_CONFIG"
else
    echo "PasswordAuthentication no" >> "$SSHD_CONFIG"
fi

# 禁用Root登录
if grep -q "^PermitRootLogin no" "$SSHD_CONFIG"; then
    echo "SSH Root登录默认为禁用"
elif grep -q "^PermitRootLogin yes" "$SSHD_CONFIG"; then
    sed -i "s/^PermitRootLogin yes/PermitRootLogin no/" "$SSHD_CONFIG"
else
    echo "PermitRootLogin no" >> "$SSHD_CONFIG"
fi

# 重启sshd服务以应用更改
systemctl restart sshd
systemctl status sshd

# 输出新的端口号
echo "sshd的端口已修改为: $RANDOM_PORT"
echo "SSH密码登录已禁用"

echo "===== 开始配置fail2ban ====="
# Function to install, configure, and start Fail2ban
setup_fail2ban() {
    local ssh_port=$1

    if [[ -z "$ssh_port" ]]; then
        echo "Usage: setup_fail2ban <ssh_port>"
        return 1
    fi

    echo "Installing Fail2ban..."

    echo "Configuring Fail2ban for SSH on port $ssh_port..."

    local jail_local="/etc/fail2ban/jail.local"
    local temp_file="/tmp/jail.local.tmp"

    cp /etc/fail2ban/jail.conf "$jail_local"

    # Check if jail.local exists and if it has an [sshd] section
    if grep -q "^\[sshd\]" $jail_local; then
                # Modify existing [sshd] section
        awk -v ssh_port="$ssh_port" '
        BEGIN { in_sshd=0; bantime_set=0; findtime_set=0; maxretry_set=0 }
        /^\[sshd\]/ { in_sshd=1; print; next }
        /^\[/ { if (in_sshd) {
                    if (!bantime_set) print "bantime = 3600";
                    if (!findtime_set) print "findtime = 600";
                    if (!maxretry_set) print "maxretry = 5";
                }
                in_sshd=0 }
        in_sshd && /^port/ { print "port = " ssh_port; next }
        in_sshd && /^logpath/ { print "logpath = %(sshd_log)s"; next }
        in_sshd && /^backend/ { print "backend = systemd"; next }
        in_sshd && /^bantime/ { print "bantime = 3600"; bantime_set=1; next }
        in_sshd && /^findtime/ { print "findtime = 600"; findtime_set=1; next }
        in_sshd && /^maxretry/ { print "maxretry = 3"; maxretry_set=1; next }
        { print }
        END {
            if (in_sshd) {
                if (!bantime_set) print "bantime = 3600";
                if (!findtime_set) print "findtime = 600";
                if (!maxretry_set) print "maxretry = 3";
            }
        }
        ' $jail_local > $temp_file
    else
        # Add new [sshd] section
        cat <<EOL >> $jail_local
[sshd]
enable = true
port = $ssh_port
logpath = %(sshd_log)s
backend = systemd
bantime = 3600
findtime = 600
maxretry = 3
EOL
    fi

    # If a temporary file was created, move it to replace the original
    if [[ -f $temp_file ]]; then
        mv $temp_file $jail_local
    fi

    echo "Restarting Fail2ban service..."
    systemctl restart fail2ban

    echo "Enabling Fail2ban to start on boot..."
    systemctl enable fail2ban

    echo "Fail2ban setup is complete. Status:"
    systemctl status fail2ban
    fail2ban-client status sshd
}

# Call the function with the first argument passed to the script
setup_fail2ban $RANDOM_PORT

