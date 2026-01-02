#!/bin/bash
set -e

echo "🐳 Starting Docker deployment..."

docker compose pull

docker compose up -d --remove-orphans

docker image prune -f

echo "✅ Docker stack deployed!"