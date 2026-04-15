#!/bin/bash
# Analyze an image using the local VIT inference server
# Usage: ./analyze_image.sh <image_path> <prompt> [api_key] [port] [stream]
#
# Arguments:
#   image_path  - Path to image file (jpg, png, etc.)
#   prompt      - Analysis instruction
#   api_key     - API key (default: reads from config.ini or uses placeholder)
#   port        - Server port (default: 8222)
#   stream      - Enable streaming: true/false (default: true)
#
# Example:
#   ./analyze_image.sh photo.jpg "提取图片中的所有文字"
#   ./analyze_image.sh report.png "总结这份报告的核心内容" "your-api-key" 8222

IMAGE_PATH="${1}"
PROMPT="${2}"
API_KEY="${3:-YOUR_API_KEY}"
PORT="${4:-8222}"
STREAM="${5:-true}"

if [ -z "$IMAGE_PATH" ] || [ -z "$PROMPT" ]; then
    echo "Usage: $0 <image_path> <prompt> [api_key] [port] [stream]"
    exit 1
fi

if [ ! -f "$IMAGE_PATH" ]; then
    echo "Error: Image file not found: $IMAGE_PATH"
    exit 1
fi

# Auto-detect image MIME type
case "${IMAGE_PATH##*.}" in
    jpg|jpeg) MIME="image/jpeg" ;;
    png)      MIME="image/png" ;;
    gif)      MIME="image/gif" ;;
    webp)     MIME="image/webp" ;;
    *)        MIME="image/jpeg" ;;
esac

# Base64 encode image
IMAGE_B64=$(base64 -i "$IMAGE_PATH" 2>/dev/null || base64 "$IMAGE_PATH")

# Build JSON payload
PAYLOAD=$(cat <<EOF
{
  "model": "glm-4.5v-ecc",
  "stream": ${STREAM},
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "image_url",
          "image_url": {
            "url": "data:${MIME};base64,${IMAGE_B64}"
          }
        },
        {
          "type": "text",
          "text": "${PROMPT}"
        }
      ]
    }
  ]
}
EOF
)

echo "🔍 Analyzing image: $IMAGE_PATH"
echo "📝 Prompt: $PROMPT"
echo "---"

curl -s -X POST "http://localhost:${PORT}/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${API_KEY}" \
    -d "$PAYLOAD"

echo ""
