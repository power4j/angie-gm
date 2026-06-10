# Packaging Implementation Plan

**Goal:** 从统一 `staging` 运行树产出可上传的 `angie-gm-basic` / `angie-gm-all` 单包 `rpm` 与 `deb`。

**Architecture:** 构建链路继续保持 `source -> compile -> staging -> package`。本阶段新增一个薄的 `assemble-runtime` 步骤，把私有库、默认配置、systemd、tmpfiles 与诊断脚本整理进 `staging`，再分别调用 `rpm` / `deb` 打包器生成最终产物。

**Tech Stack:** Bash、`rpmbuild`、`dpkg-deb`、GitHub Actions、AlmaLinux 8 容器。

## File Structure

- `builder/common/assemble-runtime.sh`
  - 负责把 Angie、TongSuo 与仓库资产整理到统一 `staging`。
- `builder/common/package-rpm.sh`
  - 负责从 `staging` 生成单包 `rpm`。
- `builder/common/package-deb.sh`
  - 负责从 `staging` 生成单包 `deb`。
- `builder/common/build.sh`
  - 串起运行树装配与打包阶段。
- `assets/config/`
  - 默认配置模板。
- `assets/systemd/`
  - `angie.service` 模板。
- `assets/tmpfiles/`
  - 运行目录与日志目录的 `tmpfiles.d` 配置。
- `assets/examples/basic/`、`assets/examples/all/`
  - edition 相关示例配置。
- `assets/diagnostics/`
  - 随包交付的诊断脚本。
- `packaging/rpm/`
  - `spec` 模板或脚本辅助文件。
- `packaging/deb/`
  - `control`、`conffiles`、维护脚本模板。
- `.github/workflows/build.yml`
  - 安装打包依赖并上传真正的包文件。
- `docs/public/tracking/STATUS.md`
  - 记录阶段状态。
- `docs/public/validation/validation-record-2026-06-09-wsl-source-prep.md`
  - 追加阶段验证结果。

## Tasks

### Task 1: Runtime Assembly

- [ ] 补 `assets/` 最小运行素材：默认配置、systemd、tmpfiles、诊断脚本、示例配置。
- [ ] 新增 `builder/common/assemble-runtime.sh`，把 Angie 安装结果、TongSuo 私有库和仓库资产装配到 `staging`。
- [ ] 运行本地 `build.sh`，确认 `staging` 内不再只有空目录。
- [ ] 提交一次聚焦于运行树装配的 commit。

### Task 2: Package Builders

- [ ] 新增 `builder/common/package-rpm.sh`，使用 `rpmbuild` 从 `staging` 生成单包 `rpm`。
- [ ] 新增 `builder/common/package-deb.sh`，使用 `dpkg-deb` 从 `staging` 生成单包 `deb`。
- [ ] 在 `build.sh` 中根据目标格式调用对应打包器，并把产物落到 `output/packages/`。
- [ ] 提交一次聚焦于打包器的 commit。

### Task 3: CI Integration And Validation

- [ ] 更新 `.github/workflows/build.yml`，安装打包依赖并上传包产物 artifact。
- [ ] 推送到 `jc/kickoff`，观察 8 个矩阵作业。
- [ ] 更新 `STATUS.md` 与验证记录，明确“真实编译已通过、真实产包结果如何”。
- [ ] 提交一次聚焦于 CI 与文档的 commit。
