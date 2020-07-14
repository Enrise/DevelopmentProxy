# Enrise development proxy

Add host names to your dockerized containers. So localhost:3000 can just be
http://example.local again.

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

TODO

## 3. Linking your docker network

To finalize

### On project start

The following command needs to be run in order to link your docker network to the enrise
dev proxy network:

```sh
docker network connect <your-project-docker-network> enrise-dev-proxy || true
```

### On project stop

When you stop your project, or down down docker compose stack, you need to disconnect the
docker network:

```sh
docker network disconnect <your-project-docker-network> enrise-dev-proxy || true
```

## 4. Add the hostname to your hosts file

Finally you have to make sure the host name is in your local hosts file. So for http://example.local
we would expect the following content in `/etc/hosts`:

```
# === example
127.0.0.1    example.local
# === /example
```

You could automate this with a script like the following:

TODO