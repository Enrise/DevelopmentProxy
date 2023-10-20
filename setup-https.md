# Set up https with SSL

Requirements: [mkcert](https://github.com/FiloSottile/mkcert#installation) (don't forget to run `mkcert -install` after installation!)

Steps to add SSL to your dev hosts:

## 1. Add labels in docker compose

Add the `tls`, and `entrypoints` label to your router:

```yaml
services:
  frontend:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.my-project-frontend.rule=Host(`frontend.my-project.local`)"
      - "traefik.http.services.my-project-frontend.loadbalancer.server.port=80"
      - "traefik.http.routers.my-project-frontend.tls=true"
      - "traefik.http.routers.my-project-frontend.entrypoints=web-secure"
```

## 2. Create certificates and copy them to the dev proxy**

To create certificates use `mkcert`.

For example: `mkcert frontend.my-project.local backend.my-project.local`

Copy the generated files to the dev proxy certificates folder: `cp ./frontend.my-project.local+1* ~/.development-proxy/certs/`

## 3. Create a tls configuration for your project**

Create a configuration file `my-project.yml`

```yaml
tls:
  certificates:
    - certFile: /var/certs/frontend.my-project.local+1.pem
      keyFile: /var/certs/frontend.my-project.local+1-key.pem
```

Copy the configuration to the dev proxy configuration folder: `cp ./my-project.yml ~/.development-proxy/certs/my-project.yml`

## Automation

Automating step 2 and 3 can be done with the following code below:

```shell
echo "\n=== Creating certificates ===\n"
(mkdir -p ./dev/traefik-config/certs || true \
	&& cd ./dev/traefik-config/certs \
	&& (mkcert frontend.my-project.local backend.my-project.local \
	&& echo "> certificates created") \
	|| echo "> could not create certificates, did you install mkcert?")
echo "\n=== Copy dev proxy config ===\n"
cp ./dev/traefik-config/my-project.yml ~/.development-proxy/config/my-project.yml
cp ./dev/traefik-config/certs/* ~/.development-proxy/certs/
echo "> configuration copied"
```
