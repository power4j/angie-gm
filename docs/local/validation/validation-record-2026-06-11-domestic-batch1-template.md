# 国产发行版 `Batch 1` 验证记录模板

## 适用范围

- 银河麒麟服务器版 V10 `x86_64`
- 统信服务器版 V10 `x86_64`
- `angie-gm-basic`
- `angie-gm-all`

## 基本信息

- 验证日期：
- 验证人员：
- 仓库：`power4j/angie-gm`
- Release tag：
- 包名：
- 包版本：
- 打包修订号：
- 架构：`x86_64`
- 发行版：
- 内核版本：
- `glibc` 版本：
- 安装包文件名：

## 环境信息

- 主机名：
- CPU：
- systemd 版本：
- 包管理器版本：
- 网络条件：
- 备注：

## 验证前检查

- `getconf GNU_LIBC_VERSION`：
- `ldd --version | head -n 1`：
- `uname -r`：
- `systemctl --version | head -n 1`：
- `curl --version | head -n 1`：
- 关键目录初始状态：
  - `/opt/angie`
  - `/etc/angie`
  - `/var/log/angie`
  - `/var/cache/angie`
  - `/var/lib/angie`
  - `/run/angie`

## 冷安装验证

- 执行命令：
- 结果：
- 输出摘要：

建议命令：

```bash
bash tests/package/validate-package.sh \
  --package-file <package-file> \
  --format <deb|rpm> \
  --keep-package
```

## 服务与配置验证

### `angie -V`

- 结果：
- 输出摘要：

### `angie -t`

- 结果：
- 输出摘要：

### `systemctl start angie`

- 结果：
- 输出摘要：

### `systemctl status angie --no-pager`

- 结果：
- 输出摘要：

### `journalctl -u angie -n 100 --no-pager`

- 结果：
- 输出摘要：

## 协议与能力冒烟

### 默认欢迎页

- 执行命令：
- 结果：
- 输出摘要：

建议命令：

```bash
bash tests/smoke/basic-http.sh
```

### `angie-gm-all` 动态模块

- 执行命令：
- 结果：
- 输出摘要：

### `angie-gm-all` `stream`

- 执行命令：
- 结果：
- 输出摘要：

### `angie-gm-all` HTTP/3

- 执行命令：
- 结果：
- 输出摘要：

### `angie-gm-all` NTLS / 国密

- 执行命令：
- 结果：
- 输出摘要：

建议命令：

```bash
bash tests/smoke/modules.sh
bash tests/smoke/stream.sh
bash tests/smoke/http3.sh
bash tests/smoke/ntls.sh
```

## 诊断线索

- 安装阶段日志是否足够：
- 关键路径输出是否足够：
- 失败上下文是否足够：
- 需要补充的排错信息：

## 结论

- 总体结果：
- 是否可进入下一批次：
- 剩余问题：

## 当前停点 / 下一步

- 当前停点：
- 下一步：
