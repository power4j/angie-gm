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

## 证书配置

普通国际证书使用单值写法：

```nginx
ssl_certificate     rsa.crt;
ssl_certificate_key rsa.key;
```

国密证书使用双值写法，但前提是同一个 `server` 已开启 `ssl_ntls on;`：

```nginx
ssl_ntls on;

ssl_certificate     gm-sign.crt gm-enc.crt;
ssl_certificate_key gm-sign.key gm-enc.key;
```

双值写法的顺序有固定语义：

- 第 1 个证书 / 私钥：签名证书 / 签名私钥
- 第 2 个证书 / 私钥：加密证书 / 加密私钥
- 顺序不能写反

同一个 `server` 可以同时配置国密证书和国际证书：

- 普通 TLS 客户端握手时使用国际证书
- NTLS / 国密客户端握手时使用国密证书
- 证书选择依据握手类型和证书槽位语义，不依据文件名

推荐写法：

```nginx
ssl_ntls on;

# 国密：第 1 个是签名证书，第 2 个是加密证书
ssl_certificate     gm-sign.crt gm-enc.crt;
ssl_certificate_key gm-sign.key gm-enc.key;

# 国际证书
ssl_certificate     rsa.crt;
ssl_certificate_key rsa.key;
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
