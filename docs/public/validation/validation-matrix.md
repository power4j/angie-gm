# 验证矩阵

本表用于记录安装包在不同架构、发行版和场景下的验证结果。

当前正式口径：

- `Build Baseline` 确认为 `glibc 2.28`
- `Verified On` 以目标机器实际执行 `getconf GNU_LIBC_VERSION`、`ldd --version | head -n 1` 为准
- `Expected Compatible` 不能代替已验证结论

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
| angie-gm-basic | TBD | TBD | x86_64 | GitHub Actions + AlmaLinux 8 | hosted runner | `2.28` | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | PARTIAL | PASS | 2026-06-09 | `Build Packages` 已通过 `Install build dependencies`、`Verify shell syntax`、`Run build pipeline`，产物以 artifact 形式保留 |
| angie-gm-all | TBD | TBD | aarch64 | GitHub Actions + AlmaLinux 8 | hosted runner | `2.28` | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | PARTIAL | PASS | 2026-06-09 | `Build Packages` 已通过 `Install build dependencies`、`Verify shell syntax`、`Run build pipeline`，产物以 artifact 形式保留 |

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
