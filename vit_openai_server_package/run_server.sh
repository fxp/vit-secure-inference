#!/bin/bash

# VIT OpenAI Server 启动脚本
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN="${SCRIPT_DIR}/bin/vit_openai_server"
DEFAULT_MODEL="${SCRIPT_DIR}/vit_model/mmproj-GLM-4.5V-Q8_0.gguf"
DEFAULT_PORT=8222

# 设置库路径
export DYLD_LIBRARY_PATH="${SCRIPT_DIR}/lib:${DYLD_LIBRARY_PATH}"

# 解析参数
if [ $# -eq 0 ]; then
    # 无参数：使用默认模型和端口
    if [ ! -f "${DEFAULT_MODEL}" ]; then
        echo "错误: 找不到默认模型文件 ${DEFAULT_MODEL}"
        echo ""
        echo "请指定模型路径："
        echo "  $0 <mmproj_path> [port]"
        echo ""
        echo "或使用默认端口："
        echo "  $0 <mmproj_path>"
        exit 1
    fi
    MODEL="${DEFAULT_MODEL}"
    PORT="${DEFAULT_PORT}"
elif [ $# -eq 1 ]; then
    # 一个参数：作为模型路径，使用默认端口
    MODEL="$1"
    PORT="${DEFAULT_PORT}"
else
    # 两个参数：模型路径和端口
    MODEL="$1"
    PORT="$2"
fi

# 检查模型文件是否存在
if [ ! -f "${MODEL}" ]; then
    echo "错误: 找不到模型文件 ${MODEL}"
    exit 1
fi

echo "启动 VIT OpenAI Server..."
echo "模型: ${MODEL}"
echo "端口: ${PORT}"
echo ""

# 运行服务器
exec "${BIN}" "${MODEL}" "${PORT}"
