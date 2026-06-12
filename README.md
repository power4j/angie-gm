# angie-gm

`angie-gm` 提供基于 `Angie` 的离线安装包，面向具备 Linux 基础的部署与运维场景。

当前提供两个包：

- `angie-gm-basic`
  - 基础 HTTP / HTTPS + 国密 / NTLS
- `angie-gm-all`
  - 在 `basic` 基础上增加 HTTP/3、`stream`、动态模块

约束：

- `angie-gm-basic` 与 `angie-gm-all` 不允许同时安装
- 运行时命令统一为 `angie`
- 服务名统一为 `angie.service`

## 安装要求

- CPU 架构：
  - `x86_64`
  - `aarch64`
- 已验证或面向的平台：
  - 银河麒麟服务器版 V10
  - 统信服务器版 V10
  - Ubuntu 20
- 运行时要求：
  - `glibc >= 2.28`
  - `systemd`
  - `root` 权限

建议在安装前检查：

```bash
getconf GNU_LIBC_VERSION
systemctl --version | head -n 1
uname -m
```

## 获取安装包

正式安装、回归验证与交付验证统一使用 GitHub Release asset。

- review / rc 版本：使用 `draft + prerelease`
- 稳定版：使用 draft stable release

## 安装

`deb`：

```bash
dpkg -i ./angie-gm-basic_<version>-<release>_<arch>.deb
```

`rpm`：

```bash
dnf install -y ./angie-gm-basic-<version>-<release>.<arch>.rpm
```

如需安装全功能版本，将包名替换为 `angie-gm-all`。

## 卸载

`deb`：

```bash
dpkg -P angie-gm-basic
```

`rpm`：

```bash
dnf remove -y angie-gm-basic
```

如已安装的是全功能版本，将包名替换为 `angie-gm-all`。

## 常用命令

检查已安装版本：

```bash
angie -V
```

查看包管理器中的已安装版本：

```bash
dpkg -s angie-gm-basic
rpm -q angie-gm-basic
```

配置检查：

```bash
angie -t
```

服务启停：

```bash
systemctl start angie
systemctl stop angie
systemctl restart angie
systemctl status angie --no-pager
```

开机自启：

```bash
systemctl enable angie
```

查看近期服务日志：

```bash
journalctl -u angie -n 100 --no-pager
```

## 路径说明

- 程序与私有库：`/opt/angie`
- 主配置：`/etc/angie`
- 主配置文件：`/etc/angie/angie.conf`
- 额外配置目录：`/etc/angie/conf.d`
- 日志目录：`/var/log/angie`
- 缓存目录：`/var/cache/angie`
- 持久状态目录：`/var/lib/angie`
- 运行时目录：`/run/angie`

## 文档

- [docs/README.md](/D:/git-repo/power4j/angie-gm/docs/README.md)
- [docs/public/README.md](/D:/git-repo/power4j/angie-gm/docs/public/README.md)

## 说明

本仓库用于构建与发布 `angie-gm` 安装包，不是 `Angie` 或 `TongSuo` 的上游开发仓库。
