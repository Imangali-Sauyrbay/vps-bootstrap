#!/bin/bash
set -e

MODE="${1:-pre}"
BASE_DIR="/opt/vps-stack"

MIGRATIONS_DIR="$BASE_DIR/scripts/migrations"

VOLUMES_DIR="$BASE_DIR/volumes"
HISTORY_FILE="$VOLUMES_DIR/.migration_history"

mkdir -p "$VOLUMES_DIR"
touch "$HISTORY_FILE"

echo "🚀 Starting Infrastructure Migrations [MODE: $MODE]..."

for script in $(find "$MIGRATIONS_DIR" -maxdepth 1 -name "*.sh" | sort); do
    filename=$(basename "$script")
    
    is_post_script=false
    if [[ "$filename" == *".post.sh" ]]; then
        is_post_script=true
    fi

    should_run=false
    if [[ "$MODE" == "pre" && "$is_post_script" == "false" ]]; then
        should_run=true
    elif [[ "$MODE" == "post" && "$is_post_script" == "true" ]]; then
        should_run=true
    fi

    if [[ "$should_run" == "true" ]]; then
        if grep -Fxq "$filename" "$HISTORY_FILE"; then
            echo "⏭️  Skipping $filename (Already executed)"
        else
            echo "▶️  Executing $filename..."
            
            chmod +x "$script"
            /bin/bash "$script"
            
            echo "$filename" >> "$HISTORY_FILE"
            echo "✅ Finished $filename"
        fi
    fi
done

echo "🎉 Migrations for [$MODE] phase completed."