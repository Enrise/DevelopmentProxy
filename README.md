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

For every service in your project, add the following to docker-compose:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.<slug>.rule=Host(`<slug>.local`)"
  - "traefik.http.services.<slug>.loadbalancer.server.port=80"
```

Make sure the slugs begin with your project name so multiple projects can run together, for example:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.my-project-api.rule=Host(`api.my-project.local`)"
  - "traefik.http.services.my-project-api.loadbalancer.server.port=80"

```

## 3. Linking your docker network

```sh
docker network connect <your-project-docker-network> enrise-dev-proxy || true
```


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

Finally you have to make sure the host name is in your local hosts file. So for http://example.local
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
