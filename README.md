# Squid Proxy

An Alpine-based Squid forward proxy with password authentication. It listens on port `3128`, permits public HTTP/HTTPS destinations, and disables response caching.

## Run locally

Build the image:

```bash
docker build --platform linux/amd64 -t squid-proxy .
```

Create a password file for `proxyuser`. The command prompts for a password:

```bash
mkdir -p secrets
docker run --rm -i alpine:latest \
  sh -c 'apk add --no-cache apache2-utils >&2 && exec htpasswd -nB proxyuser' \
  > secrets/squid-passwd
chmod 700 secrets
chmod 644 secrets/squid-passwd
```

Keep `secrets/` out of Git and the Docker build context.

```bash
docker run -d --name squid-proxy --platform linux/amd64 \
  -p 127.0.0.1:3128:3128 \
  --mount "type=bind,src=$(pwd)/secrets/squid-passwd,dst=/run/secrets/squid-passwd,readonly" \
  squid-proxy
```

Test access and view logs:

```bash
curl --proxy http://127.0.0.1:3128 --proxy-user proxyuser https://www.baidu.com/
docker logs squid-proxy
```

Use TLS or a secure tunnel before exposing the proxy publicly. Basic authentication does not encrypt credentials. Local runs use your computer's internet connection.

## Publish to Azure China

Create an Azure Container Registry token with `content/read` and `content/write` permissions for repository `squid-proxy`.

In GitHub, open **Settings → Secrets and variables → Actions** and add:

| Type     | Name               | Value                                                    |
| -------- | ------------------ | -------------------------------------------------------- |
| Variable | `ACR_LOGIN_SERVER` | Registry login server, such as `yourregistry.azurecr.cn` |
| Variable | `ACR_USERNAME`     | ACR token name                                           |
| Secret   | `ACR_PASSWORD`     | Generated ACR token password                             |

The [publishing workflow](.github/workflows/publish.yml) runs on pushes to `main` or through **Actions → Run workflow**. It builds an AMD64 image and publishes two tags:

```text
<login-server>/squid-proxy:<commit-sha>
<login-server>/squid-proxy:latest
```

Publishing does not deploy the proxy. When deploying to Azure Container Instances, mount the password file at `/run/secrets/squid-passwd` and configure secure client access.
