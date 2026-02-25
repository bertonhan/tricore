---
name: trimemory-strong
version: "1.0.0"
description: TriMemory Strong 架构 - 为低资源服务器/Agent设计的确定性(Code-First)三层记忆与认知框架。包含底层的 memctl 引擎、系统策略约束(Linter)，以及全面重构的规划(Planning)、思考(ReAct)和进化(Self-Evolution)认知套件。
author: Berton Han
repository: https://github.com/bertonhan/trimemory-strong
allowed-tools:
  - default_api:exec
  - memory_search
  - memory_get
---

# TriMemory Strong 架构 (TriMemory-Strong)

> **为真正的自主 Agent 打造的“存储与计算解耦”底层基础设施。**

传统的 Agent 技能常常带有自己的“记忆包袱”（如在项目根目录生成 `task_plan.md`、`reflection.md` 或大量散乱的学习笔记），导致上下文孤岛和存储混乱。

**TriMemory Strong** 抛弃了基于 LLM 随意读写文本的范式，转而采用 **Code-First（代码优先）** 的确定性状态机：
1. **统一引擎**: 所有记忆的增删改查必须通过 `tools/memctl.py` 路由。
2. **三层存储**:
   - **Brief (Layer 1)**: `MEMORY.md` (系统级微型档案，仅存指针与法则)
   - **Living (Layer 2)**: `memory/state/WORKING.md` (正在运行的任务流/生命周期追踪)
   - **Stable/Volatile (Layer 3)**: `memory/kb/*.md` (沉淀知识库) & `memory/daily/*.md` (临时日志)
3. **检索优先**: 禁止直接用 `read` 工具灌入巨大文件，必须使用语义检索 `memory_search` 获取代码片段，极大节省 Token 并保护低资源环境。
4. **硬性约束 (Linting)**: 具备原生的 `memctl.py lint` 机制，任何破坏架构的 Cron 或 Skill 变更都会被 Linter 拦截报错。

---

## 📦 架构组件

本技能包包含了完整的系统组件：

1. **`tools/memctl.py`**: 核心引擎，包含 `ensure`, `capture`, `work_upsert`, `kb_append`, `lint` 等子命令。
2. **`install.sh`**: 一键安装脚本，自动初始化目录并注入 TriMemory 合规策略到 `POLICY.md`。
3. **`cognitive-skills/`**: 三大基于 TriMemory 重构的核心认知技能（作为模板供你的 Agent 加载）：
   - `planning-with-files.md`: 抛弃游离任务表的 PEP 规划系统。
   - `react-agent.md`: 基于 `WORKING.md` 落盘心智状态的 ReAct 循环。
   - `self-evolution.md`: 彻底剥离记忆管理，专注“代码级 CI/CD”的进化系统。

---

## 🚀 安装与初始化

在任何全新的 OpenClaw 环境中，执行以下命令即可部署 TriMemory Strong 架构：

```bash
# 赋予安装脚本权限并执行
bash ./install.sh
```

**`install.sh` 将会执行：**
1. 创建标准的 `memory/state/`, `memory/kb/`, `memory/daily/` 等目录。
2. 将 `tools/memctl.py` 复制到环境的 `tools/` 目录下。
3. 执行 `python3 tools/memctl.py ensure` 初始化 `WORKING.md` 和基础模板。
4. 在系统的 `POLICY.md` 中注入 `[CRITICAL: TriMemory Compliance]` 的最高优先级安全防线。

---

## 📚 核心命令速查 (Cheat Sheet)

在 Agent 工具流或内部子脚本中，请严格使用以下 API 存取状态：

**1. 记录临时日志 / 会话流水 (Volatile)**
```bash
python3 tools/memctl.py capture "测试了一下 API 连通性，成功了。"
```

**2. 建立/更新任务追踪 (Living State)**
```bash
python3 tools/memctl.py work_upsert --task_id "T-API-01" --title "修复 API" --goal "联通接口" --done_when "返回 200"
```

**3. 沉淀知识与经验 (Stable KB)**
```bash
python3 tools/memctl.py kb_append facts "该 API 只接受 JSON 格式。"
python3 tools/memctl.py kb_append playbooks "遇到该模块报错时，先检查 Redis 是否启动。"
```

**4. 检查脚本/Cron命令是否合规 (Linter)**
```bash
python3 tools/memctl.py lint "试图执行的命令或要检查的 .md 文件路径"
# 正常通过: Exit Code 0 (LINT PASS)
# 非法写入: Exit Code 1 (LINT ERROR)
```

---

## 🔄 Cron 任务适配要求

如果你要在 OpenClaw 配置定时任务（Cron），**请注意**：
所有的自动分析、每日总结、学习抓取任务，在生成成果后，**只能通过 `memctl.py` 落盘**。

例如，创建一个合规的学习总结任务：
```bash
openclaw cron add --name "daily-learning" --cron "0 22 * * *" --message '请使用 agent-browser 学习 Agent 最新论文，并使用 python3 tools/memctl.py kb_append facts "提炼的事实..." 记录。严禁创建独立 md。'
```

---
*Built with ❤️ for OpenClaw / Berton Han*
