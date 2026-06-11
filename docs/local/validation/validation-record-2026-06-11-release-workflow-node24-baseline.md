# `Release Packages` `Node 24` action 基线 dry-run 记录

## 基本信息

- 验证日期：`2026-06-11`
- 验证人员：Codex
- 仓库：`power4j/angie-gm`
- 分支基线：`main` / `dev`
- 验证对象：`Release Packages` GitHub Actions workflow
- 验证目标：
  - 确认 action 版本升级后，`Release Packages` 仍可完成全矩阵重构建
  - 确认 `assemble-release` 可完成 release payload 汇总
  - 确认手工 prerelease 仍可创建 `draft + prerelease` release

## 触发输入

- workflow：`Release Packages`
- 触发方式：`workflow_dispatch`
- `package_version`：`0.1.0~rc3`
- `release_tag`：`v0.1.0-rc3`
- `package_release`：`1`
- run id：`27336252425`

## 验证结果

### GitHub Actions

- 8 个 `release-build-*` 矩阵 job：全部通过
- `assemble-release`：通过
- 总体结果：通过

### Release 结果

- GitHub Release：已创建
- title：`Review 0.1.0 RC3`
- tag：`v0.1.0-rc3`
- 状态：`draft + prerelease`

### Release 资产

- `angie-gm-basic-0.1.0-rc3-1.x86_64.rpm`
- `angie-gm-basic-0.1.0-rc3-1.aarch64.rpm`
- `angie-gm-basic_0.1.0-rc3-1_amd64.deb`
- `angie-gm-basic_0.1.0-rc3-1_arm64.deb`
- `angie-gm-all-0.1.0-rc3-1.x86_64.rpm`
- `angie-gm-all-0.1.0-rc3-1.aarch64.rpm`
- `angie-gm-all_0.1.0-rc3-1_amd64.deb`
- `angie-gm-all_0.1.0-rc3-1_arm64.deb`
- `BUILD-INFO.txt`
- `sha256sum.txt`

## 结论

- 当前 `Release Packages` 已在升级后的 action 基线下恢复为可用状态。
- `checkout`、`upload-artifact`、`download-artifact` 与 `softprops/action-gh-release` 的升级未引入发布链路退化。
- 当前主线可以继续使用 `workflow_dispatch -> draft prerelease` 路径生成 review 包。

## 当前停点 / 下一步

- 当前停点：`Release Packages` 已完成升级后 dry-run 验证。
- 下一步：规划银河麒麟服务器版 V10 / 统信服务器版 V10 的线下验证批次，并决定是否补充当前 review release 的人工验证摘要。
