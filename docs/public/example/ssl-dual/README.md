# 双证书示例

`docs/public/example/ssl-dual/` 给出 `demo.example.com` 的最小双证书示例。

示例只负责打开默认欢迎页，不包其他站点逻辑。

## 目录

- `demo.example.com.conf`
- `ssl-cert/sm2/`
- `ssl-cert/rsa/`

## 配置口径

- `38080` 提供 HTTP
- `38443` 提供 HTTPS
- 默认静态页来自 `/opt/angie/share/html/index.html`

## 部署说明

1. 将 `ssl-cert/` 复制到 `/etc/angie/ssl-cert/`
2. 将 `demo.example.com.conf` 放入 `/etc/angie/conf.d/`
3. 确认 `/opt/angie/share/html/index.html` 已由安装包提供
4. 执行 `sudo angie -t`
5. 执行 `sudo systemctl restart angie`

## 访问方式

- `http://demo.example.com:38080/`
- `https://demo.example.com:38443/`

如需本机测试，可先在 `hosts` 中把 `demo.example.com` 指向目标主机地址。
