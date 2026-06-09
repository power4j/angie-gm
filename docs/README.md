# 文档总览

## 简明总结

`docs/` 采用固定两层结构：`public`（正式文档）和 `local`（本地过程文档，除索引外不入库）。
后续新增文档必须先归类，再落盘，避免信息混乱。

## 术语口径

- 发布：指代码或产物发布到 GitHub，包括 push、merge、tag、GitHub Release。
- 部署：指安装包被安装到目标 Linux 服务器，并完成服务启动、自检与可用性确认。

## 目录结构

- `docs/public/`
  - 面向协作与复用的正式文档。
  - 内容要求稳定、可复用、术语统一。
  - 更新时机：里程碑完成、对外行为变更、协作需要同步。
- `docs/local/`
  - 面向本地开发过程的记录文档。
  - 允许阶段性、讨论性、临时性内容。
  - 除索引文件外，不纳入版本库。

## 阅读顺序

1. [docs/README.md](/D:/git-repo/power4j/angie-gm/docs/README.md)
2. [docs/public/README.md](/D:/git-repo/power4j/angie-gm/docs/public/README.md)
3. [docs/local/README.md](/D:/git-repo/power4j/angie-gm/docs/local/README.md)

## 写作规则

1. 新文档先定分类：`public` 或 `local`，禁止直接放在 `docs/` 根目录。
2. `public` 文档禁止写“进行中”“临时方案”“猜测结论”。
3. `local` 文档允许过程记录，但每次结束要补“当前停点 / 下一步”。
4. 跨文档信息优先链接，不复制大段相同内容。
5. 新增、移动、归档后同步更新对应 `README.md` 索引。
