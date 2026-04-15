#!/bin/bash
# build_dmg.sh — 构建 VIT Secure Inference 安装 DMG
# 运行前确保项目根目录下存在：
#   - installer/安装 VIT Secure Inference.command
#   - installer/卸载.command
#   - vit_openai_server_package.zip  （约 900MB）
#   - vit-secure-inference.skill
#
# 输出：~/Desktop/VIT-Secure-Inference-Installer.dmg
# （输出到桌面，避免 iCloud Drive 同步干扰 DMG 构建）

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DMG_NAME="VIT-Secure-Inference-Installer"
# 输出到桌面，不放在 iCloud Drive 目录内
DMG_OUTPUT="$HOME/Desktop/${DMG_NAME}.dmg"
DMG_TMP="$HOME/Desktop/${DMG_NAME}-rw.dmg"

echo "================================================"
echo "  VIT Secure Inference — DMG 构建脚本"
echo "================================================"
echo ""

# ── 1. 检查必要文件 ───────────────────────────────
echo "🔍 检查必要文件..."

INSTALL_CMD="$SCRIPT_DIR/installer/安装 VIT Secure Inference.command"
UNINSTALL_CMD="$SCRIPT_DIR/installer/卸载.command"
ZIP_FILE="$SCRIPT_DIR/vit_openai_server_package.zip"
SKILL_FILE="$SCRIPT_DIR/vit-secure-inference.skill"

MISSING=0
[ -f "$INSTALL_CMD" ]   && echo "   ✅ 安装脚本" || { echo "   ❌ 缺少：installer/安装 VIT Secure Inference.command"; MISSING=$((MISSING+1)); }
[ -f "$UNINSTALL_CMD" ] && echo "   ✅ 卸载脚本" || { echo "   ❌ 缺少：installer/卸载.command"; MISSING=$((MISSING+1)); }
[ -f "$ZIP_FILE" ]      && echo "   ✅ 安装包（$(du -sh "$ZIP_FILE" | cut -f1)）" || { echo "   ❌ 缺少：vit_openai_server_package.zip"; MISSING=$((MISSING+1)); }
[ -f "$SKILL_FILE" ]    && echo "   ✅ Skill 文件（$(du -sh "$SKILL_FILE" | cut -f1)）" || { echo "   ❌ 缺少：vit-secure-inference.skill"; MISSING=$((MISSING+1)); }

if [ "$MISSING" -gt 0 ]; then
  echo ""
  echo "❌ 缺少 $MISSING 个文件，请补全后重试"
  exit 1
fi
echo ""

# ── 2. 清理旧文件 ─────────────────────────────────
rm -f "$DMG_OUTPUT" "$DMG_TMP"

# ── 3. 计算所需空间 ───────────────────────────────
ZIP_SIZE_MB=$(( $(du -sm "$ZIP_FILE" | cut -f1) + 50 ))
echo "💾 DMG 空间预留：${ZIP_SIZE_MB}MB"
echo ""

# ── 4. 创建空白 HFS+ 可读写 DMG ──────────────────
echo "📦 第1步：创建空白 HFS+ DMG..."
hdiutil create \
  -size "${ZIP_SIZE_MB}m" \
  -fs "HFS+" \
  -volname "VIT Secure Inference" \
  -layout GPTSPUD \
  "$DMG_TMP"

# ── 5. 挂载并写入文件 ────────────────────────────
echo "📂 第2步：挂载并写入文件..."
MOUNT_POINT="/Volumes/VIT Secure Inference"
hdiutil attach "$DMG_TMP" -readwrite -noverify -quiet

cp "$INSTALL_CMD"   "$MOUNT_POINT/安装 VIT Secure Inference.command"
cp "$UNINSTALL_CMD" "$MOUNT_POINT/卸载.command"
cp "$SKILL_FILE"    "$MOUNT_POINT/vit-secure-inference.skill"
echo "   ⏳ 复制 vit_openai_server_package.zip（约 850MB）..."
cp "$ZIP_FILE"      "$MOUNT_POINT/vit_openai_server_package.zip"

chmod +x "$MOUNT_POINT/安装 VIT Secure Inference.command"
chmod +x "$MOUNT_POINT/卸载.command"

echo "   ✅ 文件写入完成："
ls -lh "$MOUNT_POINT/"

# ── 6. 卸载 ──────────────────────────────────────
echo "🔒 第3步：卸载..."
hdiutil detach "$MOUNT_POINT" -quiet

# ── 7. 转换为只读压缩格式 ─────────────────────────
echo "🗜️  第4步：压缩转换为只读 DMG..."
hdiutil convert "$DMG_TMP" \
  -format UDZO \
  -imagekey zlib-level=6 \
  -o "$DMG_OUTPUT"
rm -f "$DMG_TMP"

# ── 8. 完成 ───────────────────────────────────────
DMG_SIZE_ACTUAL=$(du -sh "$DMG_OUTPUT" | cut -f1)
echo ""
echo "================================================"
echo "  🎉 构建成功！"
echo "================================================"
echo ""
echo "📦 输出文件：${DMG_NAME}.dmg（${DMG_SIZE_ACTUAL}）"
echo "   $DMG_OUTPUT"
echo ""
echo "📋 DMG 内容："
echo "   • 安装 VIT Secure Inference.command — 双击安装"
echo "   • 卸载.command                       — 双击卸载"
echo "   • vit_openai_server_package.zip      — 推理服务包"
echo "   • vit-secure-inference.skill         — Claude Skill"
echo ""
echo "🚀 发布方式：将 ${DMG_NAME}.dmg 分发给用户即可"
echo "   用户双击 DMG → 双击「安装 VIT Secure Inference.command」"
echo ""
