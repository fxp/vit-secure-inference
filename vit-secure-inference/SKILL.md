---
name: vit-secure-inference
description: >
  Privacy-preserving local vision inference for image and document analysis using
  GLM-4.5V edge-cloud collaborative architecture. The local ViT encoder (300M params)
  processes images on-device and sends only compressed feature vectors (~3x compression)
  to the cloud model — original files never leave the local machine.

  Use this skill when the user wants to:
  - Analyze images or documents (PDFs, screenshots, charts, reports) with privacy protection
  - Perform OCR, document summarization, paper comparison, financial/legal/medical document analysis
  - Use phrases like "本地分析", "隐私推理", "文档解读", "analyze this image/document"
  - Start, check, or manage the local VIT inference server
  - Demonstrate the edge-cloud collaborative inference pipeline

  Requires: vit_openai_server_package installed locally (macOS only).
---

# VIT Secure Inference

Privacy-preserving image/document analysis via local ViT encoding + cloud GLM-4.5V inference.

## ⚠️ Cowork Environment Constraints (READ FIRST)

This skill runs in a **Linux VM** that communicates with the Mac host via `mcp__Control_your_Mac__osascript`.
Key rules that apply throughout:

1. **All Mac-side operations must use osascript** — bash/Python in the VM cannot reach the Mac directly (no network path to host).
2. **Images must be on the Mac filesystem** — images pasted into the conversation are not saved to disk. Always ask the user for the Mac file path before proceeding.
3. **Write Python scripts via AppleScript file writing** (not heredoc/echo) — shell heredocs break on quote escaping inside osascript strings. Use the `set fileRef` pattern (see Step 3).
4. **Use Python, not curl** — large base64 payloads (images are 1–10 MB) fail silently when passed through osascript shell strings. Python handles them reliably.
5. **Background long-running processes** — ViT encoding takes 60–180 seconds on first run (Metal GPU pipeline compilation). Use `nohup ... & echo $!`, then poll results separately.

---

## Core Workflow

```
1. Confirm image path  →  2. Check/start server  →  3. Write + run Python script  →  4. Poll result  →  5. Present
```

---

## Step 1: Confirm Prerequisites

**A. Image file path on Mac**
Images attached in Cowork conversation are NOT saved to disk. If the user shared an image in chat, ask:
> "这张图片保存在你 Mac 上的哪个路径？（例如 ~/Downloads/image.png）"

**B. Zhipu API key**
Check environment and common config locations first:
```applescript
do shell script "printenv | grep -i ZHIPU 2>/dev/null; cat ~/.zshrc 2>/dev/null | grep -i 'zhipu\\|api_key' | head -3"
```
If not found, ask the user for their Zhipu AI API key (format: `xxxxxxxx.xxxxxxxxxx`).

**C. Package location**
The user usually provides this. If not, scan:
```applescript
do shell script "find ~ -maxdepth 8 -name 'run_server.sh' -path '*/vit_openai_server_package/*' 2>/dev/null | head -3"
```
> Note: iCloud Drive paths contain spaces (e.g., `~/Library/Mobile Documents/...`). Always quote paths.

---

## Step 2: Check or Start Server

**Check if running:**
```applescript
do shell script "curl -s --connect-timeout 3 http://localhost:8222/health 2>&1"
```
Response `{"status":"healthy"...}` → skip to Step 3.

**Start the server** (handles paths with spaces):
```applescript
-- Step 2a: Kill any stale instances
do shell script "pkill -f vit_openai_server 2>/dev/null; sleep 2; echo cleared"

-- Step 2b: Start fresh (replace the path with the actual package path)
do shell script "nohup bash '/path/to/vit_openai_server_package/run_server.sh' > /tmp/vit_server.log 2>&1 & echo $!"

-- Step 2c: Wait and verify (run after 8 seconds)
do shell script "sleep 8 && curl -s http://localhost:8222/health"
```
Expected: `{"model_loaded":true,"status":"healthy"}`

---

## Step 3: Write the Inference Script to Mac

Use **AppleScript file writing** (not heredoc) to create the Python script at `/tmp/vit_run.py`.
This avoids quote-escaping problems that break osascript shell strings.

```applescript
set scriptContent to "import base64, json, sys, urllib.request
from pathlib import Path

IMAGE_PATH = '/path/to/image.png'
PROMPT     = 'YOUR PROMPT HERE'
API_KEY    = 'YOUR_ZHIPU_API_KEY'
PORT       = 8222
TIMEOUT    = 300

def get_mime(path):
    ext = Path(path).suffix.lower()
    return {'.png': 'image/png', '.jpg': 'image/jpeg',
            '.jpeg': 'image/jpeg', '.webp': 'image/webp'
            }.get(ext, 'image/jpeg')

with open(IMAGE_PATH, 'rb') as f:
    img_b64 = base64.b64encode(f.read()).decode()

mime = get_mime(IMAGE_PATH)
payload = {
    'model': 'glm-4.5v-ecc',
    'stream': False,
    'messages': [{'role': 'user', 'content': [
        {'type': 'image_url', 'image_url': {'url': 'data:' + mime + ';base64,' + img_b64}},
        {'type': 'text', 'text': PROMPT}
    ]}]
}

req = urllib.request.Request(
    'http://localhost:' + str(PORT) + '/v1/chat/completions',
    data=json.dumps(payload).encode(),
    headers={'Content-Type': 'application/json',
             'Authorization': 'Bearer ' + API_KEY}
)

try:
    with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
        result = json.loads(resp.read())
        text = result['choices'][0]['message']['content']
        print(text)
        Path('/tmp/vit_final.txt').write_text(text)
except Exception as e:
    msg = 'ERROR: ' + str(e)
    print(msg, file=sys.stderr)
    Path('/tmp/vit_final.txt').write_text(msg)
    sys.exit(1)
"

set fileRef to open for access POSIX file "/tmp/vit_run.py" with write permission
set eof fileRef to 0
write scriptContent to fileRef
close access fileRef
return "written"
```

Fill in: actual image path, prompt text, and API key **inside** the `scriptContent` string.

The reference template is in `scripts/mac_analyze.py`.

---

## Step 4: Run and Poll Results

**Launch in background:**
```applescript
do shell script "nohup python3 /tmp/vit_run.py > /tmp/vit_out.txt 2>/tmp/vit_err.txt & echo $!"
```

**⏱️ Timing expectations:**
- **First run**: 3–5 minutes (Metal GPU pipeline compilation + ViT encoding + cloud inference)
- **Subsequent runs**: 30–90 seconds (pipelines cached, only encoding + inference)

**Poll for completion:**
```applescript
-- Check if still running (returns 1 = running, 0 = done)
do shell script "ps aux | grep 'vit_run' | grep -v grep | wc -l"

-- Read result when done
do shell script "cat /tmp/vit_final.txt 2>&1"
do shell script "cat /tmp/vit_err.txt 2>&1"
```

**If polling shows still running after 3 minutes, check server log for progress:**
```applescript
do shell script "tail -5 /tmp/vit_server.log"
-- Look for: '[VIT] Image 1 processing time: XXXms' — confirms local encoding completed
-- Then: '[Compress] Image 1 compressed data size: X MB' — features ready to send
-- After these lines, the cloud response is imminent
```

---

## Step 5: Present Results

Format the result with timing data from the server log:
```applescript
do shell script "grep -E 'processing time|compression time|compressed data' /tmp/vit_server.log | tail -5"
```

Present with this structure:
```
## 🔍 分析结果（本地隐私推理）

[分析内容]

---
🔒 隐私保障：图片原文件全程留在本地，仅将 ViT 编码后的压缩特征向量传输至云端 GLM-4.5V。
⏱️ 耗时：本地 ViT 编码 Xs · 特征压缩 Xms · 云端推理 Xs
```

---

## Prompt Templates (quick reference)

See `references/prompt_templates.md` for full templates. Common tasks:
- **OCR / extract text** → T6
- **Document summary** → T7
- **Paper/contract comparison** → T1 (multi-image)
- **Financial report** → T4
- **Quick demo** → T-Quick

---

## Multi-image Analysis

Add multiple `image_url` entries in `content` to compare documents side-by-side:
```python
{'type': 'image_url', 'image_url': {'url': 'data:image/png;base64,' + img1_b64}},
{'type': 'image_url', 'image_url': {'url': 'data:image/png;base64,' + img2_b64}},
{'type': 'text', 'text': 'Compare these two documents...'}
```

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `TimeoutError` | ViT encoding in progress | Increase timeout to 300s; check server log for `[VIT] Image` line |
| `Error: Directory not found` | Path has spaces | Use `nohup bash '/path with spaces/run_server.sh'` directly |
| Empty result after wait | Process still running | Poll with `ps aux \| grep vit_run`; wait for `[VIT] Image 1 processing time` in server log |
| Multiple server instances | Repeated start attempts | `pkill -f vit_openai_server` before starting |
| curl silently fails | Base64 payload too large | Always use Python (not curl) for image inference |
| Chinese text garbled in SKILL.md | Encoding issue | Use base64 to write files: `echo '<b64>' \| base64 -d > file` |

---

## References

- **`references/api_reference.md`** — Full API docs, server setup, troubleshooting
- **`references/prompt_templates.md`** — 12+ ready-to-use analysis templates
- **`scripts/mac_analyze.py`** — Python inference script template (copy to /tmp/vit_run.py via AppleScript)
