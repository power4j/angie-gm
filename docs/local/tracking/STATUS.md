# 项目进度状态

最后更新：`2026-06-10`
当前分支：`kickoff`

## 已完成

- 仓库初始化完成
- Git 仓库已建立
- `kickoff` 分支已建立
- 项目规范已建立
- `docs/public` / `docs/local` 文档体系已建立
- 安装布局、命名基线、发布口径、诊断要求已固化
- 安装包命名已收敛为 `angie-gm-basic` / `angie-gm-all`
- `source/README.md`、manifest 模型与 checksum 文件格式已建立
- `angie-gm-basic` / `angie-gm-all` 的 profile 字段模型已建立
- `deb` / `rpm` 的打包模板骨架与冲突策略已建立
- 共享构建脚本骨架与阶段日志模型已建立
- GitHub Actions 的构建矩阵与 Release workflow 骨架已建立
- 已完成一次 `gh` 只读检查尝试，并确认当前本机 GitHub CLI 环境不可用
- 包版本、打包修订号、上游源码版本的分层策略已建立
- 验证矩阵与验证记录模板已建立
- WSL Ubuntu 24 已验证 `builder/common/*.sh` 可通过 `bash -n`，且两个 profile 可跑到 staging 准备阶段
- 已定位真实源码准备链路中的日志污染问题，原因是命令替换返回值混入了标准输出日志
- Angie 与 TongSuo 公开源码包的真实 SHA256 已补齐
- WSL Ubuntu 24 已验证 Angie 与 TongSuo 的真实源码下载、checksum、解包与 staging 准备链路通过
- TongSuo 构建骨架与 Angie configure 参数骨架已接入本地构建脚本
- WSL Ubuntu 24 已验证 `angie-gm-basic` 与 `angie-gm-all` 可稳定跑通到编译占位阶段，`build/angie` 目录创建问题已修复
- 已确认银河麒麟与统信目标机的 `glibc` 为 `2.28`
- `glibc 2.28` 已收敛为当前正式的 `Build Baseline`
- GitHub Actions 已切换为固定 runner + `glibc 2.28` 基线容器方案
- 已确认 GitHub Actions 的 `ubuntu-24.04-arm` 与 `almalinux:8` 容器可启动，当前失败点定位为 `dnf` 依赖冲突
- 已定位 GitHub Actions 构建脚本的下一处失败点：容器缺少 `python3`，导致 manifest 解析失败
- GitHub Actions 最新一轮已通过 `Install build dependencies`、`Verify shell syntax` 与 `Run build pipeline` 阶段，说明当前 CI 构建骨架已在 `x86_64` / `aarch64` 上跑通
- GitHub Actions `Build Packages` 已在 `x86_64` / `aarch64`、`deb` / `rpm` 全矩阵完成，当前剩余 CI 问题仅为 Node 20 actions 弃用告警
- Angie 真实 `configure` / `make` / `install` 已接入本地构建脚本，等待下一轮 GitHub Actions 验证真实编译结果
- 已定位 Angie 真实编译的首个错误：`--builddir` 与 `make` 执行目录不一致，导致 `No rule to make target 'src/core/ngx_build.c'`
- 真实源码编译已在 GitHub Actions 全矩阵跑通，当前进入 `staging` 运行树装配与真产包阶段
- `assemble-runtime` 已在 GitHub Actions 全矩阵通过，当前首个真产包阻塞点已定位为 `almalinux:8` 仓库不提供 `dpkg`
- 已改为使用 `ar + tar` 手工生成 `.deb`，GitHub Actions 最新一轮已在 `deb` / `rpm` 全矩阵完成真实产包并上传包 artifact
- 已移除 RPM 文件名中的 `.el8` 后缀，正式外发命名回到 `edition + version + release + arch`
- `Release Packages` 已完成一次 `workflow_dispatch` dry-run，确认 8 个矩阵重构建与 release payload 汇总链路可用
- `Release Packages` 已收敛为两条正式发布路径：`workflow_dispatch -> draft prerelease` 与 `push tag -> draft stable`
- 手工触发的 `package_version` 已改为必填，版本职责与 `package_release` 分工已写入正式文档
- `Release Packages` 已完成一次真实 `workflow_dispatch prerelease` 验证，确认可创建 `draft + prerelease` release，并正确生成 `Review 0.1.0~rc1` 与 tag `v0.1.0-rc1`
- `Release Packages` 已完成 `package_version` 与 `release_tag` 解耦，手工 prerelease 的 tag 不再从版本字符串派生
- `Release Packages` 已完成一次解耦后实测，确认 `package_version=0.1.0~rc2` 与 `release_tag=v0.1.0-rc2` 可独立输入并成功生成 `draft + prerelease`
- `Release Packages` 已完成对外展示优化：review release title 与附件文件名不再使用 `~`
- `Release Packages` 已完成一次对外展示优化实测，确认 `Review 0.1.0 RC4` 与 `angie-gm-basic_0.1.0-rc4-1_amd64.deb` 等附件命名可稳定生成
- 已补充线下验证最小执行框架，包括包级验证脚本、基础 HTTP 冒烟脚本与线下执行说明
- 验证矩阵与验证记录模板已补充线下执行入口、`glibc` 检查项与升级保留结果字段
- 已完成验证资料分层收缩：正式文档仅保留稳定验证口径，线下执行说明与记录模板已迁入 `docs/local/validation/`
- 已完成 WSL / GitHub Actions 验证记录迁移，`docs/public/validation/` 不再存放过程性验证记录

## 进行中

- 准备首轮 Linux 测试机安装 / 升级 / 替换验证

## 下一步

1. 在 Linux 测试机执行首轮 `deb` 安装、替换与基础 HTTP 验证
2. 补第一批过程验证记录，并提炼需要进入正式矩阵的结果
3. 评估并处理 GitHub Actions JavaScript actions 的 Node 20 弃用告警

## 阻塞项

- 当前 Windows 环境没有可用的 Bash / WSL 运行时，无法在本机完成 `builder/common/*.sh` 的语法检查与执行验证
- Codex 当前 shell 环境下执行 `gh` 校验失败；该现象与用户本机终端结果不一致，应按环境差异处理，不应视为仓库或账号本身异常

## 最近提交

- `336300e` `feat: wire source preparation checks`
- `96856c3` `feat: prepare real source fetch pipeline`
- `9d96f31` `docs: add validation tracking skeleton`
- `d327246` `ci: scaffold build and release workflows`
- `1bee7ce` `feat: scaffold build helper scripts`
- `3c9e34e` `docs: define packaging template skeleton`
- `287939b` `docs: define build profile model`
- `86dab56` `docs: define source manifest model`
- `908e238` `docs: clarify build environment`
- `a7121bb` `docs: align package naming baseline`
- `71acf14` `chore: initialize packaging repository`

## 维护规则

1. 每次完成一个明确任务后，必须更新本文件。
2. `已完成` 只记录已提交的结果。
3. `进行中` 只保留当前真正正在推进的事项。
4. `下一步` 保持 1 到 3 条，按优先级排序。
5. 如出现依赖外部条件的问题，写入 `阻塞项`。
