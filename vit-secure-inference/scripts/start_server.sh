#!/bin/bash
# Start vit_openai_server
# Usage: ./start_server.sh <path_to_vit_openai_server_package> [port]
#
# IMPORTANT for Cowork mode: If path contains spaces (e.g. iCloud Drive),
# bypass this script and call run_server.sh directly via osascript:
#   do shell script "nohup bash '/path with spaces/run_server.sh' > /tmp/vit_server.log 2>&1 & echo $!"

PACKAGE_DIR=$1
PORT=${2:-8222}

if [ -z "$PACKAGE_DIR" ]; then
    echo "Error: Please provide path to vit_openai_server_package"
    exit 1
fi

if [ ! -d "$PACKAGE_DIR" ]; then
    echo "Error: Directory not found: $PACKAGE_DIR"
    echo "Tip: Use osascript for paths with spaces"
    exit 1
fi

RUN_SCRIPT="$PACKAGE_DIR/run_server.sh"
if [ ! -f "$RUN_SCRIPT" ]; then
    echo "Error: run_server.sh not found in $PACKAGE_DIR"
    exit 1
fi

# Kill stale instances to avoid port conflicts
pkill -f vit_openai_server 2>/dev/null
sleep 2

echo "Starting vit_openai_server on port $PORT..."
nohup bash "$RUN_SCRIPT" > /tmp/vit_server.log 2>&1 &

echo "Waiting for server..."
for i in $(seq 1 30); do
    if curl -s --max-time 1 "http://localhost:$PORT/health" > /dev/null 2>&1; then
        echo "Server started on port $PORT"
        exit 0
    fi
    sleep 1
done

echo "Server may still be starting. Check: curl http://localhost:$PORT/health"
exit 0
