# `angie-gm-all` `rc3` NTLS 指令缺口复现记录

## 基本信息

- 验证日期：`2026-06-16`
- 验证人员：Codex
- 仓库：`power4j/angie-gm`
- Release：`v0.1.0-rc3`
- 验证对象：`angie-gm-all_0.1.0-rc3-1_amd64.deb`
- 验证目标：
  - 确认当前 `rc3` 包是否包含 Angie 侧 `--with-ntls`
  - 确认最小 `ssl_ntls on;` 配置是否可通过 `angie -t`

## 验证环境

- 主机：`192.168.100.65`
- 发行版：Debian 12
- `glibc`：`2.36`

## 验证步骤

1. 从 GitHub Release 下载 `angie-gm-all_0.1.0-rc3-1_amd64.deb`
2. 上传到测试机并执行冷安装
3. 执行 `/usr/sbin/angie -V`
4. 使用临时 TLS 证书生成最小配置：
   - `listen 18443 ssl;`
   - `ssl_certificate ...;`
   - `ssl_certificate_key ...;`
   - `ssl_ntls on;`
5. 执行 `angie -t -c <temp-conf>`
6. 完成后卸载测试包

## 结果

### `angie -V`

当前 `rc3` 包输出包含：

- `--with-openssl=/__w/angie-gm/angie-gm/output/work/angie-gm-all/sources/tongsuo`
- `--with-openssl-opt=enable-ntls`
- `--with-http_ssl_module`

当前 `rc3` 包输出不包含：

- `--with-ntls`

### `ssl_ntls on;` 配置测试

- 结果：失败
- 错误摘要：

```text
angie: [emerg] unknown directive "ssl_ntls" in /tmp/<temp-conf>:11
angie: configuration file /tmp/<temp-conf> test failed
```

## 结论

- 当前 `v0.1.0-rc3` 的 `angie-gm-all_0.1.0-rc3-1_amd64.deb` 未启用 Angie 侧 `--with-ntls`
- 当前包内 `ssl_ntls` 指令不可用
- 根因与代码检查结论一致：
  - 仓库构建脚本只传 `--with-openssl-opt=enable-ntls`
  - 未传 Angie 自身的 `--with-ntls`

## 当前停点 / 下一步

- 当前停点：`rc3` 包的 NTLS 指令缺口已在 Debian 12 上复现并确认。
- 下一步：基于已补的 `--with-ntls` 构建修复重新产包，并重新验证 `ssl_ntls on;` 可通过 `angie -t`。
