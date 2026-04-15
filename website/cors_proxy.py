#!/usr/bin/env python3
"""
VIT Secure Inference — CORS Bridge Proxy
=========================================
让浏览器页面（Cloudflare Pages）能够访问本地推理服务。

用法：
  python3 cors_proxy.py

默认：监听 localhost:8223，代理到 localhost:8222 (VIT 推理服务)

可选环境变量：
  PROXY_PORT   本代理监听端口（默认 8223）
  BACKEND_PORT 后端推理服务端口（默认 8222）
"""

import json
import os
import sys
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.error import URLError
from urllib.request import Request, urlopen

PROXY_PORT   = int(os.environ.get("PROXY_PORT",   8223))
BACKEND_PORT = int(os.environ.get("BACKEND_PORT", 8222))
BACKEND_BASE = f"http://127.0.0.1:{BACKEND_PORT}"

CORS_HEADERS = {
    "Access-Control-Allow-Origin":  "*",
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
    "Access-Control-Max-Age":       "86400",
}


class ProxyHandler(BaseHTTPRequestHandler):

    # ── Preflight ──────────────────────────────────────────────────────────
    def do_OPTIONS(self):
        self.send_response(204)
        for k, v in CORS_HEADERS.items():
            self.send_header(k, v)
        self.end_headers()

    # ── Pass-through ───────────────────────────────────────────────────────
    def do_GET(self):
        self._proxy("GET", body=None)

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body   = self.rfile.read(length) if length else None
        self._proxy("POST", body=body)

    def _proxy(self, method: str, body):
        url  = BACKEND_BASE + self.path
        hdrs = {
            k: v for k, v in self.headers.items()
            if k.lower() not in ("host", "content-length", "transfer-encoding")
        }
        req = Request(url, data=body, headers=hdrs, method=method)

        try:
            with urlopen(req, timeout=310) as resp:
                data = resp.read()
                self.send_response(resp.status)
                for k, v in resp.headers.items():
                    if k.lower() in ("transfer-encoding", "connection"):
                        continue
                    self.send_header(k, v)
                for k, v in CORS_HEADERS.items():
                    self.send_header(k, v)
                self.send_header("Content-Length", str(len(data)))
                self.end_headers()
                self.wfile.write(data)

        except URLError as e:
            msg = json.dumps({"error": str(e)}).encode()
            self.send_response(502)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(msg)))
            for k, v in CORS_HEADERS.items():
                self.send_header(k, v)
            self.end_headers()
            self.wfile.write(msg)

        except Exception as e:
            msg = json.dumps({"error": str(e)}).encode()
            self.send_response(500)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(msg)))
            for k, v in CORS_HEADERS.items():
                self.send_header(k, v)
            self.end_headers()
            self.wfile.write(msg)

    def log_message(self, fmt, *args):
        # 只打印非健康检查的请求
        if "/health" not in (args[0] if args else ""):
            print(f"[proxy] {self.address_string()} {fmt % args}")


def main():
    print(f"VIT Secure CORS Proxy")
    print(f"  listening : http://localhost:{PROXY_PORT}")
    print(f"  backend   : {BACKEND_BASE}")
    print(f"  Ctrl+C to stop\n")

    server = HTTPServer(("127.0.0.1", PROXY_PORT), ProxyHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nProxy stopped.")
        sys.exit(0)


if __name__ == "__main__":
    main()
