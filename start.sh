#!/usr/bin/env sh

if ($(docker ps | grep -q enrise-dev-proxy)); then
  echo "Development hosts proxy is already running."
  exit 0
fi

mkdir -p ~/.enrise-dev-proxy/config || true
mkdir -p ~/.enrise-dev-proxy/certs || true

echo -n "Starting development hosts proxy... "
docker network create enrise-dev-proxy > /dev/null 2>&1 || true
(docker run \
    -d \
    --rm \
    -p 80:80 \
    -p 443:443 \
    -p 10081:10081 \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v ~/.enrise-dev-proxy/config:/var/config:ro \
    -v ~/.enrise-dev-proxy/certs:/var/certs:ro \
    --name enrise-dev-proxy \
    --network enrise-dev-proxy \
    traefik:v2.2 \
    --api.insecure=true \
    --providers.docker=true \
    --providers.docker.exposedbydefault=false \
    --providers.file.directory=/var/config \
    --providers.file.watch=true \
    --entrypoints.web.address=:80 \
    --entrypoints.web-secure.address=:443 \
    --entrypoints.traefik.address=:10081 > /dev/null && echo "started")
