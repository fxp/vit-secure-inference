# VIT Secure Inference — Agent Skill

让 Claude 通过本地 ViT 编码器对图片/文档进行**隐私保护推理**。

原始文件在本地编码，仅压缩后的特征向量上传云端，GLM-4.5V 在云端完成分析。**原始数据不离开本地。**

---

## 前置条件

- macOS（Apple Silicon 或 Intel）
- `vit_openai_server_package/` 目录（含 900MB 模型文件）
- GLM-4.5V API Key（[申请地址](https://open.bigmodel.cn)）

---

## 安装 Skill

在 Claude Code 中执行：

```
/skills install vit-secure-inference.skill
```

或在 Claude Code 设置 → Skills → 安装本地 .skill 文件，选择 `vit-secure-inference.skill`。

---

## 使用方式

Skill 安装后，在对话中直接描述需求即可，**无需任何命令**。

Claude 会自动检查并启动本地推理服务，完成本地编码 → 云端分析的全流程。

---

## 示例 Prompt

### 📄 通用图片理解

```
帮我用本地推理分析这张图片：~/Desktop/screenshot.png
```

```
这张图里有什么内容？用隐私模式分析。图片路径：~/Downloads/diagram.jpg
```

---

### 🔤 文字提取 / OCR

```
提取这张截图里的所有文字，保持原始格式：~/Desktop/slide.png
```

```
这是一份扫描的表格，帮我把里面的数据提取出来：~/Documents/form_scan.jpg
```

---

### 📊 文档 / 报告分析

```
本地分析这份财报截图，列出核心财务数据（营收、利润、同比增长）：~/Downloads/earnings.png
```

```
这是一份合同第3页的截图，找出其中的关键条款和风险点：~/Desktop/contract_p3.png
```

```
帮我总结这篇论文的摘要和主要结论，图片在：~/Desktop/paper_abstract.png
```

---

### 🔍 多图对比

```
对比这两张产品设计图的差异，指出改动了哪些地方：
图1：~/Desktop/design_v1.png
图2：~/Desktop/design_v2.png
```

```
这两份合同条款截图有什么不同？重点关注付款和违约条款：
~/Documents/contract_a.png 和 ~/Documents/contract_b.png
```

---

### 🏥 专项领域

```
本地分析这张医学影像报告截图，提取检查项目和异常指标：~/Downloads/report.png
```

```
这是一张电路板照片，帮我识别主要元器件和布局：~/Desktop/pcb.jpg
```

---

## 首次使用

第一次使用时，Claude 会询问：

> 请告诉我 `vit_openai_server_package` 文件夹的路径

告知路径后，后续自动处理，无需重复配置。

---

## 支持的分析类型

| 说法 | 实际执行 |
|------|---------|
| "分析这张图片" | 通用内容理解 |
| "提取文字" / "OCR" | 文字识别与提取 |
| "总结这份文档" | 结构化摘要 |
| "对比这两张图" | 多图对比分析 |
| "分析这份财报/合同/论文" | 专项领域分析 |

---

## 分发给他人

分发 `VIT-Secure-Inference-Installer.dmg` 即可，内含全部所需文件。

**用户安装步骤：**

1. 双击 `VIT-Secure-Inference-Installer.dmg` 挂载磁盘
2. 双击「安装 VIT Secure Inference.command」→ Terminal 弹出，自动完成安装
3. 安装完成后，在 Claude Code 中安装 `vit-secure-inference.skill`（位于 DMG 内）

---

## 开发维护

```
vit-secure-inference.skill        # Skill 安装文件
vit-secure-inference/             # Skill 源码（开发迭代用）
vit_openai_server_package/        # 本地推理服务（运行时依赖）
vit_openai_server_package.zip     # 推理服务压缩包
installer/                        # 安装/卸载脚本源码
build_dmg.sh                      # 重新打包 DMG（输出到桌面）
```

重新构建 DMG：

```bash
bash build_dmg.sh
```
