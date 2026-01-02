#!/bin/bash
# [Hook] 20: After .env Generation
# Triggered: After secrets have been injected into the .env file.
# Use case: Validating secrets presence, injecting dynamic build timestamps, or debugging (careful!).

echo "🪝 [Hook] After Env: Secrets injected successfully."

PROJECT_ROOT="/opt/vps-stack"

echo "🎨 Updating Landing Page..."

mkdir -p "$PROJECT_ROOT/volumes/landing"
cp -r "$PROJECT_ROOT/landing/"* "$PROJECT_ROOT/volumes/landing/"

echo "✅ Landing page updated from source."