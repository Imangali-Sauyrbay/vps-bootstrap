#!/bin/bash
set -e

echo "📝 Generating .env file..."

cat <<EOF > .env
WG_HOST=${WG_HOST}
WG_PASSWORD_HASH=${WG_PASSWORD}
EOF

echo "✅ .env file created."