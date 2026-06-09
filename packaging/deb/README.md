# Debian 打包模板方向

当前目录用于放置 `deb` 打包模板。当前阶段只固化模板方向，不写完整 `debian/` 文件集。

## 预期包标识

- `Package: angie-gm-basic`
- `Package: angie-gm-all`

## 预期关系字段

`angie-gm-basic`：

- `Conflicts: angie, angie-gm-all`
- `Replaces: angie`

`angie-gm-all`：

- `Conflicts: angie, angie-gm-basic`
- `Replaces: angie`

## 后续文件方向

- `control`
- `rules`
- `postinst`
- `prerm`
- `postrm`
- `conffiles` 或等价配置策略说明
