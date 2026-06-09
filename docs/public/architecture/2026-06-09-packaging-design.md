# Angie 离线打包设计

## 1. 背景

本项目用于构建 `angie` 的离线安装包，目标平台为银河麒麟服务器版 V10、统信服务器版 V10、Ubuntu 20，并覆盖 `x86_64` 与 `aarch64`。

当前首要目标：

1. 单包交付
2. 除 `glibc` 外尽量自带依赖，构成厚包
3. 配置、日志、缓存、状态与程序分离
4. GitHub Actions 产包，GitHub Release 发布
5. 安装、升级与排错过程具备基础诊断能力

## 2. 安装包

项目固定维护两个安装包：

- `angie-gm-basic`
  - 基础能力 + 国密 / NTLS
- `angie-gm-all`
  - 在 `angie-gm-basic` 基础上增加 HTTP/3、stream、常用动态模块

运行时名称保持中性：

- 命令：`angie`
- 服务：`angie.service`

安装包差异只通过包名、Release 名、构建元数据和 `angie -V` 暴露。

冲突策略：

- `angie-gm-basic` 与 `angie-gm-all` 不允许同时安装。
- 两者都必须与官方 `angie` 包显式冲突。
- 首版不默认通过 `Provides: angie` 冒充官方包，除非后续出现明确依赖兼容需求。

## 3. 安装布局

固定安装路径如下：

- `/opt/angie`
- `/etc/angie`
- `/var/log/angie`
- `/var/cache/angie`
- `/var/lib/angie`
- `/run/angie`

设计原则：

- 程序与私有运行库集中在 `/opt/angie`
- 配置与可变数据不随升级覆盖
- 两种包不能共存，但应允许标准升级替换

## 4. 构建策略

构建链路固定为：

1. `profile`：定义安装包差异
2. `staging`：将运行树组装为统一目录结构
3. `package`：从 staging 结果生成 `deb` / `rpm`

主路线采用：

- `glibc` 依赖系统提供
- `TongSuo` 与其他可控私有库尽量随包进入 `/opt/angie/lib`
- 不把全静态或 `musl` 替代 `glibc` 作为首发前提

当前暂定的构建 ABI 基线：

- `Build Baseline`: `glibc 2.28`
- 适用目的：优先覆盖银河麒麟服务器版 V10、统信服务器版与 Ubuntu 20 的共同最低基线
- 当前状态：暂定要求，待目标机器线下核实 `glibc` 版本后再收敛为正式结论

约束：

- GitHub Actions 不得直接依赖 hosted runner 宿主机自带 `glibc` 版本产出最终二进制
- 构建环境必须显式控制到 `glibc 2.28` 附近的容器、sysroot 或等效工具链
- 兼容性判断不能只看“能否编译通过”，还必须结合目标产物的 `GLIBC_*` 符号需求和线下实机验证结果

降级顺序如下：

1. 保留单包交付
2. 保留厚包目标
3. 缩减 `angie-gm-all` 的模块范围
4. 最后才回退到更多系统库依赖

## 5. 文档与发布口径

构建矩阵与验证矩阵分离：

- GitHub Actions：负责 `package x arch x format`
- 线下验证：负责 `package x arch x distro`

正式文档与 Release 说明必须区分：

- `Build Baseline`
- `Verified On`
- `Expected Compatible`

不得把理论兼容写成已验证支持。

## 6. 安装诊断要求

安装、升级、卸载过程必须具备基础诊断能力：

- 输出关键阶段日志
- 输出关键路径
- 输出失败上下文、退出码、建议检查项
- 提示标准自检命令

建议在 `/opt/angie/bin/` 提供统一诊断脚本，例如 `angie-diagnose`。
