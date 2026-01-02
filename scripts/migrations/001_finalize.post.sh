#!/bin/bash
set -e

echo "🔒 [001-POST] Finalizing Security & SSH..."

CONFIG="/etc/ssh/sshd_config"
BACKUP="/etc/ssh/sshd_config.bak_$(date +%F_%T)"

if grep -q "Port ${SSH_PORT}" "$CONFIG"; then
    echo "👌 SSH Port is already set to ${SSH_PORT}."
else
    echo "🔄 Changing SSH Port to ${SSH_PORT}..."
    cp "$CONFIG" "$BACKUP"
    sed -i "s/^#\?Port 22.*/Port ${SSH_PORT}/" "$CONFIG"
    

    echo "⏳ Scheduling SSH restart & Cleanup in 5 seconds..."
    
    nohup sh -c "sleep 5 && systemctl restart ssh && ufw delete allow 22/tcp" >/dev/null 2>&1 &
fi

echo "✅ [001-POST] Configuration queued. Bye bye port 22!"