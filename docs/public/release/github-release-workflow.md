# GitHub Release 工作流

## 1. 目标

本工作流负责在 GitHub Actions 中重新构建正式发布产物，并把最终包文件上传到 GitHub Release。

当前原则：

- `Build Packages` 用于持续集成与日常产包验证
- `Release Packages` 用于正式发布或发布前 dry-run
- Release 阶段不依赖前一个 workflow 的临时 artifact，而是基于当前 tag 或手工输入重新构建
- `Build Packages` 的 workflow artifact 只作为 CI 调试产物，不作为正式线下验证输入
- 线下验证、交付验证与回归验证统一使用 GitHub Release asset
- 所有 Release 均先创建 `draft`
- 手工触发的 Release 固定为 `prerelease`
- 正式 tag 触发的 Release 固定为稳定版候选，不标记 `prerelease`

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
  - Release 不标记为 `prerelease`

### 手工触发

- 入口：`workflow_dispatch`
- 必填输入：
  - `package_version`
  - `release_tag`
- 可选输入：
  - `package_release`
- 用途：
  - 发布前 dry-run
  - review 包交付
  - `prerelease` 发布链路验证

约束：

- 手工触发时必须显式填写 `package_version`
- 手工触发时必须显式填写 `release_tag`
- 不从分支名或目录状态推导版本号
- 不从 `package_version` 推导 `release_tag`
- 手工触发生成的 GitHub Release 固定标记为 `draft + prerelease`

建议：

- review 版本使用 `0.1.0~rc1`、`0.1.0~rc2`
- review tag 使用 `v0.1.0-rc1`、`v0.1.0-rc2`
- 对外 Release 标题与附件文件名使用不含 `~` 的展示形式，例如 `0.1.0 RC1`、`0.1.0-rc1`

## 3. 版本来源

Release workflow 使用以下规则：

- `package_version`
  - tag 触发：从 tag 名去掉前缀 `v` 得到
  - 手工触发：必须使用 `workflow_dispatch` 输入
- `release_tag`
  - tag 触发：直接使用触发 tag
  - 手工触发：必须使用 `workflow_dispatch` 输入
- `package_release`
  - 默认值：`1`
  - 手工触发时可覆盖

对外展示规则：

- review release title 使用 `release_tag` 派生展示名，例如 `Review 0.1.0 RC1`
- review release asset filename 使用 `release_tag` 派生展示版本，例如 `0.1.0-rc1`
- 包内部版本与 `BUILD-INFO.txt` 仍保留 `package_version` 原值，例如 `0.1.0~rc1`

当前发布状态约定：

- `workflow_dispatch` -> `draft prerelease`
- `push v<package-version>` -> `draft stable`

说明：

- `draft` 表示产物与说明仍可人工检查
- `prerelease` 表示 review / rc 版本，不作为稳定交付口径
- 正式稳定版由人工在 GitHub 页面发布 draft release

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

review 发布时的展示示例：

- Release title：`Review 0.1.0 RC1`
- Release asset filename：
  - `angie-gm-basic-0.1.0-rc1-1.x86_64.rpm`
  - `angie-gm-basic_0.1.0-rc1-1_amd64.deb`

## 6. 当前限制

当前 workflow 已可用于：

- dry-run 构建
- draft release 构建
- package asset 上传
- 线下验证输入统一固化为 release asset

当前仍未覆盖：

- 线下验证结论自动注入 release notes
- 平台兼容性说明自动注入 release notes
- GPG 签名
- SBOM
- 包签名校验链

## 7. 使用建议

review 发布建议顺序：

1. `Build Packages` 持续集成通过
2. 在 `Release Packages` 中手工触发 `workflow_dispatch`
3. 填写 `package_version`，例如 `0.1.0~rc1`
4. 填写 `release_tag`，例如 `v0.1.0-rc1`
5. 按需调整 `package_release`
6. 等待 workflow 完成
7. 从 draft prerelease 下载 release asset
8. 基于 release asset 执行线下验证
9. 人工检查 draft prerelease
10. 人工发布 prerelease

正式发布建议顺序：

1. `Build Packages` 持续集成通过
2. 线下验证记录更新
3. 打 `v<package-version>` tag
4. 等待 `Release Packages` 完成
5. 从 draft stable release 下载 release asset
6. 基于 release asset 执行最终交付验证
7. 人工检查 draft stable release
8. 人工发布 stable release

## 8. 验证输入边界

当前必须区分两类下载来源：

- workflow artifact
  - 来源：`Build Packages`
  - 用途：CI 调试、构建问题定位、运行树排错
  - 特点：生命周期短，不作为正式交付口径
- release asset
  - 来源：`Release Packages`
  - 用途：线下安装验证、替换验证、回归验证、最终交付
  - 特点：与版本、tag、release notes 绑定，可作为正式验证输入

禁止做法：

- 不得把某次 `Build Packages` 的 workflow artifact 直接当作正式交付包
- 不得在线下验证记录中把 workflow artifact 写成正式发布产物
