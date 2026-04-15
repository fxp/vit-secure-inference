# VIT Secure Inference API Reference

## Service Architecture

```
Image/Document
    ↓ base64 encode (local)
vit_openai_server (local, port 8222)
    ↓ ViT encoding → compressed feature vectors
GLM-4.5V cloud model
    ↓ analysis result
User
```

**Privacy guarantee**: Original image bytes never leave the local machine. Only compressed feature vectors (~3x compression ratio) are transmitted.

## Server Setup

### Requirements
- macOS (ARM64 or x86_64)
- `vit_openai_server_package/` directory containing:
  - `bin/vit_openai_server` (executable)
  - `lib/` (dylib dependencies)
  - `vit_model/mmproj-GLM-4.5V-Q8_0.gguf` (900MB model)
  - `run_server.sh`

### Start server
```bash
cd vit_openai_server_package
./run_server.sh                                    # default port 8222
./run_server.sh vit_model/mmproj-GLM-4.5V-Q8_0.gguf 8080  # custom port
```

### Environment variables
```bash
export GZIP_LEVEL=1   # compression: 0=off, 1=fast(default), 9=max
```

### Health check
```bash
curl http://localhost:8222/health
curl http://localhost:8222/v1/models
```

## Chat Completions API

**Endpoint**: `POST http://localhost:{PORT}/v1/chat/completions`

**Headers**:
```
Content-Type: application/json
Authorization: Bearer {API_KEY}
```

**Request body**:
```json
{
  "model": "glm-4.5v-ecc",
  "stream": true,
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/jpeg;base64,{BASE64_IMAGE}"
          }
        },
        {
          "type": "text",
          "text": "Your analysis instruction here"
        }
      ]
    }
  ]
}
```

**Notes**:
- `model` must be `"glm-4.5v-ecc"` (not standard GLM model names)
- Supported image formats: JPEG, PNG, GIF, WebP
- `stream: true` recommended for long analyses (streaming response)
- Multiple images: add multiple `image_url` objects in `content` array

## Invoking via Bash (in Skill workflows)

### Quick one-liner (non-streaming)
```bash
IMAGE_B64=$(base64 -i image.jpg)
curl -s -X POST http://localhost:8222/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d "{\"model\":\"glm-4.5v-ecc\",\"stream\":false,\"messages\":[{\"role\":\"user\",\"content\":[{\"type\":\"image_url\",\"image_url\":{\"url\":\"data:image/jpeg;base64,${IMAGE_B64}\"}},{\"type\":\"text\",\"text\":\"YOUR_PROMPT\"}]}]}"
```

### Using the bundled script
```bash
./scripts/analyze_image.sh image.jpg "分析这张图片" API_KEY 8222
```

### Python (alternative)
```python
import base64, json, urllib.request

with open("image.jpg", "rb") as f:
    b64 = base64.b64encode(f.read()).decode()

payload = {
    "model": "glm-4.5v-ecc",
    "stream": False,
    "messages": [{
        "role": "user",
        "content": [
            {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{b64}"}},
            {"type": "text", "text": "YOUR_PROMPT"}
        ]
    }]
}

req = urllib.request.Request(
    "http://localhost:8222/v1/chat/completions",
    data=json.dumps(payload).encode(),
    headers={"Content-Type": "application/json", "Authorization": "Bearer YOUR_API_KEY"}
)
with urllib.request.urlopen(req) as resp:
    print(json.loads(resp.read())["choices"][0]["message"]["content"])
```

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `dyld: Library not loaded` | Missing dylib | `export DYLD_LIBRARY_PATH=./lib:$DYLD_LIBRARY_PATH` |
| `Library not loaded: ...openssl...` | No OpenSSL | `brew install openssl@3` |
| `Bad CPU type in executable` | Architecture mismatch | Use matching ARM64/x86_64 binary |
| Port in use | Another process on port | Change port or kill existing process |
| Connection refused | Server not started | Run `./run_server.sh` |

## Performance Logs

Server outputs performance metrics to stdout:
```
[VIT] Image processing time: 150 ms
[Compress] Feature compression time: 25 ms (level=1)
[Compress] Compressed data size: 1048576 bytes (1.00 MB)
```
