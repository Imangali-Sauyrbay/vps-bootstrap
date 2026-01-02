#!/bin/bash
set -e

BASE_DIR="/opt/vps-stack/scripts"
HOOKS_DIR="$BASE_DIR/hooks"

run_hook() {
    HOOK_NAME="$1"
    FILE="$HOOKS_DIR/$HOOK_NAME"
    if [ -f "$FILE" ]; then
        echo "⚡ Running Hook: $HOOK_NAME"

        chmod +x "$FILE"
        . "$FILE"
    else
        echo "⚪ Hook $HOOK_NAME not found (skipping)"
    fi
}

run_pipe() {
    PIPE_NAME="$1"
    shift 

    FILE="$BASE_DIR/$PIPE_NAME"
    
    if [ -f "$FILE" ]; then
        ARGS_LOG=""
        if [ -n "$*" ]; then ARGS_LOG="[args: $*]"; fi
        
        echo "🪈 Running pipe: $PIPE_NAME $ARGS_LOG"

        chmod +x "$FILE"

        "$FILE" "$@"
    else
        echo "⚪ Pipe $PIPE_NAME not found (CRITICAL)"
        exit 1
    fi
}

echo "🎬 Pipeline Started..."

# 1. Start hook
run_hook "00_before_all.sh"

# 2. Pre-Migrations (UFW, Docker)
echo "📦 Running Pre-Migrations..."
run_pipe "entrypoint.sh" "pre"
run_hook "10_after_pre_mig.sh"

# 3. Create Env
echo "📝 Creating Environment..."
run_pipe "create_env.sh"
run_hook "20_after_env.sh"

# 4. Docker Deploy
echo "🐳 Deploying Containers..."
run_pipe "docker_deploy.sh"
run_hook "30_after_deploy.sh"

# 5. Post-Migrations (SSH Port Rotation)
echo "🔒 Running Post-Migrations..."
run_pipe "entrypoint.sh" "post"

# 6. Final hook
run_hook "99_self_destruct.sh"

echo "✅ Pipeline Finished Successfully!"