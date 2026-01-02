#!/bin/bash
set -e

echo "🔒 [001-POST] Finalizing Security & SSH..."

CONFIG="/etc/ssh/sshd_config"
BACKUP="/etc/ssh/sshd_config.bak_$(date +%F_%T)"

# 1. Меняем конфиг SSH (только если нужно)
if grep -q "Port ${SSH_PORT}" "$CONFIG"; then
    echo "👌 SSH Port is already set to ${SSH_PORT}."
    NEED_RESTART=false
else
    echo "🔄 Changing SSH Port to ${SSH_PORT}..."
    cp "$CONFIG" "$BACKUP"
    sed -i "s/^#\?Port 22.*/Port ${SSH_PORT}/" "$CONFIG"
    NEED_RESTART=true
fi

echo "⏳ Scheduling cleanup actions in 5 seconds..."

if [ "$NEED_RESTART" = true ]; then
    CMD="sleep 5 && systemctl restart ssh && ufw delete allow 22/tcp"
else
    CMD="sleep 5 && ufw delete allow 22/tcp"
fi

nohup sh -c "$CMD" >/dev/null 2>&1 &

echo "✅ [001-POST] Cleanup scheduled."