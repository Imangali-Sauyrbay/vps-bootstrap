#!/bin/bash
set -e

echo "🛠️ [001-PRE] Starting Base Setup..."

if ! command -v curl &> /dev/null; then
    echo "📦 Installing curl..."
    apt-get update
    apt-get install -y curl
fi

if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker..."
    curl -fsSL https://get.docker.com | sh
fi

if ! command -v ufw &> /dev/null; then
    apt-get update && apt-get install -y ufw
fi


echo "🛡️ Configuring Firewall..."

# First we disable ufw to configure it
ufw --force disable

# Then we are resetting and setting default configs
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

# SSH ports
ufw allow 22/tcp comment 'Temp Default SSH'
ufw allow "${SSH_PORT}/tcp" comment 'New SSH Port'

# Web, Wireguard & NPM
ufw allow 80/tcp   comment 'HTTP'
ufw allow 443/tcp  comment 'HTTPS'
ufw allow 81/tcp   comment 'NPM Admin'
ufw allow 51820/udp comment 'WireGuard VPN'

ufw --force enable

echo "✅ [001-PRE] Base Setup Complete. UFW is active."