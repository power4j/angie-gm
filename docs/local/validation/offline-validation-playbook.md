# 线下验证执行说明

本文档说明 `angie-gm` 安装包在线下目标机器上的最小验证路径，用于首轮安装、替换、服务检查与基础冒烟验证。

## 1. 适用范围

适用对象：

- 银河麒麟服务器版 V10
- 统信服务器版 V10
- Ubuntu 20
- `x86_64`
- `aarch64`

适用场景：

- 首次安装验证
- `angie-gm-basic` 与 `angie-gm-all` 的替换验证
- 线下冒烟验证前的标准自检

## 2. 验证入口

当前仓库提供以下线下验证脚本骨架：

- 包级验证：
  - [tests/package/validate-package.sh](/D:/git-repo/power4j/angie-gm/tests/package/validate-package.sh)
- 基础 HTTP 冒烟：
  - [tests/smoke/basic-http.sh](/D:/git-repo/power4j/angie-gm/tests/smoke/basic-http.sh)
- `angie-gm-all` 专项冒烟：
  - [tests/smoke/http3.sh](/D:/git-repo/power4j/angie-gm/tests/smoke/http3.sh)
  - [tests/smoke/stream.sh](/D:/git-repo/power4j/angie-gm/tests/smoke/stream.sh)
  - [tests/smoke/modules.sh](/D:/git-repo/power4j/angie-gm/tests/smoke/modules.sh)

说明：

- 当前脚本以最小验证路径为目标。
- HTTP/3、stream、动态模块脚本当前属于能力级冒烟，优先证明编译开关、配置语法、最小代理链路与最小模块加载链路可用。
- 当前不把 HTTP/3 客户端互通、复杂 upstream、模块业务行为深测放入第一轮脚本。

## 3. 验证前准备

执行前至少确认以下事项：

1. 目标机器已具备 root 权限
2. 安装包已复制到目标机器本地目录
3. 目标机器可执行 `systemctl` 与 `journalctl`
4. 目标机器已具备基础安装命令：
   - `dpkg` 或 `dnf` / `yum` / `rpm`
5. 如需执行基础 HTTP 冒烟，目标机器已具备 `curl`
6. 当前验证包应来自 GitHub Release asset，而不是 `Build Packages` 的 workflow artifact

建议额外记录：

- `getconf GNU_LIBC_VERSION`
- `ldd --version | head -n 1`
- `uname -r`
- `systemctl --version | head -n 1`

包来源要求：

- review / rc 验证：
  - 从 `Release Packages` 生成的 `draft + prerelease` 下载 release asset
- 稳定版验证：
  - 从 draft stable release 下载 release asset
- `Build Packages` 的 workflow artifact：
  - 只用于 CI 调试、构建问题定位、运行树排错
  - 不作为正式线下验证输入

## 4. 首次安装验证

`deb` 示例：

```bash
bash tests/package/validate-package.sh \
  --package-file ./angie-gm-basic_0.1.0-1_amd64.deb \
  --format deb
```

`rpm` 示例：

```bash
bash tests/package/validate-package.sh \
  --package-file ./angie-gm-basic-0.1.0-1.x86_64.rpm \
  --format rpm
```

脚本默认执行以下检查：

- 安装目标包
- 执行 `angie -V`
- 执行 `angie -t`
- 启动 `angie.service`
- 检查 `systemctl is-active angie`
- 输出 `systemctl status angie --no-pager`
- 输出 `journalctl -u angie -n 100 --no-pager`

默认行为：

- 验证结束后自动卸载已安装包

如需保留现场结果，可追加：

```bash
--keep-package
```

## 5. 替换验证

当前脚本支持先安装旧包，再安装新包的替换验证。

示例：

```bash
bash tests/package/validate-package.sh \
  --package-file ./angie-gm-all_0.1.0-1_amd64.deb \
  --format deb \
  --mode replace \
  --old-package-file ./angie-gm-basic_0.1.0-1_amd64.deb
```

说明：

- `replace` 模式用于验证标准包升级路径是否可用
- 当前只验证包管理器替换、配置检查与服务启动链路
- 现场配置保留行为仍需结合真实配置变更做补充验证

## 6. 基础 HTTP 冒烟验证

在服务已启动的前提下，可执行：

```bash
bash tests/smoke/basic-http.sh
```

如服务监听地址或端口不同，可显式传入 URL：

```bash
bash tests/smoke/basic-http.sh http://127.0.0.1:8080/
```

## 7. 建议记录项

每次线下验证建议同步记录：

- 包文件名
- 包版本与打包修订号
- 目标发行版
- 架构
- `glibc` 版本
- 安装结果
- 替换结果
- `angie -t` 结果
- 服务启动结果
- 基础协议冒烟结果
- `journalctl` 摘要

记录格式可参考：

- [validation-record-template.md](/D:/git-repo/power4j/angie-gm/docs/local/validation/validation-record-template.md)
- [validation-matrix.md](/D:/git-repo/power4j/angie-gm/docs/public/validation/validation-matrix.md)

## 8. `angie-gm-all` 专项冒烟验证

当前建议按以下顺序执行：

1. 动态模块加载
2. stream
3. HTTP/3
4. NTLS / 国密

### 动态模块加载

执行命令：

```bash
bash tests/smoke/modules.sh
```

验证目标：

- `/opt/angie/modules` 目录存在
- 目录下至少存在一个动态模块文件
- 生成最小 `load_module` 配置后，`angie -t` 可通过

### stream

执行命令：

```bash
bash tests/smoke/stream.sh
```

验证目标：

- `angie -V` 包含：
  - `--with-stream`
  - `--with-stream_ssl_module`
  - `--with-stream_ssl_preread_module`
- 最小 `stream {}` 配置可通过 `angie -t`
- 本地临时 backend 可经 stream 监听端口转发访问

### HTTP/3

执行命令：

```bash
bash tests/smoke/http3.sh
```

验证目标：

- `angie -V` 包含 `--with-http_v3_module`
- 最小 `listen ... quic reuseport;` 配置可通过 `angie -t`

说明：

- 当前脚本先验证 HTTP/3 编译能力和配置能力。
- 如现场具备 `curl --http3` 或其他 QUIC 客户端，再追加真实请求验证记录。

### NTLS / 国密

执行命令：

```bash
bash tests/smoke/ntls.sh
```

验证目标：

- `angie -V` 包含：
  - `--with-http_ssl_module`
  - `--with-ntls`
- 最小 `ssl_ntls on;` 配置可通过 `angie -t`

说明：

- 当前脚本只验证 NTLS 指令级能力是否已进入二进制。
- 当前不验证双证书语法，也不验证国密客户端真实握手互通。

## 9. 当前边界

当前脚本与说明尚未覆盖：

- HTTPS 冒烟
- HTTP/3 真实客户端互通
- NTLS 双证书配置
- 国密客户端真实握手互通
- 复杂 stream upstream 场景
- 动态模块业务行为深测
- 配置变更后的升级保留验证

上述内容应在后续线下验证中逐步补齐。

## 10. 当前停点 / 下一步

- 当前停点：Rocky Linux 10.2 与 Debian 12 已完成安装、自检、启动与欢迎页回归验证，当前进入 `angie-gm-all` 特性专项验证阶段。
- 下一步：基于 GitHub Release asset 在 Rocky Linux 10.2 与后续目标发行版执行 `modules.sh`、`stream.sh`、`http3.sh`，并补对应验证记录。

## 11. 国产发行版 `Batch 1` 建议顺序

当前建议按以下顺序执行首轮国产发行版验证：

1. 银河麒麟服务器版 V10 `x86_64` `angie-gm-basic`
2. 银河麒麟服务器版 V10 `x86_64` `angie-gm-all`
3. 统信服务器版 V10 `x86_64` `angie-gm-basic`
4. 统信服务器版 V10 `x86_64` `angie-gm-all`

执行要求：

- 输入包统一来自 GitHub Release asset
- 每台机器至少保留一份完整验证记录
- `angie-gm-all` 必须额外执行：
  - `tests/smoke/modules.sh`
  - `tests/smoke/stream.sh`
  - `tests/smoke/http3.sh`
  - `tests/smoke/ntls.sh`

记录建议：

- 直接复制并填写：
  - [validation-record-2026-06-11-domestic-batch1-template.md](/D:/git-repo/power4j/angie-gm/docs/local/validation/validation-record-2026-06-11-domestic-batch1-template.md)
