#!/bin/bash
# VIT Secure Inference — 安装程序
# 双击此文件即可开始安装

INSTALL_DIR="$HOME/Library/Application Support/vit-secure-inference"
PACKAGE_NAME="vit_openai_server_package"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZIP_FILE="$SCRIPT_DIR/vit_openai_server_package.zip"

echo "================================================"
echo "  VIT Secure Inference 安装程序"
echo "================================================"
echo ""

# ── 1. 检查 zip 文件是否存在 ─────────────────────
if [ ! -f "$ZIP_FILE" ]; then
  echo "❌ 错误：找不到安装包 vit_openai_server_package.zip"
  echo "   请确保此脚本与 vit_openai_server_package.zip 在同一文件夹"
  echo ""
  read -p "按 Enter 退出..." dummy
  exit 1
fi

# ── 2. 检测架构 ───────────────────────────────────
ARCH=$(uname -m)
if [ "$ARCH" != "arm64" ] && [ "$ARCH" != "x86_64" ]; then
  echo "❌ 不支持的系统架构：$ARCH"
  echo "   本程序仅支持 macOS (Apple Silicon 或 Intel)"
  read -p "按 Enter 退出..." dummy
  exit 1
fi
echo "✅ 系统架构：$ARCH"

# ── 3. 如已安装，询问是否覆盖 ────────────────────
if [ -d "$INSTALL_DIR/$PACKAGE_NAME" ]; then
  echo ""
  echo "⚠️  检测到已有安装："
  echo "   $INSTALL_DIR/$PACKAGE_NAME"
  echo ""
  read -p "是否覆盖重新安装？(y/n): " choice
  if [ "$choice" != "y" ] && [ "$choice" != "Y" ]; then
    echo "❌ 已取消安装"
    read -p "按 Enter 退出..." dummy
    exit 0
  fi
  echo "🗑️  移除旧版本..."
  rm -rf "$INSTALL_DIR/$PACKAGE_NAME"
fi

# ── 4. 创建安装目录 ───────────────────────────────
echo ""
echo "📁 创建安装目录..."
mkdir -p "$INSTALL_DIR"

# ── 5. 解压安装包 ─────────────────────────────────
echo "📦 解压安装包（约 900MB，请稍候）..."
unzip -q "$ZIP_FILE" -d "$INSTALL_DIR"

if [ ! -d "$INSTALL_DIR/$PACKAGE_NAME" ]; then
  echo "❌ 解压失败，请检查安装包是否完整"
  read -p "按 Enter 退出..." dummy
  exit 1
fi
echo "✅ 解压完成"

# ── 6. 移除 macOS 隔离属性 ───────────────────────
echo "🔓 移除系统安全隔离标记..."
xattr -cr "$INSTALL_DIR/$PACKAGE_NAME" 2>/dev/null || true
echo "✅ 完成"

# ── 7. Ad-hoc 签名（避免 Gatekeeper 拦截）────────
echo "🔐 进行本地代码签名..."
BIN="$INSTALL_DIR/$PACKAGE_NAME/bin/vit_openai_server"
LIB_DIR="$INSTALL_DIR/$PACKAGE_NAME/lib"

chmod +x "$BIN"
codesign --force --deep --sign - "$BIN" 2>/dev/null && echo "   ✅ 主程序签名完成" || echo "   ⚠️  主程序签名跳过（不影响运行）"

for dylib in "$LIB_DIR"/*.dylib; do
  [ -f "$dylib" ] || continue
  codesign --force --sign - "$dylib" 2>/dev/null || true
done
echo "   ✅ 动态库签名完成"

# ── 8. 设置执行权限 ───────────────────────────────
chmod +x "$INSTALL_DIR/$PACKAGE_NAME/run_server.sh" 2>/dev/null || true
chmod +x "$INSTALL_DIR/$PACKAGE_NAME/api_call_curl.sh" 2>/dev/null || true

# ── 9. 验证安装 ───────────────────────────────────
echo ""
echo "🔍 验证安装..."
ERRORS=0

[ -f "$BIN" ]                                                                    && echo "   ✅ 主程序" || { echo "   ❌ 主程序缺失"; ERRORS=$((ERRORS+1)); }
[ -f "$INSTALL_DIR/$PACKAGE_NAME/run_server.sh" ]                               && echo "   ✅ 启动脚本" || { echo "   ❌ 启动脚本缺失"; ERRORS=$((ERRORS+1)); }
[ -f "$INSTALL_DIR/$PACKAGE_NAME/vit_model/mmproj-GLM-4.5V-Q8_0.gguf" ]       && echo "   ✅ 模型文件（900MB）" || { echo "   ❌ 模型文件缺失"; ERRORS=$((ERRORS+1)); }
[ "$(ls "$LIB_DIR"/*.dylib 2>/dev/null | wc -l)" -gt 0 ]                       && echo "   ✅ 动态库" || { echo "   ❌ 动态库缺失"; ERRORS=$((ERRORS+1)); }

if [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo "❌ 安装不完整，请重新下载安装包后再试"
  read -p "按 Enter 退出..." dummy
  exit 1
fi

# ── 10. 完成 ──────────────────────────────────────
echo ""
echo "================================================"
echo "  🎉 安装成功！"
echo "================================================"
echo ""
echo "📍 安装位置："
echo "   $INSTALL_DIR/$PACKAGE_NAME"
echo ""
echo "🔌 Claude Skill 配合使用说明："
echo "   1. 在 Claude Code 中安装 vit-secure-inference.skill"
echo "   2. 对话中说「帮我分析这张图片」并附上图片"
echo "   3. Claude 会自动发现并启动推理服务"
echo ""
echo "📖 手动启动服务（如需）："
echo "   bash \"$INSTALL_DIR/$PACKAGE_NAME/run_server.sh\""
echo ""
read -p "按 Enter 关闭此窗口..." dummy
