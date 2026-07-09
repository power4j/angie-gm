# 文档总览

`docs/` 仅用于组织正式文档。

## 目录结构

- `docs/public/`
  - 正式文档。
  - 面向最终交付、用户可见与外部引用。
- `docs/local/`
  - 本地过程文档。
  - 默认不入库，仅用于本地过程记录、阶段计划与进度跟踪。

## 术语口径

- 发布：指代码或产物发布到 GitHub，包括 push、merge、tag、GitHub Release。
- 部署：指安装包被安装到目标 Linux 服务器，并完成服务启动、自检与可用性确认。

## 阅读顺序

1. [docs/README.md](/D:/git-repo/power4j/angie-gm/docs/README.md)
2. [docs/public/README.md](/D:/git-repo/power4j/angie-gm/docs/public/README.md)

## 说明

- 正式协作与对外引用，优先使用 `docs/public/`。
- 过程记录、临时计划与阶段跟踪，仅保留在本地 `docs/local/`，不纳入 Git 跟踪。
