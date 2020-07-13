# Enrise development proxy

Add host names to your dockerized containers. So localhost:3000 can just be
http://example.local again.

## How does it work?

1. Add the start snippet to your project start command to make sure the proxy is running for your project
2. Add the Traefik rules to your docker compose file
3. Visit your container via the designed hostname

## Start proxy snippet

We recommend that you add the snippet below to your project starting command, to make sure
you have the proxy running when you run a project.

Via curl:

```sh
curl --silent https://gitlab.enrise.com/Enrise/DevProxy/-/raw/master/start.sh | sh
```

Via wget:

```sh
wget --quiet --output-document - https://gitlab.enrise.com/Enrise/DevProxy/-/raw/master/start.sh | sh
```

## Docker compose config

TODO