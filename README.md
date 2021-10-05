# Enrise development proxy

Add host names to your containerized containers.
So localhost:3000 can just be http://my-project.local again.

## How does it work?

With 4 simple steps you should be able to use hostnames instead of ports:

1. Add the start snippet to your project start command to make sure the proxy is running for your project
2. Add the Traefik rules to your docker compose file
3. Link your docker network to the `enrise-dev-proxy` network
4. Add the hostname to your `/etc/hosts` file 

## 1. Start proxy snippet

We recommend that you add the snippet below to your project starting command, to make sure
you have the proxy running when you run a project.

### Via curl

```sh
curl --silent https://gitlab.enrise.com/Enrise/DevProxy/-/raw/master/start.sh | sh
```

### Via wget

```sh
wget --quiet --output-document - https://gitlab.enrise.com/Enrise/DevProxy/-/raw/master/start.sh | sh
```

## 2. Docker compose config

Add a labels to your docker-compose services so Traefik knows how to connect to them:

```yaml
services:
  frontend:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.my-project-frontend.rule=Host(`frontend.my-project.local`)"
      - "traefik.http.services.my-project-frontend.loadbalancer.server.port=80"
  backend:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.my-project-frontend.rule=Host(`api.my-project.local`)"
      - "traefik.http.services.my-project-frontend.loadbalancer.server.port=80"
```

Note: make sure the slugs begin with your project name so multiple projects can run together.

## 3. Linking your docker network

### On project start

After starting your Docker Compose stack, the following command needs to be run
in order to link your docker network to the enrise dev proxy network:

```sh
docker network connect <your-project-docker-network> enrise-dev-proxy || true
```

### On project stop

When you stop your project, or bring your docker compose stack down , you need to disconnect the
docker network first:

```sh
docker network disconnect <your-project-docker-network> enrise-dev-proxy || true
```

## 4. Add the hostname to your hosts file

Finally, you have to make sure the host name is in your local hosts file. So for http://example.local
we would expect the following content in `/etc/hosts`:

```
#==== My Example Project
127.0.0.1    my-project.local
127.0.0.1    api.my-project.local
127.0.0.1    frontend.my-project.local
#====
```

You could automate this with a script like the following:

```shell script
@cat /etc/hosts | grep -q my-project.local \
|| (echo "\n=== Adding local My Project hosts ===\n" && \
    docker run --rm \
    -v /etc/hosts:/etc/hosts \
    -v $$(pwd)/dev/hostnames.txt:/dev/hostnames.txt \
    alpine:latest \
    sh -c 'cat /dev/hostnames.txt >> /etc/hosts')
```
This script checks if my-project.local already exists in the hosts file, and if not, it adds the contents
of a file named dev/hostnames.txt (Add this file to your project).

## 5. SSL

Requirements: [mkcert](https://github.com/FiloSottile/mkcert#installation) (don't forget to run `mkcert -install` after installation!)

Steps to add SSL to your dev hosts:

**Step 1. Add labels in docker compose**

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

**Step 2. Create certificates and copy them to the dev proxy**

To create certificates use `mkcert`.

For example: `mkcert frontend.my-project.local backend.my-project.local`

Copy the generated files to the dev proxy certificates folder: `cp ./frontend.my-project.local+1* ~/.enrise-dev-proxy/certs/`

**Step 3. Create a tls configuration for your project**

Create a configuration file `my-project.yml`

```yaml
tls:
  certificates:
    - certFile: /var/certs/frontend.my-project.local+1.pem
      keyFile: /var/certs/frontend.my-project.local+1-key.pem
```

Copy the configuration to the dev proxy configuration folder: `cp ./my-project.yml ~/.enrise-dev-proxy/certs/my-project.yml`
