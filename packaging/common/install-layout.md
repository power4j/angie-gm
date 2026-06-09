# 安装布局与包行为

## 安装布局

- 程序与私有库：`/opt/angie`
- 主配置：`/etc/angie`
- 日志：`/var/log/angie`
- 缓存：`/var/cache/angie`
- 持久状态：`/var/lib/angie`
- 运行时目录：`/run/angie`

## 单包交付原则

- `angie-gm-basic` 与 `angie-gm-all` 都以单包形式对外交付
- 包内可包含主程序、模块、私有动态库、systemd unit、默认配置模板
- 安装后运行入口不因 edition 变化而变化

## 升级与替换规则

- `angie-gm-basic` 与 `angie-gm-all` 必须允许标准包升级路径替换
- 升级时不得覆盖现场修改过的配置
- 卸载时不得误删用户日志与用户自有数据

## 安装诊断要求

- 维护脚本必须输出关键阶段
- 维护脚本必须输出关键路径
- 失败时必须输出失败上下文与建议检查项
- 安装完成后必须提示标准自检命令
