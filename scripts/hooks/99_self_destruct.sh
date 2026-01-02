#!/bin/bash
# [Hook] 99: Total Cleanup
# Triggered: At the very end.
# ACTION: Deletes EVERYTHING in the project root EXCEPT the './volumes' directory.

echo "💣 [Hook] Initiating Total Self Destruct (preserving ./volumes)..."

TARGET_DIR="/opt/vps-stack"

nohup sh -c "
    sleep 10; 
    echo '🧹 Starting cleanup...';
    
    cd $TARGET_DIR || exit;
    
    find . -maxdepth 1 ! -name 'volumes' ! -name '.' -exec rm -rf {} +;
    
    echo '✨ Project root is clean. Only ./volumes survived.';
" >/dev/null 2>&1 &

echo "👋 Bye! Everything else will be gone in 10 seconds."