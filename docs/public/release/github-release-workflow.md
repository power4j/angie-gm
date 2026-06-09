# GitHub Release 工作流

## 1. 目标

本工作流负责在 GitHub Actions 中重新构建正式发布产物，并把最终包文件上传到 GitHub Release。

当前原则：

- `Build Packages` 用于持续集成与日常产包验证
- `Release Packages` 用于正式发布或发布前 dry-run
- Release 阶段不依赖前一个 workflow 的临时 artifact，而是基于当前 tag 或手工输入重新构建

## 2. 触发方式

支持两种触发方式：

### tag 触发

- 条件：push `v*` tag
- 示例：`v0.1.0`
- 行为：
  - 重新构建 `angie-gm-basic` / `angie-gm-all`
  - 覆盖 `x86_64` / `aarch64`
  - 同时生成 `rpm` / `deb`
  - 汇总到 `output/release/`
  - 创建或更新 GitHub draft release

### 手工触发

- 入口：`workflow_dispatch`
- 可选输入：
  - `package_version`
  - `package_release`
- 用途：
  - 发布前 dry-run
  - 不打 tag 的流程调试
  - 重打同一版本的发布链路验证

## 3. 版本来源

Release workflow 使用以下规则：

- `package_version`
  - tag 触发：从 tag 名去掉前缀 `v` 得到
  - 手工触发：优先使用 `workflow_dispatch` 输入
- `package_release`
  - 默认值：`1`
  - 手工触发时可覆盖

上游版本仍只从以下文件读取：

- `source/manifests/angie.json`
- `source/manifests/tongsuo.json`

## 4. 构建矩阵

Release workflow 当前矩阵固定为：

- package
  - `angie-gm-basic`
  - `angie-gm-all`
- arch
  - `x86_64`
  - `aarch64`
- format
  - `rpm`
  - `deb`

构建环境固定为：

- runner
  - `ubuntu-24.04`
  - `ubuntu-24.04-arm`
- container
  - `almalinux:8`

目的：

- 继续服从 `glibc 2.28` 的构建 ABI 基线

## 5. 产物汇总

Release workflow 在矩阵构建完成后汇总以下内容：

- 所有 `.rpm`
- 所有 `.deb`
- `sha256sum.txt`
- `BUILD-INFO.txt`

当前对外交付命名：

- `angie-gm-basic-<version>-<release>.<arch>.rpm`
- `angie-gm-all-<version>-<release>.<arch>.rpm`
- `angie-gm-basic_<version>-<release>_<arch>.deb`
- `angie-gm-all_<version>-<release>_<arch>.deb`

## 6. 当前限制

当前 workflow 已可用于：

- dry-run 构建
- draft release 构建
- package asset 上传

当前仍未覆盖：

- 线下验证结论自动注入 release notes
- 平台兼容性说明自动注入 release notes
- GPG 签名
- SBOM
- 包签名校验链

## 7. 使用建议

正式发布建议顺序：

1. `Build Packages` 持续集成通过
2. 线下验证记录更新
3. 打 `v<package-version>` tag
4. 等待 `Release Packages` 完成
5. 人工检查 draft release
6. 人工发布
