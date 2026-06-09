# RPM 打包模板方向

当前目录用于放置 `rpm` 打包模板。当前阶段只固化模板方向，不写完整 `.spec` 细节。

## 预期包标识

- `Name: angie-gm-basic`
- `Name: angie-gm-all`

## 预期关系字段

`angie-gm-basic`：

- `Conflicts: angie`
- `Conflicts: angie-gm-all`
- `Obsoletes: angie`

`angie-gm-all`：

- `Conflicts: angie`
- `Conflicts: angie-gm-basic`
- `Obsoletes: angie`

## 后续文件方向

- `angie-gm-basic.spec`
- `angie-gm-all.spec`
- 共享 `%post` / `%preun` / `%postun` 逻辑说明
- 配置保留策略说明
