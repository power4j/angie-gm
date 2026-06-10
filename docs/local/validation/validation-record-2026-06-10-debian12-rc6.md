# Debian 12 官方 `rc6` `deb` 验证记录

## 基本信息

- 验证日期：`2026-06-10`
- 验证人员：Codex + 用户提供测试机
- 包名：`angie-gm-basic`
- 包版本：`0.1.0~rc6`
- 打包修订号：`1`
- 架构：`amd64`
- 发行版：Debian 12
- 内核版本：以现场为准，未单独抄录
- `glibc` 版本：`2.36`
- 安装包文件名：`angie-gm-basic_0.1.0-rc6-1_amd64.deb`

## 环境信息

- 主机名：`debian-temp`
- CPU：`x86_64`
- systemd 版本：现场可执行 `systemctl --version`
- 网络条件：测试机可通过 SSH 访问；安装包通过 GitHub Release 下载后手工复制到 `/tmp`
- 备注：
  - 本次验证对象是 GitHub Actions 产出的官方 review 包
  - 本次验证环境不是目标交付发行版，仅用于过程验证

## 验证前检查

- `angie -V`：
  - `rc5` 之前已确认输出来自 GitHub Actions 产物
- `getconf GNU_LIBC_VERSION`：
  - `glibc 2.36`
- `ldd` / 依赖检查：
  - 未单独展开；本轮重点是安装、自检与启动链路
- 关键目录状态：
  - 复测前先执行清理，避免沿用上轮服务进程
- 包管理器版本：
  - `dpkg`

## 安装与升级验证

### 安装

- 执行命令：

```bash
sudo dpkg -i /tmp/angie-gm-basic_0.1.0-rc6-1_amd64.deb
sudo /usr/sbin/angie -V
sudo /usr/sbin/angie -t -c /etc/angie/angie.conf
sudo systemctl start angie
sudo systemctl is-active angie
```

- 结果：通过
- 关键日志：
  - `postinst` 正常执行
  - `angie -t` 通过
  - `systemctl start angie` 冷启动通过
  - `ExecStartPre=/opt/angie/bin/angie-diagnose preflight` 返回成功

### 升级或替换

- 执行命令：
  - `sudo dpkg -i /tmp/angie-gm-basic_0.1.0-rc6-1_amd64.deb`
  - 现场也验证过 `rc5 -> rc6` 的升级路径
- 结果：通过
- 关键日志：
  - `rc5` 时的 `nobody` / `daemon-reload` 问题均已消除
- 配置保留结果：
  - `dpkg` 安装日志显示 `angie.conf` 属于常规配置文件管理路径

## 服务与配置验证

### 配置检查

- 执行命令：`angie -t`
- 结果：通过
- 输出摘要：
  - `syntax is ok`
  - `configuration file /etc/angie/angie.conf test is successful`

### 服务启动

- 执行命令：`systemctl start angie`
- 结果：通过
- 输出摘要：
  - `active (running)`
  - `angie-diagnose` 打印了 `/opt/angie`、`/etc/angie`、`/var/log/angie`、`/var/cache/angie`、`/var/lib/angie`、`/run/angie`
  - `preflight=ok`

## 协议冒烟验证

### 基础 HTTP

- 执行命令：未执行
- 结果：待补
- 输出摘要：本轮先收敛安装、自检与服务启动链路

### 基础 HTTPS

- 执行命令：未执行
- 结果：待补
- 输出摘要：未进入本轮范围

### NTLS / 国密

- 执行命令：未执行
- 结果：待补
- 输出摘要：未进入本轮范围

### HTTP/3

- 执行命令：未执行
- 结果：待补
- 输出摘要：`basic` 版本轮不覆盖

### stream

- 执行命令：未执行
- 结果：待补
- 输出摘要：`basic` 版本轮不覆盖

### 动态模块加载

- 执行命令：未执行
- 结果：待补
- 输出摘要：`basic` 版本轮不覆盖

## 诊断线索

- 安装脚本阶段日志是否足够：基本足够
- 关键路径输出是否足够：足够，`angie-diagnose` 已打印关键目录存在性
- 失败上下文是否足够：
  - `rc5` 阶段足以定位到 `systemd` unit 缓存问题
- `journalctl -u angie -n 100 --no-pager` 摘要：
  - 可看到 `rc5` 旧失败记录
  - `rc6` 冷启动记录显示 `angie-diagnose` 与 `angie -t` 都成功
- 建议补充项：
  - 验证脚本在 `install` 模式下必须先清理同名已安装包，避免把升级或残留进程误判为冷安装成功

## 卸载观察

- 执行命令：

```bash
sudo dpkg -P angie-gm-basic
```

- 结果：包已卸载
- 现场残留：
  - `/opt/angie` 已删除
  - `/var/cache/angie` 已删除
  - `/var/lib/angie` 已删除
  - `/run/angie` 可能因非空被保留
  - `/etc/angie` 作为配置目录保留
  - `/var/log/angie` 因非空被保留
- 说明：
  - 这符合“不要静默清理现场配置 / 日志”的保守策略
  - 后续应明确文档口径：哪些目录属于预期保留

## 结论

- 总体结果：通过
- 是否可进入下一阶段：可以
- 剩余问题：
  - 仍需补基础 HTTP 冒烟
  - 仍需在目标发行版（麒麟 / 统信 / Ubuntu 20）执行正式线下验证
  - 仍需覆盖 `angie-gm-all`、替换升级、HTTPS / NTLS / HTTP/3 / stream / 动态模块

## 当前停点 / 下一步

- 当前停点：官方 `rc6` `deb` 已在 Debian 12 上完成冷安装、自检、启动与卸载验证。
- 下一步：补验证脚本的“冷安装前清理”逻辑，并继续推进目标发行版与 `angie-gm-all` 验证。
