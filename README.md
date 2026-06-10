# angie-gm

`angie-gm` 是一个面向离线 Linux 部署场景的打包与发布工程，用于构建并发布基于 `angie` 的安装包。

当前对外交付的安装包为：

- `angie-gm-basic`
  - 基础能力 + 国密 / NTLS
- `angie-gm-all`
  - 尽量完整，包含 HTTP/3、stream、常用动态模块、国密 / NTLS

## 支持范围

当前面向以下目标平台与架构：

- 银河麒麟服务器版 V10
- 统信服务器版 V10
- Ubuntu 20
- `x86_64`
- `aarch64`

当前构建 ABI 基线：

- `glibc 2.28`

## 安装布局

运行时统一使用中性名称：

- 可执行文件：`angie`
- 服务名：`angie.service`

固定安装布局如下：

- 程序与私有库：`/opt/angie`
- 主配置：`/etc/angie`
- 日志：`/var/log/angie`
- 缓存：`/var/cache/angie`
- 持久状态：`/var/lib/angie`
- 运行时目录：`/run/angie`

## 构建与发布

当前仓库的正式构建与发布链路为：

- 通过 GitHub Actions 进行构建
- 输出 `deb` 与 `rpm`
- 通过 GitHub Release 发布产物

当前验证输入口径：

- `Build Packages` 的 workflow artifact 仅用于持续集成调试与问题定位
- 线下安装验证、替换验证与交付验证统一使用 GitHub Release asset
- review / rc 验证使用 `draft + prerelease` release asset
- 稳定版验证使用 draft stable release asset

当前交付策略为：

- 单包交付
- 除 `glibc` 外尽量自带运行时依赖
- 配置、日志、缓存、状态与程序分离

## 文档入口

- [docs/README.md](/D:/git-repo/power4j/angie-gm/docs/README.md)
- [docs/public/README.md](/D:/git-repo/power4j/angie-gm/docs/public/README.md)

## 相关说明

- 当前仓库是 `angie` 离线安装包的构建与发布工程，不是 `Angie` 或 `TongSuo` 的上游开发仓库。
