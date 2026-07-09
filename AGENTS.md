# AGENTS.md

## 1. 权威资料

资料优先级如下：

1. 本仓库 `docs/public/reference/`
2. 本仓库 `docs/public/architecture/`、`docs/public/packaging/`、`docs/public/release/`、`docs/public/validation/`
3. Angie 官方文档与仓库
4. TongSuo 官方文档与仓库
5. 线下验证记录

若上游文档、现网行为与本仓库正式文档不一致，应先记录差异，再调整实现与文档，不得静默改口径。

## 2. 文档结构

`docs/` 固定采用正式文档与本地过程文档分层：

- `docs/public/`
  - 正式文档，入库。
  - 仅放最终交付、用户可见、可稳定复用的文档。
- `docs/local/`
  - 本地过程文档。
  - 放调研记录、阶段计划、进度跟踪、停点记录等过程内容。
  - 完全不入库，必须通过 `.gitignore` 排除。
  - 如过程内容需要长期协作或对外引用，应整理为正式文档后迁入 `docs/public/`。

子目录职责：

- `docs/public/architecture/`：架构、目录规范、安装布局、edition 设计
- `docs/public/packaging/`：打包策略、依赖策略、包行为约束
- `docs/public/release/`：GitHub Actions、Release、版本发布流程
- `docs/public/validation/`：验证矩阵、验证记录、已验证平台
- `docs/public/reference/`：上游来源、版本基线、补丁、checksums

强制规则：

1. 新文档必须先归类到 `public` 或 `local`，禁止直接放在 `docs/` 根目录。
2. `public` 文档只允许放最终交付、用户可见、可稳定引用的内容。
3. `local` 文档每次结束必须补“当前停点 / 下一步”。
4. `local` 文档不得使用 `git add -f` 强制入库。
5. 新增、移动、归档 `public` 文档后，必须同步更新对应 `README.md` 索引。
6. 每次完成一个明确任务后，应同步更新本地进度跟踪文档；如结论需要入库，应整理后写入 `docs/public/`。

## 3. 目录规范

当前仓库目录职责固定如下：

```text
.github/workflows/   GitHub Actions 工作流
assets/              配置模板、systemd、tmpfiles、示例资源
builder/             构建脚本、profile、构建容器定义
docs/                正式文档；本地过程文档仅在 `docs/local/` 本地维护
output/              本地产物与中间文件，不入库
packaging/           deb/rpm 打包模板与维护脚本
source/              上游源码清单、checksums、patches
tests/               安装包与构建链路级验证
```

约束：

- `builder/` 只放构建逻辑，不放正式文档。
- `packaging/` 只放打包模板与维护脚本，不放临时产物。
- `output/` 是本地构建输出目录，不入库。
- `docs/local/` 是本地过程记录目录，不入库。
- 不得把上游大源码压缩包直接散落到仓库根目录。

## 4. 构建与打包约束

构建链路固定为：

1. `profile` 定义安装包差异
2. 编译并安装到 `staging`
3. 从统一的 `staging` 结果生成 `deb` / `rpm`

约束：

- 对外交付为单包。
- 包名固定为 `angie-gm-basic`、`angie-gm-all`。
- 运行时命令与服务名统一使用 `angie`。
- 固定安装布局如下：
  - 程序与私有库：`/opt/angie`
  - 主配置：`/etc/angie`
  - 日志：`/var/log/angie`
  - 缓存：`/var/cache/angie`
  - 持久状态：`/var/lib/angie`
  - 运行时目录：`/run/angie`
- `angie-gm-basic` 与 `angie-gm-all` 不允许同时安装。
- 两种包必须允许通过标准包升级路径相互替换。
- 升级时不得覆盖现场配置与用户数据。
- 两种包必须与官方 `angie` 包显式冲突，避免与上游仓库安装结果混用。
- 除 `glibc` 外，能稳定自带的依赖应优先随包进入 `/opt/angie/lib`。
- `angie-gm-all` 的动态模块、HTTP/3 相关能力与私有库应从同一运行树打包。
- 不得为了追求“全静态”破坏首发稳定性。
- 首版不默认通过 `Provides: angie` 冒充官方包，仅在明确存在依赖兼容需求时再评估。

降级顺序固定如下：

1. 保留单包交付
2. 保留厚包目标
3. 缩减 `angie-gm-all` 的可选模块
4. 最后才回退到更多系统库依赖

## 5. 发布与部署术语

- 发布：指代码或产物发布到 GitHub，包括 push、merge、tag、GitHub Release。
- 部署：指安装包被安装到目标 Linux 服务器，并完成服务启动、自检与可用性确认。

不得混用“发布”和“部署”。

## 6. 验证策略

构建矩阵与验证矩阵必须分离：

- GitHub Actions 负责按 `package x arch x format` 产包。
- 线下环境负责目标发行版验证。

正式文档必须明确区分：

- `Build Baseline`
- `Verified On`
- `Expected Compatible`

禁止把“理论兼容”写成“已验证支持”。

进度跟踪文档必须明确区分：

- 已完成
- 进行中
- 下一步
- 阻塞项

最低验证项：

- 包可安装、升级、替换、卸载
- `angie -V` 输出正确
- `angie -t` 可执行
- `systemctl start angie` 可启动
- `angie-gm-basic` 验证基础 HTTP/HTTPS 与 NTLS
- `angie-gm-all` 验证 HTTP/3、stream 与至少一个动态模块

## 7. 安装诊断与排错约束

安装、升级、卸载脚本必须具备基础诊断能力。

强制要求：

- 关键阶段必须打印日志，例如目录准备、运行树安装、systemd 注册、依赖检查、配置检查。
- 关键路径必须可见：`/opt/angie`、`/etc/angie`、`/var/log/angie`、`/var/cache/angie`、`/var/lib/angie`、`/run/angie`。
- 失败时必须输出失败阶段、命令上下文、退出码与建议检查项。
- 不得吞错后只返回模糊提示。
- 安装完成后必须提示标准自检命令，例如 `angie -V`、`angie -t`、`systemctl status angie`、`journalctl -u angie -n 100 --no-pager`。
- 新增安装逻辑时，必须同步补充对应的诊断输出。

如项目提供辅助诊断脚本，应优先放在 `/opt/angie/bin/` 下，并在文档中说明用途。

## 8. Git 与产物管理

- 开发前先查看当前工作区状态。
- 不得回退未由当前任务引入的改动。
- 每完成一个明确任务或阶段，必须尽快提交，不得长期积累大量未提交文件。
- 提交应保持聚焦，一个提交只覆盖一组可解释、可回滚的相关改动。
- 提交信息使用英文，描述本次变更意图。
- 未经用户明确确认，不执行远程 push。
- 本地构建产物、中间目录、日志与缓存不得入库。
- 大型归档文件如确需入库，应优先使用 Git LFS。

## 9. 写作与风格

- Markdown 文档使用克制、准确、可扫读的中文技术写法。
- 中文与英文、数字之间保留必要空格。
- 代码字面量、URL、命令、字段名保持原样。
- 不写 AI 署名或生成痕迹。
- 不在正式文档中写未经验证的宣传性结论。

## 10. 修改原则

- 只做与当前任务直接相关的改动。
- 不预先增加未确认的抽象层。
- 发现风险或约束冲突时，先记录并说明，再继续实现。
- 每个改动都应能追溯到明确目标：构建、打包、验证、发布或诊断。
