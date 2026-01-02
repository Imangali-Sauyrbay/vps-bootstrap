#!/bin/bash
set -e

echo "📝 Generating .env file..."

if ! command -v htpasswd &> /dev/null; then
    echo "📦 Installing apache2-utils (for bcrypt)..."
    apt-get update >/dev/null
    apt-get install -y apache2-utils >/dev/null
fi

HASH=$(htpasswd -nbBC 10 "dummy" "${WG_PASSWORD}" | cut -d ":" -f 2)

if [ -z "$HASH" ]; then
    echo "❌ Error: Failed to generate password hash!"
    exit 1
fi

echo "   Hash generated: [HIDDEN]"

cat <<EOF > .env
WG_HOST=${WG_HOST}
WG_PASSWORD_HASH='${HASH}'
EOF

echo "✅ .env file created."