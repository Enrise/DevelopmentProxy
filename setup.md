# Set up the Development Proxy


## 1. Start proxy snippet

We recommend that you add the snippet below to your project starting command, to make sure
you have the proxy running when you run a project. Run it via curl:

```shell
curl --silent --location https://enri.se/development-proxy-start | sh
```
or via wget:
```shell
wget --quiet --output-document - https://enri.se/development-proxy-start | sh
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

```shell
docker network connect <your-project-docker-network> development-proxy || true
```

### On project stop

When you stop your project, or bring your docker compose stack down , you need to disconnect the
docker network first:

```shell
docker network disconnect <your-project-docker-network> development-proxy || true
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

You can now visit your container via your custom local domain!

### automate setting the hostnames

```shell
cat /etc/hosts | grep -q my-project.local \
|| (echo "\n=== Adding local My Project hosts ===\n" && \
    docker run --rm \
    -v /etc/hosts:/etc/hosts \
    -v $$(pwd)/dev/hostnames.txt:/dev/hostnames.txt \
    alpine:latest \
    sh -c 'cat /dev/hostnames.txt >> /etc/hosts')
```
This script checks if my-project.local already exists in the hosts file, and if not, it adds the contents
of a file named dev/hostnames.txt (Add this file to your project).

## 5. (optional) Add SSL certificates for https

To use https, please read the [setup https documentation](./setup-https.md).
