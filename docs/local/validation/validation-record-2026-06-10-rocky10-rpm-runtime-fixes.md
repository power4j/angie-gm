# Rocky Linux 10.2 `rpm` 运行时修复回归验证记录

## 基本信息

- 验证日期：`2026-06-10`
- 验证人员：Codex + 用户提供测试机
- 包名：
  - `angie-gm-basic`
  - `angie-gm-all`
- 包版本：`0.1.0`
- 打包修订号：`1`
- 架构：`x86_64`
- 发行版：Rocky Linux 10.2
- 内核版本：`6.12.0-124.21.1.el10_1.x86_64`
- `glibc` 版本：`2.39`
- 安装包文件名：
  - `angie-gm-basic-0.1.0-1.x86_64.rpm`
  - `angie-gm-all-0.1.0-1.x86_64.rpm`

## 环境信息

- 主机名：`rocky-10-temp`
- CPU：`x86_64`
- systemd 版本：`257`
- 网络条件：GitHub Actions 产物下载到本地后，通过 `scp` 复制到测试机
- 备注：
  - 本轮验证目标是确认两个运行时修复是否生效：
    - 私带 `libcrypt.so.1`
    - `/run/angie` 只由 `tmpfiles.d` 管理

## 验证前检查

- 现场已知历史问题：
  - 旧包在 Rocky 10.2 上缺少 `libcrypt.so.1`
  - 旧包同时使用 `tmpfiles.d` 与 `RuntimeDirectory` 管理 `/run/angie`，会触发 `status=233/RUNTIME_DIRECTORY`
- 关键目录状态：
  - 每轮验证前都执行：
    - `systemctl stop angie || true`
    - `dnf remove -y angie-gm-basic angie-gm-all || true`
    - `systemctl daemon-reload || true`
- 包管理器版本：
  - `dnf`

## 安装与启动验证

### `angie-gm-basic`

- 执行命令：

```bash
sudo bash ./validate-package.sh \
  --package-file ./angie-gm-basic-0.1.0-1.x86_64.rpm \
  --format rpm \
  --keep-package
./basic-http.sh http://127.0.0.1/
systemctl is-active angie
sudo systemctl stop angie
sudo rpm -e angie-gm-basic
sudo systemctl daemon-reload
```

- 结果：通过
- 关键日志：
  - `angie -V` 通过
  - `angie -t` 通过
  - `systemctl start angie` 通过
  - `systemctl is-active angie` 返回 `active`
  - `basic-http.sh` 返回 `pass`
  - `journalctl` 中本轮未再出现 `status=233/RUNTIME_DIRECTORY`

### `angie-gm-all`

- 执行命令：

```bash
sudo bash ./validate-package.sh \
  --package-file ./angie-gm-all-0.1.0-1.x86_64.rpm \
  --format rpm \
  --keep-package
./basic-http.sh http://127.0.0.1/
systemctl is-active angie
sudo systemctl stop angie
sudo rpm -e angie-gm-all
sudo systemctl daemon-reload
```

- 结果：通过
- 关键日志：
  - `angie -V` 通过
  - `angie -t` 通过
  - `systemctl start angie` 通过
  - `systemctl is-active angie` 返回 `active`
  - `basic-http.sh` 返回 `pass`
  - `journalctl` 中本轮未再出现 `status=233/RUNTIME_DIRECTORY`

## 关键修复验证点

### `libcrypt.so.1`

- 验证结论：通过
- 说明：
  - 本轮 `basic` / `all` 都可正常执行 `angie -V` 与 `angie -t`
  - 说明 Rocky 10.2 上此前的 `libcrypt.so.1` 缺口已被当前运行树修复覆盖

### `/run/angie`

- 验证结论：通过
- 说明：
  - 当前方案保留 `tmpfiles.d` 创建 `/run/angie`
  - `systemd` unit 不再声明 `RuntimeDirectory=angie`
  - 安装后直接执行 `angie -t` 与后续 `systemctl start angie` 可同时成立

## 卸载观察

- `rpm -e` 后观察：
  - 服务可停止
  - 包可正常移除
  - `daemon-reload` 后未见新的 unit 缓存问题
- 备注：
  - 本轮未单独深挖 `/opt/angie`、`/var/log/angie` 等残留策略，后续仍需明确

## 结论

- 总体结果：通过
- 是否可进入下一阶段：可以
- 本轮确认：
  - Rocky Linux 10.2 上 `basic` / `all` 的 `rpm` 安装、自检、启动、欢迎页链路已恢复稳定
  - `libcrypt.so.1` 问题已解决
  - `/run/angie` 目录冲突问题已解决
- 剩余问题：
  - 仍需补 `angie-gm-all` 的 HTTP/3、stream、动态模块专项验证
  - 仍需明确 purge / erase 后的残留策略

## 当前停点 / 下一步

- 当前停点：Rocky Linux 10.2 上 `basic` / `all` `rpm` 的运行时修复已回归通过。
- 下一步：继续做 Debian 12 `deb` 回归结果归档，并开始 `angie-gm-all` 特性专项验证。
