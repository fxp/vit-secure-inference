#!/usr/bin/env python3
# VIT Secure Inference - Mac-side inference script template
# Fill in IMAGE_PATH, PROMPT, API_KEY before using.
# See SKILL.md Step 3 for how to write this to /tmp/vit_run.py via AppleScript.

import base64, json, sys, urllib.request
from pathlib import Path

IMAGE_PATH = "{IMAGE_PATH}"   # e.g. /Users/you/Downloads/image.png
PROMPT     = "{PROMPT}"
API_KEY    = "{API_KEY}"
PORT       = 8222
TIMEOUT    = 300  # 5 min: first run needs ~3 min for Metal GPU compilation

def get_mime(path):
    ext = Path(path).suffix.lower()
    return {".png": "image/png", ".jpg": "image/jpeg",
            ".jpeg": "image/jpeg", ".webp": "image/webp"
            }.get(ext, "image/jpeg")

with open(IMAGE_PATH, "rb") as f:
    img_b64 = base64.b64encode(f.read()).decode()

mime = get_mime(IMAGE_PATH)
payload = {
    "model": "glm-4.5v-ecc",
    "stream": False,
    "messages": [{"role": "user", "content": [
        {"type": "image_url", "image_url": {"url": "data:" + mime + ";base64," + img_b64}},
        {"type": "text", "text": PROMPT}
    ]}]
}

req = urllib.request.Request(
    "http://localhost:" + str(PORT) + "/v1/chat/completions",
    data=json.dumps(payload).encode(),
    headers={"Content-Type": "application/json",
             "Authorization": "Bearer " + API_KEY}
)

try:
    with urllib.request.urlopen(req, timeout=TIMEOUT) as resp:
        result = json.loads(resp.read())
        text = result["choices"][0]["message"]["content"]
        print(text)
        Path("/tmp/vit_final.txt").write_text(text)
except Exception as e:
    msg = "ERROR: " + str(e)
    print(msg, file=sys.stderr)
    Path("/tmp/vit_final.txt").write_text(msg)
    sys.exit(1)
