# angie-gm

`angie-gm` 是一个面向离线 Linux 部署场景的打包与发布工程，用于构建 `angie` 的两类安装包：

- `angie-gm-basic`：基础能力 + 国密 / NTLS
- `angie-gm-all`：尽量完整，包含 HTTP/3、stream、常用动态模块、国密 / NTLS

项目目标：

- 通过 GitHub Actions 稳定产出可重复的 `deb` / `rpm`
- 除 `glibc` 外尽量自带运行时依赖
- 当前构建 ABI 基线固定为 `glibc 2.28`
- 统一安装前缀为 `/opt/angie`
- 配置、日志、缓存、状态与程序分离
- 通过 GitHub Actions 构建，并发布到 GitHub Release

## 目录概览

- `AGENTS.md`：项目规范
- `docs/`：正式文档与本地过程文档索引
- `source/`：上游源码清单、checksums、patches
- `builder/`：构建脚本、profile、构建容器
- `packaging/`：`deb` / `rpm` 打包模板
- `assets/`：默认配置、systemd、tmpfiles 等资源
- `tests/`：安装包级验证
- `output/`：本地构建产物与中间文件

## 当前状态

当前仓库已完成基础初始化，后续工作将围绕以下方向展开：

1. 固化构建 profile 与打包模板
2. 引入 Angie / TongSuo 来源清单与版本基线
3. 建立 GitHub Actions 构建与 Release 流程
4. 建立线下验证矩阵与诊断规范

## 文档入口

- [docs/README.md](/D:/git-repo/power4j/angie-gm/docs/README.md)
- [docs/public/README.md](/D:/git-repo/power4j/angie-gm/docs/public/README.md)
- [docs/local/README.md](/D:/git-repo/power4j/angie-gm/docs/local/README.md)
