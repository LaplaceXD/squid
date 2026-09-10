# Squid Proxy

An Alpine-based Squid forward proxy with password authentication. It listens on port `3128`, permits public HTTP/HTTPS destinations, and disables response caching.

## Run locally

Build the image:

```bash
docker build --platform linux/amd64 -t squid-proxy .
```

Set the proxy credentials in Bash. Enter the password at the prompt:

```bash
export PROXY_USERNAME=proxyuser
read -r -s -p 'Proxy password: ' PROXY_PASSWORD
echo
export PROXY_PASSWORD
```

Both variables must have a non-empty value. At each start, the container creates a password hash in `/etc/squid/passwd` and starts Squid in the foreground. You do not need to mount a password file.

Start the container:

```bash
docker run -d --name squid-proxy --platform linux/amd64 \
  -p 127.0.0.1:3128:3128 \
  --env PROXY_USERNAME \
  --env PROXY_PASSWORD \
  squid-proxy
unset PROXY_PASSWORD
```

Test access and view logs. Enter the same password when curl prompts for it:

```bash
curl --proxy http://127.0.0.1:3128 --proxy-user proxyuser https://www.baidu.com/
docker logs squid-proxy
```

Check that a request without credentials returns `407 Proxy Authentication Required`:

```bash
curl --include --proxy http://127.0.0.1:3128 http://example.com/
```

To change the credentials, remove and create the container again with the new environment values.

Use TLS or a secure tunnel before exposing the proxy publicly. Basic authentication does not encrypt credentials. Local runs use your computer's internet connection.

## Publish to Docker Hub

Create a `squid-proxy` repository under your Docker Hub username. Select public or private visibility as required.

Create a [Docker Hub personal access token](https://docs.docker.com/security/access-tokens/) with Read and Write permissions.

In GitHub, open **Settings → Secrets and variables → Actions** and add:

| Type     | Name               | Value                                                    |
| -------- | ------------------ | -------------------------------------------------------- |
| Variable | `DOCKERHUB_USERNAME` | Your Docker Hub username                              |
| Secret   | `DOCKERHUB_TOKEN`    | Your Docker Hub personal access token                 |

The [publishing workflow](.github/workflows/publish.yml) runs on pushes to `main` or through **Actions → Run workflow**. It builds an AMD64 image and publishes two tags:

```text
<dockerhub-username>/squid-proxy:<commit-sha>
<dockerhub-username>/squid-proxy:latest
```

Commit and push the workflow and image source files to `main` to start publishing. For a manual run, open **Actions → Publish Squid Proxy to Docker Hub → Run workflow** and select `main`.

The workflow does not use the previous `ACR_*` settings. You can remove them if no other workflow uses them.

Publishing does not deploy the proxy. When deploying to Azure Container Instances, set `PROXY_USERNAME` and `PROXY_PASSWORD` as secure environment variables and configure secure client access. Supply the password itself, not a password hash.
