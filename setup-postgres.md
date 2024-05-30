# Set up postgres with SSL (SSL Required for postgres)

Requirements: [mkcert](https://github.com/FiloSottile/mkcert#installation) (don't forget to run `mkcert -install` after installation!)

Before you start, you must have [the development proxy](./setup.md) running.

## 1. Add labels in docker compose

Add the `tls`, and `entrypoints` label to your router:

```yaml
services:
  postgres:
    labels:
      - "traefik.enable=true"
      - "traefik.tcp.routers.my-project-postgres.rule=HostSNI(`postgres.my-project.local`)"
      - "traefik.tcp.routers.my-project-postgres.tls=true"
      - "traefik.tcp.routers.my-project-postgres.entrypoints=pg-tcp"
      - "traefik.tcp.services.my-project-postgres.loadbalancer.server.port=5432"
```

## 2. Create certificates and copy them to the dev proxy**

To create certificates use `mkcert`.

For example: `mkcert postgres.my-project.local`

Copy the generated files to the dev proxy certificates folder: `cp ./postgres.my-project.local+1* ~/.development-proxy/certs/`

## 3. Create a tls configuration for your project**

Create a configuration file `my-project.yml`

```yaml
tls:
  certificates:
    - certFile: /var/certs/postgres.my-project.local+1.pem
      keyFile: /var/certs/postgres.my-project.local+1-key.pem
```

Copy the configuration to the dev proxy configuration folder: `cp ./my-project.yml ~/.development-proxy/certs/my-project.yml`

## Automation

Automating step 2 and 3 can be done with the following code below:

```shell
echo "\n=== Creating certificates ===\n"
(mkdir -p ./dev/traefik-config/certs || true \
	&& cd ./dev/traefik-config/certs \
	&& (mkcert frontend.my-project.local backend.my-project.local postgres.my-project.local \
	&& echo "> certificates created") \
	|| echo "> could not create certificates, did you install mkcert?")
echo "\n=== Copy dev proxy config ===\n"
cp ./dev/traefik-config/my-project.yml ~/.development-proxy/config/my-project.yml
cp ./dev/traefik-config/certs/* ~/.development-proxy/certs/
echo "> configuration copied"
```
