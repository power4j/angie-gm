# 源码来源管理

`source/` 用于管理上游源码的来源声明、校验信息与补丁，不默认存放源码包本体。

## 目录说明

- `manifests/`
  - 上游组件的来源声明。
  - 当前组件：`angie`、`tongsuo`
- `checksums/`
  - 源码包校验值。
  - 使用标准 `sha256sum` 兼容格式
- `patches/`
  - 按上游组件拆分的补丁目录

## 基本规则

1. 默认构建方式为：根据 manifest 下载公开源码包，再做 checksum 校验。
2. 本地可预置源码包到缓存目录，例如 `source/downloads/`，但该目录不入库。
3. 不使用 Git submodule 管理 Angie 或 TongSuo 源码。
4. 正式文档与 manifest 优先记录公开可访问的上游来源。
5. 补丁属于上游组件，不属于安装包 edition。

## 构建时推荐顺序

1. 读取 `source/manifests/*.json`
2. 查找本地缓存
3. 从 `upstream_url` 下载源码包
4. 使用 `source/checksums/upstream.sha256` 校验
5. 应用 `source/patches/<component>/` 下的补丁
6. 进入构建与 staging

## 当前状态

- manifest 模型已建立
- checksum 文件格式已建立
- 具体 SHA256 值待在首次拉取上游源码包后补齐
