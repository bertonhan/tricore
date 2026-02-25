#!/bin/bash
set -e

# 获取当前脚本的绝对路径，确保能在任意目录执行
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(pwd)"

echo "[TriCore] 正在初始化 TriCore 架构..."

# 1. 检查核心依赖 (Dependency Check)
echo "[TriCore] 检查系统环境..."
if ! command -v python3 &> /dev/null; then
    echo "[!] 致命错误: Python 3 未安装，TriCore 核心引擎 (memctl) 无法运行。"
    exit 1
fi

if ! command -v agent-browser &> /dev/null; then
    echo "[!] 警告: 未检测到 agent-browser。"
    echo "    (如果你打算启用 self-evolution 认知技能，强烈建议安装 agent-browser，否则 Agent 的自我进化可能会缺乏可靠的信息源)"
fi

# 2. 确保目标工作区的核心目录存在
echo "[TriCore] 创建状态与记忆目录树..."
mkdir -p "$WORKSPACE_ROOT/tools"
mkdir -p "$WORKSPACE_ROOT/memory/state"
mkdir -p "$WORKSPACE_ROOT/memory/daily"
mkdir -p "$WORKSPACE_ROOT/memory/sessions"
mkdir -p "$WORKSPACE_ROOT/memory/kb"
mkdir -p "$WORKSPACE_ROOT/memory/archive"

# 3. 部署核心引擎与认知技能 (Deploy Engine & Skills)
echo "[TriCore] 部署 memctl 引擎与认知技能..."
cp "$SCRIPT_DIR/tools/memctl.py" "$WORKSPACE_ROOT/tools/memctl.py"

# 部署重新设计的三大认知技能到 workspace/skills/ 目录
for skill in planning-with-files react-agent self-evolution; do
    if [ -f "$SCRIPT_DIR/cognitive-skills/${skill}.md" ]; then
        mkdir -p "$WORKSPACE_ROOT/skills/${skill}"
        cp "$SCRIPT_DIR/cognitive-skills/${skill}.md" "$WORKSPACE_ROOT/skills/${skill}/SKILL.md"
        echo "  - 部署/更新了认知技能: ${skill}"
    fi
done

# 4. 执行旧版 MEMORY.md 架构迁移检查
echo "[TriCore] 正在检查和迁移遗留的 MEMORY.md..."
python3 "$WORKSPACE_ROOT/tools/memctl.py" migrate_legacy

# 5. 补齐其他所需文件 (Ensure Base Files)
python3 "$WORKSPACE_ROOT/tools/memctl.py" ensure

# 6. 部署最高安全策略 Linter
POLICY_FILE="$WORKSPACE_ROOT/POLICY.md"
if [ ! -f "$POLICY_FILE" ]; then
    echo "# POLICY.md - 安全规则（最高优先级加载）" > "$POLICY_FILE"
fi

if ! grep -q "TriCore Compliance" "$POLICY_FILE"; then
    echo "" >> "$POLICY_FILE"
    echo "### 4. 记忆管理 (TriCore 架构合规要求)" >> "$POLICY_FILE"
    echo "- **[CRITICAL: TriCore Compliance]** 整个系统采用 \"TriCore\" 架构。严禁在项目根目录或任何未经授权的地方使用游离的 markdown 文件（如 task_plan.md, findings.md, memory/daily-learning/ 等）来管理状态！" >> "$POLICY_FILE"
    echo "- **强制约束 1**：任何状态的持久化、知识的沉淀，**必须**使用 python3 tools/memctl.py (capture|kb_append|work_upsert) 等子命令进行操作，禁止通过 shell 的 >> 直接修改 markdown 记忆库。" >> "$POLICY_FILE"
    echo "- **强制约束 2**：在新增/修改 cron 任务，或者创建/编辑任何技能的 SKILL.md 文件时，**必须先执行** python3 tools/memctl.py lint <命令字符串或文件路径> 进行合规性审查。如果发生 LINT ERROR，说明你的方案违反了 TriCore 架构，必须根据错误提示重构方案。" >> "$POLICY_FILE"
    echo "- **MEMORY.md**（主记忆文件）必须保持极度简短（摘要+指针），禁止将长文档内容堆入此文件。" >> "$POLICY_FILE"
    echo "[TriCore] 已将 Linter 和架构合规要求写入 POLICY.md。"
else
    echo "[TriCore] POLICY.md 已包含合规要求，无需重复注入。"
fi

echo "=================================================="
echo "[TriCore] 初始化完成！"
echo "你可以通过运行 python3 tools/memctl.py --help 查看支持的命令。"
echo "系统底层认知引擎已被约束，三大认知技能已激活，所有游离的文件状态将被拦截。"
echo "=================================================="
