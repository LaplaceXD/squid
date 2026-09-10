# Squid

Authenticated HTTP/HTTPS proxy on port `3128`. Blocks common private address ranges and disables caching.

## Run locally

Replace the credentials with your own non-empty values:

```bash
export PROXY_USERNAME='your-username'
export PROXY_PASSWORD='your-password'

docker build --platform linux/amd64 -t squid .
docker run -d --name squid --platform linux/amd64 \
  -p 127.0.0.1:3128:3128 \
  --env PROXY_USERNAME --env PROXY_PASSWORD \
  squid
unset PROXY_PASSWORD
```

Test access (curl prompts for the password) and check logs:

```bash
curl --proxy http://127.0.0.1:3128 --proxy-user "$PROXY_USERNAME" https://example.com/
docker logs squid
```

## Limitations

- Client-to-proxy access uses HTTP only. HTTPS destinations work through CONNECT, but proxy credentials remain unencrypted. Configure HTTPS (TLS) for the proxy or use a secure tunnel before public access.
- Only destination ports `80` and `443` are allowed. CONNECT is limited to `443`. Ports such as `8080` and `8443` are blocked.
- The destination block list is not complete network isolation. Internal services with public IP addresses are not covered. Add outbound firewall rules if you need that protection.

## Publish to Docker Hub

Create a Docker Hub repository named `squid`. In GitHub **Settings → Secrets and variables → Actions**, add:

| Type     | Name                 | Value                                      |
| -------- | -------------------- | ------------------------------------------ |
| Variable | `DOCKERHUB_USERNAME` | Your Docker Hub username                   |
| Secret   | `DOCKERHUB_TOKEN`    | Access token with Read & Write permissions |

Push to `main` or select **Actions → Publish Squid Proxy to Docker Hub → Run workflow** on `main`. The [workflow](.github/workflows/publish.yml) publishes AMD64 images:

```text
<dockerhub-username>/squid:latest
<dockerhub-username>/squid:<commit-sha>
```

Publishing does not deploy the proxy. Set `PROXY_USERNAME` and `PROXY_PASSWORD` when you run the image.
