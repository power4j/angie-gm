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

说明：

- 当前脚本以最小验证路径为目标。
- 后续可在此基础上继续补充 HTTPS、NTLS、HTTP/3、stream 与动态模块验证。

## 3. 验证前准备

执行前至少确认以下事项：

1. 目标机器已具备 root 权限
2. 安装包已复制到目标机器本地目录
3. 目标机器可执行 `systemctl` 与 `journalctl`
4. 目标机器已具备基础安装命令：
   - `dpkg` 或 `dnf` / `yum` / `rpm`
5. 如需执行基础 HTTP 冒烟，目标机器已具备 `curl`

建议额外记录：

- `getconf GNU_LIBC_VERSION`
- `ldd --version | head -n 1`
- `uname -r`
- `systemctl --version | head -n 1`

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

## 8. 当前边界

当前脚本与说明尚未覆盖：

- HTTPS 冒烟
- NTLS / 国密冒烟
- HTTP/3
- stream
- 动态模块加载
- 配置变更后的升级保留验证

上述内容应在后续线下验证中逐步补齐。

## 9. 当前停点 / 下一步

- 当前停点：最小线下验证脚本已就位，待接入真实 `deb` / `rpm` 包执行首轮测试。
- 下一步：在 Linux 测试机执行首次安装、替换与基础 HTTP 验证，并补第一批验证记录。
