# 项目进度状态

最后更新：`2026-06-09`
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

## 进行中

- 真实源码准备链路接入中

## 下一步

1. 补齐 Angie 与 TongSuo 源码包的真实 SHA256
2. 在线下 Linux 或 WSL 环境验证源码下载、checksum、解包链路
3. 把 workflow 从占位 artifact 接到真实源码准备与 staging 流程

## 阻塞项

- 当前 Windows 环境没有可用的 Bash / WSL 运行时，无法在本机完成 `builder/common/*.sh` 的语法检查与执行验证
- Codex 当前 shell 环境下执行 `gh` 校验失败；该现象与用户本机终端结果不一致，应按环境差异处理，不应视为仓库或账号本身异常
- `source/checksums/upstream.sha256` 仍未写入真实 SHA256，当前真实源码准备链路还不能在严格校验模式下完成

## 最近提交

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
