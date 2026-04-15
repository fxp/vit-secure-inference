#!/bin/bash
# Check if VIT inference services are running
# Usage: ./check_services.sh [--port PORT]
# Default port: 8222

PORT=${1:-8222}

echo "=== VIT Secure Inference Service Status ==="

# Check vit_openai_server
if curl -s --max-time 2 "http://localhost:${PORT}/health" > /dev/null 2>&1; then
    echo "✅ vit_openai_server: RUNNING (port ${PORT})"
    VIT_RUNNING=true
else
    echo "❌ vit_openai_server: NOT RUNNING (port ${PORT})"
    VIT_RUNNING=false
fi

# Check /v1/models endpoint
if curl -s --max-time 2 "http://localhost:${PORT}/v1/models" > /dev/null 2>&1; then
    echo "✅ OpenAI-compatible API: AVAILABLE"
else
    echo "⚠️  OpenAI-compatible API: NOT AVAILABLE"
fi

if [ "$VIT_RUNNING" = false ]; then
    echo ""
    echo "To start the server, run: ./start_server.sh <path_to_vit_openai_server_package>"
    exit 1
fi

exit 0
