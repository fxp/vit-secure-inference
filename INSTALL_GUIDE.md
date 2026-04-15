# VIT OpenAI Server 一键安装包

## 🎯 设计目标

**避免在 macOS 上多次安全授权** - 通过一次性请求所有必要权限，实现"一键安装，零后续授权"。

## 📦 安装方式

### 方式 1: 一键安装脚本（推荐）

**特点**：
- ✅ 一次性请求所有权限
- ✅ 安装到系统目录
- ✅ 创建便捷命令
- ✅ 自动化配置

**使用方法**：
```bash
cd /path/to/ViT_secure_inference
chmod +x one_click_install.sh
./one_click_install.sh
```

**安装后的使用**：
```bash
# 启动服务器
vit-server start

# 查看状态
vit-server status

# 查看日志
vit-server logs

# 停止服务器
vit-server stop

# 重启服务器
vit-server restart
```

### 方式 2: PKG 安装包（高级用户）

**特点**：
- 📦 标准 macOS 安装包格式
- 🖥️  包含 App Bundle
- 📝 提供图形化安装向导
- 🔒 自动配置权限

**构建方法**：
```bash
chmod +x create_installer.sh
./create_installer.sh
```

**安装方法**：
```bash
# 双击 VIT_OpenAI_Server.pkg
# 或
sudo installer -pkg VIT_OpenAI_Server.pkg -target /
```

## 🔒 权限说明

### 需要的权限

| 权限 | 用途 | 授权时机 |
|--------|--------|----------|
| **文件系统访问** | 读取模型文件、写入日志 | 安装时一次 |
| **网络访问** | 监听端口、提供 API 服务 | 安装时一次 |
| **后台进程** | 在后台运行服务器 | 安装时一次 |

### 为什么避免多次授权？

**传统方式的问题**：
```
1. 安装程序 → 请求文件访问权限 ✅
2. 首次运行 → 请求网络权限 ❌
3. 后台运行 → 请求后台权限 ❌
4. 启动服务 → 再次请求权限 ❌
```

**我们的方案**：
```
1. 安装脚本 → 一次性请求所有权限 ✅
2. 后续使用 → 无需再次授权 ✅
```

## 📋 安装后的目录结构

```
/usr/local/
├── bin/
│   ├── vit-server              # 便捷命令（推荐）
│   ├── vit-server-uninstall    # 卸载脚本
│   └── vit_openai_server     # 主程序
├── lib/                     # 依赖库
│   ├── libllama.0.dylib
│   ├── libggml*.dylib
│   └── libspdlog*.dylib
└── share/
    └── vit-model/            # 模型文件
        └── mmproj-GLM-4.5V-Q8_0.gguf

~/Library/LaunchAgents/
└── com.vitserver.plist      # 自动启动配置
```

## 🚀 快速开始

### 1. 安装

```bash
cd /path/to/ViT_secure_inference
./one_click_install.sh
```

### 2. 启动服务器

```bash
# 使用默认配置（推荐）
vit-server start

# 或指定模型和端口
vit-server start /usr/local/share/vit-model/mmproj-GLM-4.5V-Q8_0.gguf 8080
```

### 3. 测试服务器

```bash
# 健康检查
curl http://localhost:8222/health

# API 调用
curl -X POST http://localhost:8222/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "messages": [{"role": "user", "content": "Hello"}],
    "stream": false
  }'
```

## 📊 管理命令

### vit-server 命令

```bash
# 启动服务器
vit-server start [模型路径] [端口]

# 停止服务器
vit-server stop

# 重启服务器
vit-server restart [模型路径] [端口]

# 查看状态
vit-server status

# 查看日志（实时）
vit-server logs
```

### 示例输出

```
$ vit-server start
========================================
🚀 启动 VIT Server
========================================
📦 模型: /usr/local/share/vit-model/mmproj-GLM-4.5V-Q8_0.gguf
🌐 端口: 8222
📚 库路径: /usr/local/lib
========================================

✅ VIT Server 已启动
   PID: 12345
   日志: /tmp/vit-server.log

💡 提示: 使用 'vit-server status' 查看状态
```

```
$ vit-server status
✅ VIT Server 正在运行

📊 进程信息:
user  12345  1.2  2.3  234567  89012  pts/0  S+   0:00.12 vit_openai_server

📋 网络监听:
vit_opena 12345  user  10u  IPv4 0x12345678      0t0  TCP  *:8222 (LISTEN)
```

## 🗑️  卸载

### 方法 1: 使用卸载脚本

```bash
vit-server-uninstall
```

### 方法 2: 手动卸载

```bash
# 停止服务器
vit-server stop

# 删除文件
sudo rm -rf /usr/local/bin/vit-server
sudo rm -rf /usr/local/lib/libllama*
sudo rm -rf /usr/local/lib/libggml*
sudo rm -rf /usr/local/share/vit-model
rm ~/Library/LaunchAgents/com.vitserver.plist
```

## 🔧 故障排除

### 问题 1: 库加载错误

**错误信息**：
```
dyld: Library not loaded: @rpath/libggml.0.dylib
```

**解决方法**：
```bash
# 检查库是否安装
ls -la /usr/local/lib/libggml*

# 如果缺失，重新运行安装脚本
./one_click_install.sh
```

### 问题 2: 端口已被占用

**错误信息**：
```
Error: Address already in use
```

**解决方法**：
```bash
# 查找占用端口的进程
lsof -i :8222

# 停止该进程或使用其他端口
vit-server start /usr/local/share/vit-model/mmproj-GLM-4.5V-Q8_0.gguf 8080
```

### 问题 3: 权限被拒绝

**错误信息**：
```
Permission denied
```

**解决方法**：
```bash
# 确保脚本有执行权限
chmod +x one_click_install.sh

# 以 root 身份运行
sudo ./one_click_install.sh
```

## 📝 高级配置

### 修改默认端口

编辑 `/usr/local/bin/vit-server`，修改 `DEFAULT_PORT` 变量。

### 添加自动启动

LaunchAgent 已自动配置，服务器会在系统启动时自动启动。

如需禁用：
```bash
launchctl unload ~/Library/LaunchAgents/com.vitserver.plist
```

### 自定义日志位置

编辑 `/usr/local/bin/vit-server`，修改日志路径。

## 🎯 对比：传统方式 vs 一键安装

### 传统方式

| 步骤 | 需要授权 |
|------|----------|
| 解压文件 | ❌ |
| 运行脚本 | ✅ (第1次) |
| 首次启动 | ✅ (第2次) |
| 网络监听 | ✅ (第3次) |
| 后台运行 | ✅ (第4次) |

### 一键安装方式

| 步骤 | 需要授权 |
|------|----------|
| 运行安装脚本 | ✅ (仅1次) |
| 后续所有操作 | ❌ 无需授权 |

## 📚 相关文档

- [VIT OpenAI Server README](./vit_openai_server_package/README.md)
- [API 文档](./api_documentation.md)
- [模型说明](./model_specifications.md)

## 🤝 贡献

如需改进此安装脚本，请提交 Issue 或 Pull Request。

## 📄 许可证

与 VIT OpenAI Server 项目相同。

---

**总结**: 本安装包通过一次性授权机制，避免了 macOS 上的多次安全授权问题，提供真正的"一键安装，零后续授权"体验。
