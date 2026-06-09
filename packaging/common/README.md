# 打包模板骨架

`packaging/` 用于维护 `deb` / `rpm` 打包模板，不放构建中间产物。

## 设计边界

- 对外交付为单包
- 安装包名称固定为 `angie-gm-basic`、`angie-gm-all`
- 运行时命令固定为 `angie`
- 服务名固定为 `angie.service`
- 安装前缀固定为 `/opt/angie`
- 配置与数据目录分离

## 冲突策略

- `angie-gm-basic` 与 `angie-gm-all` 不允许同时安装
- 两者都必须与官方 `angie` 包显式冲突
- 首版不默认使用 `Provides: angie`
- 仅在后续出现明确依赖兼容需求时，再评估是否补 `Provides`

## 模板职责

- `common/`
  - 放共享规则说明、布局说明、维护脚本约束
- `deb/`
  - 放 `debian/` 相关模板与维护脚本
- `rpm/`
  - 放 `.spec` 与相关维护脚本模板
