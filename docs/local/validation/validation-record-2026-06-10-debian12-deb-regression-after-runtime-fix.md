# Debian 12 `deb` 运行时目录修复回归验证记录

## 基本信息

- 验证日期：`2026-06-10`
- 验证人员：Codex + 用户提供测试机
- 包名：
  - `angie-gm-basic`
  - `angie-gm-all`
- 包版本：`0.1.0`
- 打包修订号：`1`
- 架构：`amd64`
- 发行版：Debian 12
- 内核版本：以现场为准，未单独抄录
- `glibc` 版本：`2.36`
- 安装包文件名：
  - `angie-gm-basic_0.1.0-1_amd64.deb`
  - `angie-gm-all_0.1.0-1_amd64.deb`

## 环境信息

- 主机名：`debian-temp`
- CPU：`x86_64`
- systemd 版本：现场可执行 `systemctl --version`
- 网络条件：GitHub Actions 产物下载到本地后，通过 `scp` 复制到测试机
- 备注：
  - 本轮重点不是首次安装可用性，而是确认 `/run/angie` 管理方式调整没有让 `deb` 退化

## 验证前检查

- 每轮验证前都执行：
  - `systemctl stop angie || true`
  - `dpkg -P angie-gm-basic angie-gm-all || true`
  - `systemctl daemon-reload || true`
- 额外处理：
  - `chmod +x validate-package.sh basic-http.sh`
- 包管理器版本：
  - `dpkg`

## 安装与启动验证

### `angie-gm-basic`

- 执行命令：

```bash
sudo bash ./validate-package.sh \
  --package-file ./angie-gm-basic_0.1.0-1_amd64.deb \
  --format deb \
  --keep-package
./basic-http.sh http://127.0.0.1/
systemctl is-active angie
sudo systemctl stop angie
sudo dpkg -P angie-gm-basic
sudo systemctl daemon-reload
```

- 结果：通过
- 关键日志：
  - `angie -V` 通过
  - `angie -t` 通过
  - `systemctl start angie` 通过
  - `systemctl is-active angie` 返回 `active`
  - `basic-http.sh` 返回 `pass`

### `angie-gm-all`

- 执行命令：

```bash
sudo bash ./validate-package.sh \
  --package-file ./angie-gm-all_0.1.0-1_amd64.deb \
  --format deb \
  --keep-package
./basic-http.sh http://127.0.0.1/
systemctl is-active angie
sudo systemctl stop angie
sudo dpkg -P angie-gm-all
sudo systemctl daemon-reload
```

- 结果：通过
- 关键日志：
  - `angie -V` 通过
  - `angie -t` 通过
  - `systemctl start angie` 通过
  - `systemctl is-active angie` 返回 `active`
  - `basic-http.sh` 返回 `pass`

## 回归关注点

### `/run/angie`

- 验证结论：通过
- 说明：
  - 当前方案下，安装后直接执行 `angie -t` 依旧可用
  - 后续 `systemctl start angie` 依旧可用
  - 说明本次把 `/run/angie` 统一交给 `tmpfiles.d` 管理，没有给 `deb` 引入回归

### 诊断输出

- 验证结论：通过
- 说明：
  - `angie-diagnose preflight` 在 `basic` / `all` 两个包中都能执行
  - 日志仍可见关键路径：
    - `/opt/angie`
    - `/etc/angie`
    - `/var/log/angie`
    - `/var/cache/angie`
    - `/var/lib/angie`
    - `/run/angie`

## 卸载观察

- `dpkg -P` 后观察：
  - `/var/log/angie` 因非空被保留
  - `/opt/angie` 因非空被保留
- 说明：
  - 当前 purge 仍为偏保守策略
  - 这属于既有行为，本轮未改变

## 结论

- 总体结果：通过
- 是否可进入下一阶段：可以
- 本轮确认：
  - `/run/angie` 管理方式调整未让 Debian 12 `deb` 安装、自检、启动、欢迎页链路退化
  - `basic` / `all` 两个包都保持通过
- 剩余问题：
  - 仍需补 `angie-gm-all` 的 HTTP/3、stream、动态模块专项验证
  - 仍需明确 purge 后残留目录是否接受

## 当前停点 / 下一步

- 当前停点：Debian 12 上 `basic` / `all` `deb` 已完成运行时目录修复后的回归验证。
- 下一步：进入 `angie-gm-all` 特性专项验证，并单独整理残留目录策略。
