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
#====
```

You can now visit your container via your custom local domain!

### automate setting the hostnames

Add the following [./Taskfile](https://github.com/Enrise/Taskfile) task in order to make sure the hosts are set correctly:

```shell
function project:set-hosts {
    title "Setup hosts file"
    for localHostName in "my-project.local" "api.my-project.local"; do
        if ! cat /etc/hosts | grep --silent $localHostName; then
            echo "Missing $localHostName in /etc/hosts, please make sure it contains:"
            echo ""
            echo "#==== My Example Project"
            echo "127.0.0.1    my-project.local"
            echo "127.0.0.1    api.my-project.local"
            echo "#===="
            exit 422
        fi
    done
    echo "All hosts present."
}
```

Or, automatically update the hosts file via a docker container using root permissions:

```shell
function project:set-hosts {
    title "Setup hosts file"
    for localHostName in "my-project.local" "api.my-project.local"; do
        if ! cat /etc/hosts | grep --silent $localHostName; then
            docker run --rm \
                --volume /etc/hosts:/etc/hosts \
                --volume ./hostnames.txt:/dev/hostnames.txt \
                alpine:latest \
                sh -c 'cat /dev/hostnames.txt >> /etc/hosts'
            break
        fi
    done
    echo "All hosts present."
}
```

For the script above, make sure a `hostnames.txt` is resolved correctly, put in the desired `/etc/hosts` section there.

## 5. (optional) Add SSL certificates for https

To use https, please read the [setup https documentation](./setup-https.md).
