# Prompt Templates for VIT Secure Inference

Use these templates as the `text` field in API requests. Replace `[placeholder]` variables as needed.

## Quick Selection Guide

| Use Case | Template |
|----------|----------|
| First demo / general analysis | T1 - Paper Comparison |
| Extract text from image | T6 - OCR |
| Summarize any document | T7 - Document Summary |
| Financial reports | T4 - Financial Analysis |
| Legal contracts | T5 - Contract Comparison |
| Medical documents | T8 - Medical Report |
| Simple 30-second demo | T-Quick |

---

## T1 - Paper Comparison (Recommended for demos)
```
结合这两篇论文的图表和内容，完成以下任务：

1. 对比分析两篇论文的架构设计异同
2. 提取两篇论文中的关键性能对比数据，生成对比表格
3. 基于当前研究趋势，提出 3 个改进方向

要求：
- 嵌入论文原图（架构图、性能曲线图）
- 生成专业的对比分析表格
- 输出格式：图文并茂的 Markdown 报告
```

## T2 - Literature Review (Multiple papers)
```
请阅读这几篇关于 [主题] 的论文，完成文献综述：

1. 总结每篇论文的核心贡献和创新点
2. 对比不同方法的技术路线差异
3. 提取关键实验数据，生成性能对比表
4. 分析该领域的研究趋势和未来方向

输出：
- 各论文摘要（每篇 100 字）
- 技术对比分析表
- 关键图表
- 研究展望（500 字）
```

## T3 - Architecture Analysis
```
分析这份系统架构设计文档（包含架构图）：

1. 识别文档中的所有架构图，逐一解释
2. 提取技术栈选型及理由
3. 分析系统模块划分和接口设计
4. 指出潜在的性能瓶颈或风险点

输出要求：
- 嵌入所有架构图并添加说明
- 给出优化建议
```

## T4 - Financial Report Analysis
```
分析这份财报，完成以下任务：

1. 提取核心财务指标：营收、净利润、毛利率、同比/环比增长率、现金流
2. 生成关键指标对比表格
3. 识别财报中的关键图表并说明其含义
4. 给出 200 字投资摘要

注意：确保数据准确，标注数据来源（第几页）
```

## T5 - Contract Comparison
```
对比这两份合同的关键条款差异：

分析维度：
1. 付款条款（金额、时间、方式）
2. 违约责任条款
3. 知识产权归属
4. 保密协议内容
5. 争议解决机制

输出格式：
- 差异对比表（双栏格式）
- 风险点标注（用⚠️标记）
- 建议修订的条款（如有）
```

## T6 - OCR / Text Extraction
```
提取这张图片中的所有文字内容，保持原有格式和结构。
如果有表格，以 Markdown 表格格式输出。
如果有多个区域，按区域分别提取并标注位置。
```

## T7 - Document Summary
```
总结这份文档：

1. 执行摘要（300字）
2. 主要内容要点（5-7条）
3. 关键数据和图表提取
4. 行动建议（如有）

特别要求：
- 生成一页纸精华版
- 标注重要信息来源页码
```

## T8 - Medical Report (Privacy-sensitive)
```
分析这份医学影像/检验报告：

1. 提取关键检查指标及其数值
2. 标注异常指标（用⚠️标记）
3. 与正常参考值对比
4. 生成结构化报告摘要

注意：本文档在本地处理，原始文件不上传云端。
```

## T-Quick - 30-second Simple Demo
```
用 3 句话总结这张图片/文档的核心内容。
```

## T-Critical - Critical Analysis
```
批判性地分析这篇文档：

1. 验证文中数据的自洽性
2. 指出论证逻辑的潜在缺陷
3. 质疑核心观点并提供反例
4. 提出改进建议

要求：每个批判点需引用文档具体内容佐证
```

---

## Output Quality Tips

**明确格式**:
```
输出格式：
## 1. [章节名]（约 100 字）
## 2. 对比表格
## 3. 图表（嵌入原图）
```

**要求引用来源**:
```
在每个关键数据后添加 [来源：P页码]
```

**控制长度**:
```
总报告长度：1500-2000 字
每个章节：150-200 字
```
