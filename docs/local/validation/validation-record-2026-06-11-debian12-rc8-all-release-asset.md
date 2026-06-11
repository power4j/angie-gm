# Debian 12 `angie-gm-all` `rc8` release asset 专项验证记录

## 基本信息

- 验证日期：`2026-06-11`
- 验证人员：Codex + 用户提供测试机
- 包名：`angie-gm-all`
- 包版本：`0.1.0~rc8`
- 打包修订号：`1`
- 架构：`amd64`
- 发行版：Debian 12
- 内核版本：以现场为准，未单独抄录
- `glibc` 版本：`2.36`
- 安装包文件名：`angie-gm-all_0.1.0-rc8-1_amd64.deb`

## 环境信息

- 主机名：`debian-temp`
- CPU：`x86_64`
- systemd 版本：现场可执行 `systemctl --version`
- 网络条件：从 GitHub Release 下载 `draft + prerelease` asset 后上传到目标机
- 备注：
  - 本轮输入为正式 release asset，不再使用 `Build Packages` workflow artifact。
  - 本轮重点验证 `angie-gm-all` 的安装、自检、动态模块、`stream` 与 HTTP/3 最小能力链路。

## 验证前检查

- 每轮验证前都执行：
  - `systemctl stop angie || true`
  - `dpkg -P angie-gm-basic angie-gm-all || true`
  - `systemctl daemon-reload || true`
- 额外准备：
  - 上传以下脚本到目标机：
    - `tests/package/validate-package.sh`
    - `tests/smoke/modules.sh`
    - `tests/smoke/stream.sh`
    - `tests/smoke/http3.sh`

## 安装与服务验证

### 安装

- 执行命令：

```bash
sudo bash ./validate-package.sh \
  --package-file ./angie-gm-all_0.1.0-rc8-1_amd64.deb \
  --format deb \
  --keep-package
```

- 结果：通过
- 关键日志：
  - `dpkg -i` 成功
  - `angie -V` 通过
  - `angie -t` 通过
  - `systemctl start angie` 通过
  - `systemctl is-active angie` 返回 `active`
  - `systemctl status angie --no-pager` 显示服务正常运行

### 诊断输出

- 结果：通过
- 关键日志：
  - `angie-diagnose preflight` 正常执行
  - 关键路径均可见：
    - `/opt/angie`
    - `/etc/angie`
    - `/var/log/angie`
    - `/var/cache/angie`
    - `/var/lib/angie`
    - `/run/angie`

## 专项冒烟验证

### 动态模块加载

- 执行命令：

```bash
sudo bash ./modules.sh
```

- 结果：通过
- 输出摘要：
  - `/opt/angie/modules` 存在
  - 动态模块文件数：`2`
  - 最小 `load_module` 配置可通过 `angie -t`

### `stream`

- 执行命令：

```bash
sudo bash ./stream.sh
```

- 结果：通过
- 输出摘要：
  - `angie -V` 包含：
    - `--with-stream`
    - `--with-stream_ssl_module`
    - `--with-stream_ssl_preread_module`
  - 最小 `stream {}` 配置可通过 `angie -t`
  - 本地临时 backend 经 `127.0.0.1:18080` 转发访问成功

### HTTP/3

- 执行命令：

```bash
sudo bash ./http3.sh
```

- 结果：通过
- 输出摘要：
  - `angie -V` 包含 `--with-http_v3_module`
  - 最小 `listen ... quic reuseport;` 配置可通过 `angie -t`

## 卸载观察

- 执行命令：

```bash
sudo systemctl stop angie || true
sudo dpkg -P angie-gm-all || sudo dpkg -r angie-gm-all || true
sudo systemctl daemon-reload || true
```

- 结果：通过
- 说明：
  - 包可正常移除
  - 本轮未继续深挖 `/opt/angie`、`/var/log/angie` 等残留目录策略

## 结论

- 总体结果：通过
- 是否可进入下一阶段：可以
- 本轮确认：
  - Debian 12 上 `angie-gm-all` 的 `rc8` 正式 release asset 可完成安装、自检、启动
  - 动态模块、`stream` 与 HTTP/3 最小能力链路均通过
  - 当前 `deb` 包已满足后续扩展验证前提
- 剩余问题：
  - 仍需明确卸载后的残留目录策略
  - 仍需规划银河麒麟 V10 / 统信 V10 验证批次

## 当前停点 / 下一步

- 当前停点：Debian 12 上 `angie-gm-all` `rc8` release asset 的安装、自检与三项专项冒烟已完成。
- 下一步：明确 `dpkg -P` / `rpm -e` 后的残留目录策略，并推进银河麒麟 V10 / 统信 V10 验证计划。
