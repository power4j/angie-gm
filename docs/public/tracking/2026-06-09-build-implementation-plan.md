# Angie 打包实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 完成 `angie-gm-basic` 与 `angie-gm-all` 的源码管理、构建配置、打包模板、发布流程与基础验证框架。

**Architecture:** 先固化公开可复现的源码来源与 profile 定义，再建立共享构建脚本和 `deb/rpm` 打包模板，随后补 GitHub Actions 与进度跟踪，最后进入验证与诊断增强。

**Tech Stack:** GitHub Actions、Shell、`deb`、`rpm`、systemd、Markdown

---

### Task 1: 固化源码来源模型

**Files:**
- Create: `source/README.md`
- Create: `source/manifests/angie.json`
- Create: `source/manifests/tongsuo.json`
- Create: `source/checksums/upstream.sha256`
- Create: `source/patches/angie/.gitkeep`
- Create: `source/patches/tongsuo/.gitkeep`
- Modify: `docs/public/reference/.gitkeep`

- [ ] **Step 1: 定义 `source/README.md`**

说明源码默认不入库、构建时下载、可本地缓存、必须做 checksum 校验。

- [ ] **Step 2: 定义 Angie 与 TongSuo manifest 格式**

包含名称、版本、公开来源 URL、文件名、checksum 索引、补丁列表。

- [ ] **Step 3: 定义 checksum 文件**

采用标准 `sha256sum` 兼容格式。

- [ ] **Step 4: 提交**

```bash
git add source docs/public/README.md AGENTS.md
git commit -m "docs: define source manifest model"
```

### Task 2: 固化 profile 模型

**Files:**
- Create: `builder/profiles/angie-gm-basic/profile.env`
- Create: `builder/profiles/angie-gm-basic/modules.dynamic`
- Create: `builder/profiles/angie-gm-basic/install.assets`
- Create: `builder/profiles/angie-gm-all/profile.env`
- Create: `builder/profiles/angie-gm-all/modules.dynamic`
- Create: `builder/profiles/angie-gm-all/install.assets`

- [ ] **Step 1: 定义 profile 标量字段**

明确包名、特性开关、目录、目标格式、目标架构、冲突策略。

- [ ] **Step 2: 定义动态模块列表**

收敛 `basic` 与 `all` 的模块差异。

- [ ] **Step 3: 定义安装资源清单**

列出配置、systemd、tmpfiles、示例文件。

- [ ] **Step 4: 提交**

```bash
git add builder/profiles
git commit -m "docs: define build profile model"
```

### Task 3: 建立共享构建脚本骨架

**Files:**
- Create: `builder/common/build.sh`
- Create: `builder/common/fetch-sources.sh`
- Create: `builder/common/load-profile.sh`
- Create: `builder/common/verify-checksums.sh`
- Create: `builder/common/stage-runtime.sh`
- Create: `builder/common/diagnostics.sh`

- [ ] **Step 1: 先定义脚本职责**

每个脚本只负责一个明确阶段。

- [ ] **Step 2: 写最小命令骨架与阶段日志**

保证安装与构建诊断能力从骨架开始存在。

- [ ] **Step 3: 提交**

```bash
git add builder/common
git commit -m "feat: scaffold build helper scripts"
```

### Task 4: 建立打包模板骨架

**Files:**
- Create: `packaging/common/README.md`
- Create: `packaging/common/install-layout.md`
- Create: `packaging/deb/`
- Create: `packaging/rpm/`

- [ ] **Step 1: 定义单包交付与互斥规则**

明确 `angie-gm-basic`、`angie-gm-all` 与官方 `angie` 的冲突关系。

- [ ] **Step 2: 为 `deb` / `rpm` 分别确定模板结构**

只建骨架，不先写完整 spec/control 细节。

- [ ] **Step 3: 提交**

```bash
git add packaging
git commit -m "docs: define packaging template skeleton"
```

### Task 5: 建立 GitHub Actions 构建骨架

**Files:**
- Create: `.github/workflows/build.yml`
- Create: `.github/workflows/release.yml`

- [ ] **Step 1: 定义 `package x arch x format` 矩阵**

不把发行版塞进主构建矩阵。

- [ ] **Step 2: 定义 Release 上传骨架**

以 GitHub Release 作为正式交付入口。

- [ ] **Step 3: 提交**

```bash
git add .github/workflows
git commit -m "ci: scaffold build and release workflows"
```

### Task 6: 建立验证与诊断跟踪骨架

**Files:**
- Create: `docs/public/validation/validation-matrix.md`
- Create: `docs/public/validation/validation-record-template.md`
- Modify: `docs/public/tracking/STATUS.md`

- [ ] **Step 1: 定义验证矩阵字段**

包括包名、架构、发行版、安装结果、启动结果、协议冒烟结果、备注。

- [ ] **Step 2: 定义验证记录模板**

明确命令、结果、问题、定位线索。

- [ ] **Step 3: 提交**

```bash
git add docs/public/validation docs/public/tracking/STATUS.md
git commit -m "docs: add validation tracking skeleton"
```
