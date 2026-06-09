# 版本策略

## 1. 版本分层

本项目的版本号分为三层：

1. 包版本
2. 打包修订号
3. 上游源码版本

三者职责不同，不得混用。

## 2. 包版本

包版本用于表达本项目对外发布的安装包语义版本。

规则：

- 使用 `MAJOR.MINOR.PATCH` 格式
- 初期开发阶段从 `0.x.y` 开始
- 只在对外交付行为变化时递增

示例：

- `0.1.0`
- `0.2.0`
- `0.2.1`

适用范围：

- `angie-gm-basic`
- `angie-gm-all`

同一次发布中的两个包共享同一包版本。

补充说明：

- `package_version` 是构建与发布流程中的权威输入字段。
- 正式发布时，`package_version` 由正式 tag 去掉前缀 `v` 得到。
- 手工触发 review 发布时，`package_version` 由 `workflow_dispatch` 显式输入，不做隐式推断。
- `package_version` 只表达包版本，不承担 GitHub Release tag 的推导职责。

建议：

- 正式版使用 `0.1.0`、`0.2.0`
- review 版使用 `0.1.0~rc1`、`0.1.0~rc2`

约束：

- 不得从分支名猜测 `package_version`
- 不得在没有明确版本号的情况下手工发布 review 包
- 不得从 `package_version` 字符串内容推导 `prerelease` 状态
- 不得从 `package_version` 字符串内容推导 `release_tag`

## 2.1 Release Tag

`release_tag` 用于表达 GitHub Release 与 Git tag 标识。

规则：

- 正式发布使用 `v<package-version>`
- review 发布使用显式输入的 tag，例如 `v0.1.0-rc1`
- `release_tag` 与 `package_version` 必须各自明确，不得相互猜测

示例：

- `package_version=0.1.0` -> `release_tag=v0.1.0`
- `package_version=0.1.0~rc1` -> `release_tag=v0.1.0-rc1`

## 3. 打包修订号

打包修订号用于表达在同一包版本下的重新打包次数。

规则：

- `rpm` 使用 `Release`
- `deb` 使用修订号
- 从 `1` 开始递增
- 仅在打包逻辑、安装脚本、配置保留策略、诊断输出等发生变化时递增

示例：

- `angie-gm-basic-0.1.0-1.x86_64.rpm`
- `angie-gm-basic_0.1.0-1_amd64.deb`

补充说明：

- `package_release` 是构建与发布流程中的打包修订输入字段。
- `package_release` 不表达功能代际，只表达同一 `package_version` 下的重新打包次数。

判断原则：

- 对外交付语义变化，提升 `package_version`
- 仅打包实现、安装脚本、诊断输出等修复，提升 `package_release`

## 4. 上游源码版本

上游源码版本仅用于锁定 Angie 与 TongSuo 的来源版本，不作为本项目包版本的一部分。

当前规则：

- Angie 版本由 `source/manifests/angie.json` 定义
- TongSuo 版本由 `source/manifests/tongsuo.json` 定义
- 版本升级必须通过修改 manifest 与 checksum 完成

不得：

- 在 workflow 输入中临时手填正式发布版本
- 在构建脚本中硬编码上游版本
- 在包文件名中直接拼接上游版本

## 5. 构建时版本来源

正式构建时版本来源固定如下：

- 包版本：由项目发布策略统一指定
- 打包修订号：由打包模板或发布流程指定
- 上游源码版本：只从 `source/manifests/*.json` 读取

构建顺序建议：

1. 读取 Angie manifest
2. 读取 TongSuo manifest
3. 下载或定位指定版本源码包
4. 使用 `source/checksums/upstream.sha256` 校验
5. 应用补丁
6. 进入编译与打包

## 6. 文件命名建议

最终对外交付文件建议遵循：

- `angie-gm-basic-<package-version>-<release>.<arch>.rpm`
- `angie-gm-all-<package-version>-<release>.<arch>.rpm`
- `angie-gm-basic_<package-version>-<revision>_<arch>.deb`
- `angie-gm-all_<package-version>-<revision>_<arch>.deb`

示例：

- 正式版：
  - `angie-gm-basic-0.1.0-1.x86_64.rpm`
  - `angie-gm-basic_0.1.0-1_amd64.deb`
- review 版：
  - `angie-gm-basic-0.1.0~rc1-1.x86_64.rpm`
  - `angie-gm-basic_0.1.0~rc1-1_amd64.deb`

上游版本应放入以下位置，而不是文件名：

- `source/manifests/*.json`
- GitHub Release 说明
- 构建元数据，例如 `.buildinfo`
- `angie -V` 扩展输出

## 7. 版本升级约束

升级上游版本时，至少同步修改：

- 对应 manifest
- `source/checksums/upstream.sha256`
- 相关验证记录

如上游版本变化导致功能或兼容性变化，应评估是否提升本项目包版本，而不仅仅是打包修订号。

常见场景建议：

- 升级 Angie / TongSuo 且影响交付结果：提升 `package_version`
- 调整 `basic` / `all` 的能力集合：提升 `package_version`
- 修复安装脚本、打包模板、systemd 集成、诊断输出：提升 `package_release`

## 8. 构建 ABI 基线

当前确认：

- `Build Baseline`: `glibc 2.28`

约束：

- 包版本升级或上游版本升级时，不得静默抬高 `glibc` 运行时要求。
- GitHub Actions 的构建环境选择必须服从该基线，而不是服从 hosted runner 的默认系统版本。
- 如后续新增目标平台或发现基线变化，应同步更新正式文档、验证记录与构建环境定义。
