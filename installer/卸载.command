#!/bin/bash
# VIT Secure Inference — 卸载程序

INSTALL_DIR="$HOME/Library/Application Support/vit-secure-inference"

echo "================================================"
echo "  VIT Secure Inference 卸载程序"
echo "================================================"
echo ""

if [ ! -d "$INSTALL_DIR" ]; then
  echo "ℹ️  未检测到已安装的 VIT Secure Inference"
  echo "   路径不存在：$INSTALL_DIR"
  echo ""
  read -p "按 Enter 退出..." dummy
  exit 0
fi

echo "⚠️  即将卸载："
echo "   $INSTALL_DIR"
echo ""
read -p "确认卸载？(y/n): " choice
if [ "$choice" != "y" ] && [ "$choice" != "Y" ]; then
  echo "❌ 已取消卸载"
  read -p "按 Enter 退出..." dummy
  exit 0
fi

# 停止正在运行的服务
echo ""
echo "🛑 停止推理服务（如正在运行）..."
pkill -f vit_openai_server 2>/dev/null && echo "   ✅ 服务已停止" || echo "   ℹ️  服务未在运行"

# 删除安装目录
echo "🗑️  删除安装目录..."
rm -rf "$INSTALL_DIR"

if [ -d "$INSTALL_DIR" ]; then
  echo "❌ 删除失败，请手动删除："
  echo "   $INSTALL_DIR"
  read -p "按 Enter 退出..." dummy
  exit 1
fi

echo "✅ 卸载完成"
echo ""
echo "================================================"
echo "  VIT Secure Inference 已成功卸载"
echo "================================================"
echo ""
echo "📌 提示：Claude Skill 文件（vit-secure-inference.skill）"
echo "   需在 Claude Code 中手动卸载。"
echo ""
read -p "按 Enter 关闭此窗口..." dummy
