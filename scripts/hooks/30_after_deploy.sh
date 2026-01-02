#!/bin/bash
# [Hook] 30: After Docker Deploy
# Triggered: After 'docker compose up -d'.
# Use case: Healthchecks (curl localhost), cache warming, or success notifications.

echo "🪝 [Hook] After Deploy: Containers are up and running."