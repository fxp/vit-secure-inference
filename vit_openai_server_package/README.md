# VIT 端云协同服务器

这是一个已打包好的 VIT 端云协同服务器，包含所有依赖和模型文件，可以直接在其他 macOS 电脑上运行。

## 文件结构

```
vit_openai_server_package/
├── bin/
│   └── vit_openai_server      # 主程序
├── lib/                        # 依赖库
│   ├── libllama.0.dylib
│   ├── libggml*.dylib
│   └── libspdlog*.dylib
├── vit_model/                  # 模型文件
│   └── mmproj-GLM-4.5V-Q8_0.gguf
├── run_server.sh              # 启动脚本（推荐使用）
└── README.md                  # 本文件
```

## 快速开始

### 1. 解压打包文件

```bash
tar -xzf vit_openai_server_macos_*.tar.gz
cd vit_openai_server_package
```

### 2. 启动服务器

**使用默认配置（推荐）**
```bash
./run_server.sh
```
- 使用内置模型：`vit_model/mmproj-GLM-4.5V-Q8_0.gguf`
- 使用默认端口：`8222`

**指定端口**
```bash
./run_server.sh vit_model/mmproj-GLM-4.5V-Q8_0.gguf 8080
```

### 3. 测试服务器

```bash
# 健康检查
curl http://localhost:8222/health

# API 调用（需要提供 API Key）
curl -X POST http://localhost:8222/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -d '{
    "messages": [{"role": "user", "content": "Hello"}],
    "stream": false
  }'
```

## 系统要求

- **操作系统**：macOS（ARM64 或 x86_64，取决于编译时的架构）
- **运行时依赖**：
  - 系统库：libz、libc++（系统自带，无需安装）
  - OpenSSL：如果系统没有自带，需要安装（见下方说明）

## 依赖安装

### OpenSSL（如果需要）

如果运行时提示找不到 OpenSSL 库，需要安装：

```bash
# 安装 Homebrew（如果还没有）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装 OpenSSL
brew install openssl@3
```

## 使用方法

### 启动服务器

**默认配置（推荐）**
```bash
./run_server.sh
```
使用内置模型，监听 8222 端口。

**指定端口**
```bash
./run_server.sh vit_model/mmproj-GLM-4.5V-Q8_0.gguf 8080
```

## 环境变量配置（可选）

### GZIP_LEVEL

设置 Gzip 压缩级别（0-9），影响压缩速度和压缩率：

```bash
export GZIP_LEVEL=1  # 最快压缩（默认）
./run_server.sh

export GZIP_LEVEL=9  # 最高压缩
./run_server.sh
```

**压缩级别说明**：
- `0`：无压缩（最快，文件最大）
- `1`：最快压缩（默认，推荐）
- `6`：平衡压缩
- `9`：最高压缩（最慢，文件最小）

## 故障排除

### 问题1: 库加载错误

**错误信息**：`dyld: Library not loaded: @rpath/...`

**解决方法**：
```bash
export DYLD_LIBRARY_PATH=./lib:$DYLD_LIBRARY_PATH
./bin/vit_openai_server <mmproj_path> <port>
```

### 问题2: OpenSSL 找不到

**错误信息**：`Library not loaded: /opt/homebrew/opt/openssl@3/lib/libssl.3.dylib`

**解决方法**：
1. 安装 OpenSSL：`brew install openssl@3`
2. 如果仍然失败，可能需要创建符号链接或设置环境变量

### 问题3: 架构不匹配

**错误信息**：`Bad CPU type in executable`

**说明**：打包的程序是针对特定架构编译的（ARM64 或 x86_64）。如果目标机器架构不匹配，需要重新编译。

**解决方法**：在目标机器上重新编译，或使用匹配架构的打包版本。

## 完整示例

```bash
# 1. 解压
tar -xzf vit_openai_server_macos_*.tar.gz
cd vit_openai_server_package

# 2. 启动服务器
./run_server.sh

# 3. 测试服务器
curl http://localhost:8222/health
```

就这么简单！服务器会自动使用内置的模型文件，监听 8222 端口。

## 注意事项

1. **架构兼容性**：打包的程序只能在相同架构的 macOS 上运行（ARM64 或 x86_64）
2. **系统库**：libz、libc++ 等系统库不需要打包，系统自带
3. **OpenSSL**：如果目标机器没有 OpenSSL，需要单独安装
4. **权限**：确保 `run_server.sh` 有执行权限：`chmod +x run_server.sh`
5. **端口**：确保指定的端口未被占用

## 性能监控

服务器会输出详细的性能日志：

```
[VIT] Image processing time: 150 ms
[Compress] Feature compression time: 25 ms (level=1)
[Compress] Compressed data size: 1048576 bytes (1.00 MB)
```

这些日志可以帮助你：
- 监控 VIT 处理性能
- 评估不同压缩级别的效果
- 优化服务器配置
