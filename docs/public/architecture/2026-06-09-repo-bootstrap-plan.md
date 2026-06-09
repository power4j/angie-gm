# Angie 打包仓库初始化计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 初始化 `angie-gm` 打包仓库，建立项目规范、文档骨架与 Git 基础配置，并固化 `angie-gm-basic` / `angie-gm-all` 命名基线。

**Architecture:** 先固化正式设计文档，再创建仓库目录、文档入口与 Git 规则，最后初始化仓库并做结构级验证。当前阶段只处理文档、目录与配置，不引入构建逻辑。

**Tech Stack:** Git、Markdown、EditorConfig、Git attributes、Git ignore

---

### Task 1: 固化正式设计文档

**Files:**
- Create: `docs/public/architecture/2026-06-09-packaging-design.md`
- Create: `docs/public/architecture/2026-06-09-repo-bootstrap-plan.md`

- [ ] **Step 1: 写入正式设计文档**

输出仓库目标、安装包命名、安装布局、构建策略、发布口径、诊断要求。

- [ ] **Step 2: 人工检查文档结构**

检查标题、术语和路径是否一致。

- [ ] **Step 3: 记录初始化计划**

把初始化边界、目标与步骤写入计划文档。

### Task 2: 建立仓库规范与入口文档

**Files:**
- Create: `AGENTS.md`
- Create: `README.md`
- Create: `docs/README.md`
- Create: `docs/public/README.md`
- Create: `docs/local/README.md`

- [ ] **Step 1: 编写项目规范**

明确项目定位、目录职责、安装布局、验证口径、安装诊断要求与 Git 规则。

- [ ] **Step 2: 编写仓库与文档入口**

确保根 README 与 docs 索引文档可直接指导后续维护。

- [ ] **Step 3: 检查索引链接**

确认所有索引文档引用路径与目录名称一致。

### Task 3: 建立 Git 基础配置

**Files:**
- Create: `.editorconfig`
- Create: `.gitattributes`
- Create: `.gitignore`

- [ ] **Step 1: 定义换行、缩进与文本规范**

保证跨平台文本文件统一使用预期换行符。

- [ ] **Step 2: 定义忽略规则**

忽略本地产物、中间文件、本地过程记录与大型归档输出。

- [ ] **Step 3: 预留 Git LFS 规则**

为未来可能入库的大型归档或镜像定义 LFS 匹配模式。

### Task 4: 初始化目录骨架并验证

**Files:**
- Create: `.github/workflows/.gitkeep`
- Create: `assets/.gitkeep`
- Create: `builder/common/.gitkeep`
- Create: `builder/container/.gitkeep`
- Create: `builder/profiles/angie-gm-basic/.gitkeep`
- Create: `builder/profiles/angie-gm-all/.gitkeep`
- Create: `builder/scripts/.gitkeep`
- Create: `packaging/common/.gitkeep`
- Create: `packaging/deb/.gitkeep`
- Create: `packaging/rpm/.gitkeep`
- Create: `source/checksums/.gitkeep`
- Create: `source/manifests/.gitkeep`
- Create: `source/patches/.gitkeep`
- Create: `tests/fixtures/.gitkeep`
- Create: `tests/package/.gitkeep`
- Create: `tests/smoke/.gitkeep`
- Create: `docs/public/packaging/.gitkeep`
- Create: `docs/public/release/.gitkeep`
- Create: `docs/public/reference/.gitkeep`
- Create: `docs/public/validation/.gitkeep`

- [ ] **Step 1: 创建目录占位文件**

建立后续构建、打包、验证、发布所需的空目录。

- [ ] **Step 2: 初始化 Git 仓库**

运行 `git init`，建立本地仓库。

- [ ] **Step 3: 验证目录与忽略规则**

运行 `git status --short` 和目录检查命令，确认仓库结构与忽略行为符合预期。
