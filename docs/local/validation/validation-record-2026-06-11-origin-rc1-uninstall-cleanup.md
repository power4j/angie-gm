# `power4j/angie-gm` `rc1` 卸载残留清理回归记录

## 基本信息

- 验证日期：`2026-06-11`
- 验证人员：Codex + 用户提供测试机
- 仓库：`power4j/angie-gm`
- Release：`v0.1.0-rc1`
- 验证对象：`angie-gm-all`
- 验证目标：
  - 确认卸载后空运行目录是否被清理
  - 确认日志目录是否继续保留

## 输入包

- Debian 12：
  - `angie-gm-all_0.1.0-rc1-1_amd64.deb`
- Rocky Linux 10.2：
  - `angie-gm-all-0.1.0-rc1-1.x86_64.rpm`

说明：

- 两个包均来自 `power4j/angie-gm` 的 GitHub Release asset
- Release `target_commitish` 为 `bd0544a`

## 验证环境

### Debian 12

- 主机名：`debian-temp`
- `glibc`：`2.36`

### Rocky Linux 10.2

- 主机名：`rocky-10-temp`
- `glibc`：`2.39`

## 执行步骤

1. 冷安装 `angie-gm-all`
2. 执行 `validate-package.sh --keep-package`
3. 手工卸载：
   - Debian：`dpkg -P angie-gm-all`
   - Rocky：`dnf remove -y angie-gm-all`
4. 检查以下路径：
   - `/opt/angie`
   - `/etc/angie`
   - `/var/log/angie`
   - `/var/cache/angie`
   - `/var/lib/angie`
   - `/run/angie`

## 结果

### Debian 12

- `validate-package.sh`：通过
- 卸载后路径状态：
  - `/opt/angie`：已删除
  - `/etc/angie`：已删除
  - `/var/log/angie`：保留
  - `/var/cache/angie`：已删除
  - `/var/lib/angie`：已删除
  - `/run/angie`：已删除

### Rocky Linux 10.2

- `validate-package.sh`：通过
- 卸载后路径状态：
  - `/opt/angie`：已删除
  - `/etc/angie`：已删除
  - `/var/log/angie`：保留
  - `/var/cache/angie`：已删除
  - `/var/lib/angie`：已删除
  - `/run/angie`：已删除

## 结论

- 总体结果：通过
- 已确认当前卸载行为符合预期：
  - 配置目录不残留
  - 空运行目录、空缓存目录、空状态目录不残留
  - `/opt/angie` 中仅用于运行期的空临时目录已被清理
  - 日志目录与日志文件继续保留

## 当前停点 / 下一步

- 当前停点：正式仓库 `power4j/angie-gm` 的 `rc1` 已完成卸载残留清理回归。
- 下一步：规划银河麒麟 V10 / 统信 V10 验证批次，并决定是否把当前人工验证摘要补入 release 说明。
