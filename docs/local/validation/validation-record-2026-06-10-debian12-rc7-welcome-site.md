# Debian 12 官方 `rc7` 欢迎站点验证记录

## 基本信息

- 验证日期：`2026-06-10`
- 验证人员：Codex + 用户提供测试机
- 包名：
  - `angie-gm-basic`
  - `angie-gm-all`
- 包版本：`0.1.0~rc7`
- 打包修订号：`1`
- 架构：`amd64`
- 发行版：Debian 12
- 内核版本：以现场为准，未单独抄录
- `glibc` 版本：`2.36`
- 安装包文件名：
  - `angie-gm-basic_0.1.0-rc7-1_amd64.deb`
  - `angie-gm-all_0.1.0-rc7-1_amd64.deb`

## 环境信息

- 主机名：`debian-temp`
- CPU：`x86_64`
- systemd 版本：现场可执行 `systemctl --version`
- 网络条件：安装包由 GitHub Release 下载后复制到 `/tmp`
- 备注：
  - 本次验证对象是 GitHub Actions 产出的官方 review 包
  - 本次重点是默认欢迎站点与基础 HTTP 冒烟

## 验证前检查

- 冷安装前动作：
  - 使用更新后的 `tests/package/validate-package.sh`
  - `install` 模式先清理同名已安装包并重置 `systemd` 状态
- 关键目录状态：
  - 允许现场残留 `/etc/angie`、非空 `/var/log/angie`、非空 `/run/angie`
- 包管理器版本：
  - `dpkg`

## 安装与启动验证

### `angie-gm-basic`

- 执行命令：

```bash
sudo bash /tmp/validate-package.sh \
  --package-file /tmp/angie-gm-basic_0.1.0-rc7-1_amd64.deb \
  --format deb \
  --keep-package
sudo bash /tmp/basic-http.sh http://127.0.0.1/
sudo dpkg -P angie-gm-basic
```

- 结果：通过
- 关键日志：
  - `angie -t` 通过
  - `systemctl start angie` 通过
  - `systemctl is-active angie` 返回 `active`
  - 默认欢迎页正文校验通过

### `angie-gm-all`

- 执行命令：

```bash
sudo bash /tmp/validate-package.sh \
  --package-file /tmp/angie-gm-all_0.1.0-rc7-1_amd64.deb \
  --format deb \
  --keep-package
sudo bash /tmp/basic-http.sh http://127.0.0.1/
sudo dpkg -P angie-gm-all
```

- 结果：通过
- 关键日志：
  - `angie -t` 通过
  - `systemctl start angie` 通过
  - `systemctl is-active angie` 返回 `active`
  - 默认欢迎页正文校验通过

## 默认欢迎站点验证

### 配置与静态资源

- 预期配置文件：`/etc/angie/conf.d/welcome.conf`
- 预期静态页：`/opt/angie/share/html/index.html`
- 页面标题：`Welcome to Angie`
- 页面说明：安装验证页，正文包含：
  - `This page confirms that`
  - `angie-gm`
  - `is installed and running.`

### HTTP 冒烟

- 执行命令：

```bash
sudo bash /tmp/basic-http.sh http://127.0.0.1/
```

- 结果：通过
- 输出摘要：
  - `basic` / `all` 均返回欢迎页正文
  - 冒烟脚本已改为校验稳定片段，避免被 HTML 标签拆断

## 卸载观察

### `angie-gm-basic`

- `dpkg -P` 后观察：
  - `/opt/angie` 因非空被保留
  - `/run/angie` 因非空被保留
  - `/var/log/angie` 因非空被保留

### `angie-gm-all`

- `dpkg -P` 后观察：
  - `/opt/angie` 因非空被保留
  - `/run/angie` 因非空被保留
  - `/var/log/angie` 因非空被保留

说明：

- 这说明当前 purge 行为仍然偏保守
- 后续应单独明确：
  - 哪些残留属于预期
  - 是否需要在文档中显式说明欢迎页与运行树残留策略

## 结论

- 总体结果：通过
- 是否可进入下一阶段：可以
- 本轮确认：
  - `angie-gm-basic` 默认欢迎站点已在官方包中生效
  - `angie-gm-all` 默认欢迎站点已在官方包中生效
  - 基础 HTTP 冒烟链路已可复用
- 剩余问题：
  - 仍需在目标发行版执行同类验证
  - 仍需补替换升级验证
  - 仍需补 `angie-gm-all` 的 HTTP/3、stream、动态模块验证
  - 仍需决定 purge 后 `/opt/angie` 残留是否接受

## 当前停点 / 下一步

- 当前停点：官方 `rc7` `deb` 已在 Debian 12 上完成 `basic` / `all` 的默认欢迎站点验证。
- 下一步：把验证重心切到目标发行版安装替换链路，以及 `angie-gm-all` 特有能力验证。
