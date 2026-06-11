# 验证矩阵

本表用于记录安装包在不同架构、发行版和场景下的验证结果。

当前正式口径：

- `Build Baseline` 确认为 `glibc 2.28`
- `Verified On` 以目标机器实际执行 `getconf GNU_LIBC_VERSION`、`ldd --version | head -n 1` 为准
- `Expected Compatible` 不能代替已验证结论
- GitHub Actions workflow artifact 仅作为 CI 调试输入
- 正式线下验证与交付验证统一以 GitHub Release asset 为输入

## 字段说明

- `package`：`angie-gm-basic` 或 `angie-gm-all`
- `version`：本项目包版本
- `release`：打包修订号
- `arch`：`x86_64` 或 `aarch64`
- `distro`：目标发行版名称
- `kernel`：目标内核版本
- `glibc`：目标系统 `glibc` 版本
- `install`：安装结果
- `upgrade`：升级或替换结果
- `service`：`systemctl start angie` 结果
- `config_test`：`angie -t` 结果
- `protocol_smoke`：基础协议冒烟结果
- `diagnostics`：排错线索是否充足
- `date`：验证日期
- `notes`：补充说明

## 状态值建议

- `PASS`
- `FAIL`
- `PARTIAL`
- `NOT_RUN`

## 矩阵

| package | version | release | arch | distro | kernel | glibc | install | upgrade | service | config_test | protocol_smoke | diagnostics | date | notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| angie-gm-basic | TBD | TBD | x86_64 | Ubuntu 20 | TBD | TBD | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | TBD | 首行模板 |
| angie-gm-all | TBD | TBD | aarch64 | 银河麒麟服务器版 V10 | TBD | TBD | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | TBD | 首行模板 |
| angie-gm-basic | TBD | TBD | x86_64 | Ubuntu 24 (WSL) | `6.6.87.2-microsoft-standard-WSL2` | TBD | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | PARTIAL | PASS | 2026-06-09 | 已验证 `bash -n` 通过，Angie 与 TongSuo 源码下载 / checksum / 解包 / staging 准备通过 |
| angie-gm-all | TBD | TBD | x86_64 | Ubuntu 24 (WSL) | `6.6.87.2-microsoft-standard-WSL2` | TBD | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | PARTIAL | PASS | 2026-06-09 | 已验证 `bash -n` 通过，Angie 与 TongSuo 源码缓存命中 / checksum / 解包 / staging 准备通过 |
| angie-gm-basic | TBD | TBD | x86_64 | GitHub Actions + AlmaLinux 8 | hosted runner | `2.28` | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | PARTIAL | PASS | 2026-06-09 | `Build Packages` 仅验证 CI 构建链路；其 workflow artifact 只用于调试，不作为正式线下验证输入 |
| angie-gm-all | TBD | TBD | aarch64 | GitHub Actions + AlmaLinux 8 | hosted runner | `2.28` | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | PARTIAL | PASS | 2026-06-09 | `Build Packages` 仅验证 CI 构建链路；其 workflow artifact 只用于调试，不作为正式线下验证输入 |
| angie-gm-all | `0.1.0~rc8` | `1` | x86_64 | Rocky Linux 10.2 | `6.12.0-124.21.1.el10_1.x86_64` | `2.39` | PASS | NOT_RUN | PASS | PASS | PASS | PASS | 2026-06-11 | 输入为 GitHub Release `v0.1.0-rc8` asset；已通过安装、自检、动态模块、`stream` 与 HTTP/3 最小能力验证 |

## 协议冒烟最低要求

`angie-gm-basic`：

- 基础 HTTP
- 基础 HTTPS
- NTLS / 国密链路

`angie-gm-all`：

- 基础 HTTP
- 基础 HTTPS
- NTLS / 国密链路
- HTTP/3
- stream
- 至少一个动态模块加载

## 线下验证入口

当前仓库已提供最小线下验证脚本：

- 包级验证脚本：
  - [tests/package/validate-package.sh](/D:/git-repo/power4j/angie-gm/tests/package/validate-package.sh)
- 基础 HTTP 冒烟脚本：
  - [tests/smoke/basic-http.sh](/D:/git-repo/power4j/angie-gm/tests/smoke/basic-http.sh)

正式要求：

- 执行线下验证前，应先从 GitHub Release 下载对应版本的 release asset
- review / rc 验证应使用 `draft + prerelease` 的 release asset
- 稳定版验证应使用 draft stable release 的 release asset

执行说明、过程记录与记录模板属于过程资料，应放在 `docs/local/` 维护。
