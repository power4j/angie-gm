# 验证记录：WSL 源码准备与编译骨架链路

## 基本信息

- 验证日期：2026-06-09
- 验证人员：用户在 WSL Ubuntu 24 中执行，结果由当前任务整理
- 包名：`angie-gm-basic`、`angie-gm-all`
- 包版本：TBD
- 打包修订号：TBD
- 架构：`x86_64`
- 发行版：Ubuntu 24（WSL）
- 内核版本：`6.6.87.2-microsoft-standard-WSL2`
- `glibc` 版本：未记录
- 安装包文件名：不适用

## 环境信息

- 主机名：未记录
- CPU：未记录
- systemd 版本：未记录
- 网络条件：可访问 Angie 与 GitHub 公开源码下载地址
- 备注：验证重点为源码准备链路与编译骨架接入，不包含真实编译、打包、安装、服务启动

## 验证前检查

- `bash -n builder/common/*.sh`：通过
- `ldd` / 依赖检查：未执行
- 关键目录状态：仓库可从 `/mnt/d/git-repo/power4j/angie-gm` 访问
- 包管理器版本：未记录

## 安装与升级验证

### 安装

- 执行命令：未执行
- 结果：未执行
- 关键日志：无

### 升级或替换

- 执行命令：未执行
- 结果：未执行
- 关键日志：无

## 服务与配置验证

### 配置检查

- 执行命令：未执行
- 结果：未执行
- 输出摘要：无

### 服务启动

- 执行命令：未执行
- 结果：未执行
- 输出摘要：无

## 协议冒烟验证

### 基础 HTTP

- 执行命令：未执行
- 结果：未执行

### 基础 HTTPS

- 执行命令：未执行
- 结果：未执行

### NTLS / 国密

- 执行命令：未执行
- 结果：未执行

### HTTP/3

- 执行命令：未执行
- 结果：未执行

### stream

- 执行命令：未执行
- 结果：未执行

### 动态模块加载

- 执行命令：未执行
- 结果：未执行

## 源码准备链路验证

### `angie-gm-basic`

- 执行命令：`bash builder/common/build.sh angie-gm-basic`
- 结果：通过到 staging 准备阶段
- 输出摘要：
  - Angie 源码包命中本地缓存
  - Angie SHA256 校验通过
  - Angie 解包通过
  - TongSuo 源码包下载成功
  - TongSuo SHA256 校验通过
  - TongSuo 解包通过
  - staging 目录准备通过

### `angie-gm-all`

- 执行命令：`bash builder/common/build.sh angie-gm-all`
- 结果：通过到 staging 准备阶段
- 输出摘要：
  - Angie 源码包命中本地缓存
  - Angie SHA256 校验通过
  - Angie 解包通过
  - TongSuo 源码包命中本地缓存
  - TongSuo SHA256 校验通过
  - TongSuo 解包通过
  - staging 目录准备通过

## 诊断线索

- 安装脚本阶段日志是否足够：是
- 关键路径输出是否足够：是
- 失败上下文是否足够：是；此前已根据输出定位并修复日志污染问题
- `journalctl -u angie -n 100 --no-pager` 摘要：不适用
- 建议补充项：后续编译阶段需要输出 configure 参数摘要和上游源码目录位置

## 编译骨架链路验证

### `angie-gm-basic`

- 执行命令：`bash builder/common/build.sh angie-gm-basic`
- 结果：通过到编译占位阶段
- 输出摘要：
  - TongSuo 构建目录与安装目录准备通过
  - Angie configure 参数文件生成通过
  - Angie 构建目录准备通过
  - staging 目录准备通过
  - 终点为 `compile and package execution are not implemented yet`

### `angie-gm-all`

- 执行命令：`bash builder/common/build.sh angie-gm-all`
- 结果：通过到编译占位阶段
- 输出摘要：
  - TongSuo 构建目录与安装目录准备通过
  - Angie configure 参数文件生成通过
  - Angie 构建目录准备通过
  - staging 目录准备通过
  - 终点为 `compile and package execution are not implemented yet`

## 结论

- 总体结果：通过源码准备链路与编译骨架链路验证
- 是否可进入下一阶段：可以
- 剩余问题：尚未进入真实编译、打包、安装与服务验证

## TongSuo 真实编译链路验证

### `angie-gm-basic`

- 执行命令：`bash builder/common/build.sh angie-gm-basic`
- 结果：用户反馈命令已跑完，终端未见明显报错，待日志级复核
- 输出摘要：
  - TongSuo 真实编译阶段已接入
  - 编译耗时较长，人工浏览终端输出未见明确失败信号
  - 尚未补充 `configure.log`、`make.log`、`install.log` 的逐项复核结果

### `angie-gm-all`

- 执行命令：`bash builder/common/build.sh angie-gm-all`
- 结果：用户反馈命令已跑完，终端未见明显报错，待日志级复核
- 输出摘要：
  - TongSuo 真实编译阶段已接入
  - 编译耗时较长，人工浏览终端输出未见明确失败信号
  - 尚未补充 `configure.log`、`make.log`、`install.log` 的逐项复核结果

## GitHub Actions 构建骨架验证

### `package x arch x format` 矩阵

- 执行环境：
  - runner：`ubuntu-24.04`、`ubuntu-24.04-arm`
  - container：`almalinux:8`
  - `glibc`：`2.28`
- 执行入口：GitHub Actions `Build Packages`
- 结果：通过
- 输出摘要：
  - `x86_64` / `aarch64` 的 8 个矩阵任务均完成
  - `Install build dependencies` 通过
  - `Verify shell syntax` 通过
  - `Run build pipeline` 通过
  - `output/work/<package>/` 与 `output/staging/<package>/` 可上传为 artifact
  - 当前告警仅剩 GitHub 官方 JavaScript actions 的 Node 20 弃用提示
