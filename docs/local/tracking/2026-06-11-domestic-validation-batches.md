# 国产发行版线下验证批次计划

## 目标

在不阻塞当前 GitHub 构建与发布基线的前提下，尽快完成银河麒麟服务器版 V10 与统信服务器版 V10 的首轮线下验证。

## 前提

- 当前 `Build Baseline` 为 `glibc 2.28`
- 当前正式验证输入统一使用 GitHub Release asset
- 当前 `x86_64` 的 Debian 12 与 Rocky Linux 10.2 已完成代表性验证
- 当前 `dev` 为日常开发分支，`main` / `dev` 已进入 `origin` 单上游模式

## 验证批次

### Batch 1

- 目标：
  - 银河麒麟服务器版 V10 `x86_64`
  - 统信服务器版 V10 `x86_64`
- 验证包：
  - `angie-gm-basic`
  - `angie-gm-all`
- 最低验证项：
  - 冷安装
  - `angie -V`
  - `angie -t`
  - `systemctl start angie`
  - 默认欢迎页
  - `angie-gm-all` 的 `stream` / 动态模块 / HTTP/3
- 目标：
  - 先确认 `glibc 2.28` 基线下的主流 `x86_64` 兼容性

### Batch 2

- 目标：
  - 银河麒麟服务器版 V10 `aarch64`
  - 统信服务器版 V10 `aarch64`
- 验证包：
  - `angie-gm-basic`
  - `angie-gm-all`
- 最低验证项：
  - 与 Batch 1 相同
- 目标：
  - 补齐国产发行版 `ARM` 交付口径

### Batch 3

- 目标：
  - 选定一台国产发行版机器执行升级 / 替换 / 卸载专项回归
- 验证重点：
  - `basic -> all`
  - `all -> basic`
  - 同版本重新安装
  - 卸载后目录清理
  - 配置保留行为
- 目标：
  - 验证“单包交付 + 互斥替换”在国产发行版上的行为

## 执行顺序建议

1. 先做 Batch 1
2. Batch 1 通过后再做 Batch 2
3. `x86_64` 与 `aarch64` 都有首轮通过样本后，再做 Batch 3

## 记录要求

- 每台机器单独生成验证记录
- 输入包必须标明 release tag 与具体文件名
- 明确记录：
  - `getconf GNU_LIBC_VERSION`
  - `ldd --version | head -n 1`
  - 内核版本
  - systemd 版本
  - 是否为最小化安装

## 当前停点 / 下一步

- 当前停点：当前仅完成 Debian 12 / Rocky Linux 10.2 的代表性验证，国产发行版批次尚未开始。
- 下一步：准备银河麒麟服务器版 V10 `x86_64` 与统信服务器版 V10 `x86_64` 的首轮 Batch 1 验证输入与记录模板实例。
