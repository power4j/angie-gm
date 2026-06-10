# 项目进度状态

最后更新：`2026-06-10`
当前分支：`kickoff`

## 已完成

- 仓库初始化完成
- Git 仓库已建立
- `kickoff` 分支已建立
- 项目规范已建立
- `docs/public` / `docs/local` 文档体系已建立
- 安装布局、命名基线、发布口径、诊断要求已固化
- 安装包命名已收敛为 `angie-gm-basic` / `angie-gm-all`
- `source/README.md`、manifest 模型与 checksum 文件格式已建立
- `angie-gm-basic` / `angie-gm-all` 的 profile 字段模型已建立
- `deb` / `rpm` 的打包模板骨架与冲突策略已建立
- 共享构建脚本骨架与阶段日志模型已建立
- GitHub Actions 的构建矩阵与 Release workflow 骨架已建立
- 已完成一次 `gh` 只读检查尝试，并确认当前本机 GitHub CLI 环境不可用
- 包版本、打包修订号、上游源码版本的分层策略已建立
- 验证矩阵与验证记录模板已建立
- WSL Ubuntu 24 已验证 `builder/common/*.sh` 可通过 `bash -n`，且两个 profile 可跑到 staging 准备阶段
- 已定位真实源码准备链路中的日志污染问题，原因是命令替换返回值混入了标准输出日志
- Angie 与 TongSuo 公开源码包的真实 SHA256 已补齐
- WSL Ubuntu 24 已验证 Angie 与 TongSuo 的真实源码下载、checksum、解包与 staging 准备链路通过
- TongSuo 构建骨架与 Angie configure 参数骨架已接入本地构建脚本
- WSL Ubuntu 24 已验证 `angie-gm-basic` 与 `angie-gm-all` 可稳定跑通到编译占位阶段，`build/angie` 目录创建问题已修复
- 已确认银河麒麟与统信目标机的 `glibc` 为 `2.28`
- `glibc 2.28` 已收敛为当前正式的 `Build Baseline`
- GitHub Actions 已切换为固定 runner + `glibc 2.28` 基线容器方案
- 已确认 GitHub Actions 的 `ubuntu-24.04-arm` 与 `almalinux:8` 容器可启动，当前失败点定位为 `dnf` 依赖冲突
- 已定位 GitHub Actions 构建脚本的下一处失败点：容器缺少 `python3`，导致 manifest 解析失败
- GitHub Actions 最新一轮已通过 `Install build dependencies`、`Verify shell syntax` 与 `Run build pipeline` 阶段，说明当前 CI 构建骨架已在 `x86_64` / `aarch64` 上跑通
- GitHub Actions `Build Packages` 已在 `x86_64` / `aarch64`、`deb` / `rpm` 全矩阵完成，当前剩余 CI 问题仅为 Node 20 actions 弃用告警
- Angie 真实 `configure` / `make` / `install` 已接入本地构建脚本，等待下一轮 GitHub Actions 验证真实编译结果
- 已定位 Angie 真实编译的首个错误：`--builddir` 与 `make` 执行目录不一致，导致 `No rule to make target 'src/core/ngx_build.c'`
- 真实源码编译已在 GitHub Actions 全矩阵跑通，当前进入 `staging` 运行树装配与真产包阶段
- `assemble-runtime` 已在 GitHub Actions 全矩阵通过，当前首个真产包阻塞点已定位为 `almalinux:8` 仓库不提供 `dpkg`
- 已改为使用 `ar + tar` 手工生成 `.deb`，GitHub Actions 最新一轮已在 `deb` / `rpm` 全矩阵完成真实产包并上传包 artifact
- 已移除 RPM 文件名中的 `.el8` 后缀，正式外发命名回到 `edition + version + release + arch`
- `Release Packages` 已完成一次 `workflow_dispatch` dry-run，确认 8 个矩阵重构建与 release payload 汇总链路可用
- `Release Packages` 已收敛为两条正式发布路径：`workflow_dispatch -> draft prerelease` 与 `push tag -> draft stable`
- 手工触发的 `package_version` 已改为必填，版本职责与 `package_release` 分工已写入正式文档
- `Release Packages` 已完成一次真实 `workflow_dispatch prerelease` 验证，确认可创建 `draft + prerelease` release，并正确生成 `Review 0.1.0~rc1` 与 tag `v0.1.0-rc1`
- `Release Packages` 已完成 `package_version` 与 `release_tag` 解耦，手工 prerelease 的 tag 不再从版本字符串派生
- `Release Packages` 已完成一次解耦后实测，确认 `package_version=0.1.0~rc2` 与 `release_tag=v0.1.0-rc2` 可独立输入并成功生成 `draft + prerelease`
- `Release Packages` 已完成对外展示优化：review release title 与附件文件名不再使用 `~`
- `Release Packages` 已完成一次对外展示优化实测，确认 `Review 0.1.0 RC4` 与 `angie-gm-basic_0.1.0-rc4-1_amd64.deb` 等附件命名可稳定生成
- 已补充线下验证最小执行框架，包括包级验证脚本、基础 HTTP 冒烟脚本与线下执行说明
- 验证矩阵与验证记录模板已补充线下执行入口、`glibc` 检查项与升级保留结果字段
- 已完成验证资料分层收缩：正式文档仅保留稳定验证口径，线下执行说明与记录模板已迁入 `docs/local/validation/`
- 已完成 WSL / GitHub Actions 验证记录迁移，`docs/public/validation/` 不再存放过程性验证记录
- 已在 Debian 12 测试机完成一次 GitHub Release 官方 `deb` 包安装验证，确认安装成功且 `angie -V` 输出来自 GitHub Actions 产物
- 已定位官方 `deb` 包当前首个运行时兼容问题：默认用户组回退到 `nobody`，在 Debian 12 上因缺少 `nobody` 组导致 `angie -t` 失败
- 已收敛修复方案：统一改为创建并使用专用运行账户 `angie:angie`
- 已完成官方 `rc5` `deb` 复测，确认 `angie -t` 已恢复通过
- 已定位官方 `rc5` 当前新的启动失败根因：安装脚本未执行 `systemctl daemon-reload`，导致 `systemd` 继续使用旧 unit 缓存
- 已完成官方 `rc6` `deb` 在 Debian 12 上的冷安装、自检、启动与卸载验证
- 已确认 `angie:angie` 运行账户与 `systemd daemon-reload` 修复已在 GitHub 官方产包中生效
- 已定位线下验证脚本当前缺口：`install` 模式未先清理同名已安装包，可能误把升级场景当作冷安装验证
- 已确定 `angie-gm-basic` 默认欢迎站点口径：`/etc/angie/conf.d/welcome.conf` + `/opt/angie/share/html/index.html`
- 已确认 `angie-gm-all` 也应复用同一套默认欢迎站点资源
- 已完成官方 `rc7` `deb` 在 Debian 12 上的 `basic` / `all` 默认欢迎站点验证
- 已确认 `basic` / `all` 官方包均可通过基础 HTTP 欢迎页正文校验
- 已在 Rocky Linux 10.2 上定位官方 `rc7` `rpm` 的首个运行时缺口：二进制依赖 `libcrypt.so.1`，而系统仅提供 `libcrypt.so.2`
- 已定位 Rocky Linux 10.2 上 `rpm` 包的第二个启动缺口：`/run/angie` 同时由 `tmpfiles.d` 与 `systemd RuntimeDirectory` 管理，导致 `status=233/RUNTIME_DIRECTORY`
- 已确认仅保留 `RuntimeDirectory` 不可接受：会破坏安装后直接执行 `angie -t`，因为 `pid` 路径 `/run/angie/angie.pid` 不存在
- 已完成 `/run/angie` 管理机制收敛：保留 `tmpfiles.d`，移除 `systemd RuntimeDirectory`
- 已完成 Rocky Linux 10.2 上 `basic` / `all` `rpm` 回归验证，确认安装、自检、启动、欢迎页链路通过
- 已完成 Debian 12 上 `basic` / `all` `deb` 回归验证，确认 `/run/angie` 修复未引入退化
- 已补 `angie-gm-all` 的专项验证脚本骨架：动态模块、stream、HTTP/3
- 已更新线下执行说明，纳入 `angie-gm-all` 专项冒烟入口与当前边界
- 已完成 `angie-gm-all` 第一轮专项验证：
  - `stream` 在 Rocky Linux 10.2 与 Debian 12 上通过
  - `modules` 在 Rocky Linux 10.2 与 Debian 12 上失败，当前包内没有动态模块文件
  - `http3` 在 Rocky Linux 10.2 与 Debian 12 上失败，原脚本最小配置缺少 TLS 证书上下文
- 已定位 `angie-gm-all` 最新 GitHub 构建失败根因：Angie 1.11.6 不支持 `http_realip`、`http_auth_request`、`http_slice` 的 `=dynamic` 形式；当前应仅保留 `stream` 与 `mail` 作为动态模块入口
- 已定位 `angie-gm-all` 第二轮线下专项验证问题：
  - Debian 12 上 `modules.sh` 的失败根因是临时测试配置未声明 `user angie angie`，触发默认 `nobody` 账户解析错误
  - Rocky Linux 10.2 上 `stream.sh` 的失败根因是 `all` 包默认运行树未自动加载 `ngx_stream_module.so`
- 已完成 Debian 12 上 `angie-gm-all` 第三轮专项复测：
  - `modules.sh` 通过
  - `stream.sh` 通过
  - `http3.sh` 通过
- 已确认 `http3.sh` 的真实问题不是 HTTP/3 功能缺失，而是临时测试配置未对齐实际运行树；补齐 `user angie angie`、`modules.d` 引入与临时证书生成后已恢复
- 已收敛验证输入口径：`Build Packages` 的 workflow artifact 仅用于 CI 调试；线下验证、替换验证与交付验证统一改为使用 GitHub Release asset

## 进行中

- 完成 `angie-gm-all` 在 Rocky Linux 10.2 上的新 RPM 专项复测

## 下一步

1. 触发或复用对应版本的 GitHub Release，并以 release asset 作为 Rocky Linux 10.2 的验证输入
2. 在 Rocky Linux 10.2 上复测 `modules.sh`、`stream.sh`、`http3.sh`
3. 明确 `dpkg -P` / `rpm -e` 后 `/opt/angie`、`/var/log/angie` 残留是否接受
4. 规划银河麒麟 V10 / 统信 V10 的线下验证批次

## 阻塞项

- 当前 Windows 环境没有可用的 Bash / WSL 运行时，无法在本机完成 `builder/common/*.sh` 的语法检查与执行验证
- Codex 当前 shell 环境下执行 `gh` 校验失败；该现象与用户本机终端结果不一致，应按环境差异处理，不应视为仓库或账号本身异常

## 最近提交

- `336300e` `feat: wire source preparation checks`
- `96856c3` `feat: prepare real source fetch pipeline`
- `9d96f31` `docs: add validation tracking skeleton`
- `d327246` `ci: scaffold build and release workflows`
- `1bee7ce` `feat: scaffold build helper scripts`
- `3c9e34e` `docs: define packaging template skeleton`
- `287939b` `docs: define build profile model`
- `86dab56` `docs: define source manifest model`
- `908e238` `docs: clarify build environment`
- `a7121bb` `docs: align package naming baseline`
- `71acf14` `chore: initialize packaging repository`

## 维护规则

1. 每次完成一个明确任务后，必须更新本文件。
2. `已完成` 只记录已提交的结果。
3. `进行中` 只保留当前真正正在推进的事项。
4. `下一步` 保持 1 到 3 条，按优先级排序。
5. 如出现依赖外部条件的问题，写入 `阻塞项`。
