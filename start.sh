#!/usr/bin/env sh

# ================================================
# Enrise development proxy
# find out more: https://enri.se/development-proxy
# ================================================

if ($(docker ps | grep -q development-proxy)); then
    echo "Development hosts proxy is already running."
    exit 0
fi

mkdir -p ~/.development-proxy/config || true
mkdir -p ~/.development-proxy/certs || true

echo "Starting development proxy..."
docker network create development-proxy > /dev/null 2>&1 || true
(docker run \
    --detach \
    --rm \
    --publish 80:80 \
    --publish 443:443 \
    --publish 10081:10081 \
    --publish 5432:5432 \
    --volume /var/run/docker.sock:/var/run/docker.sock:ro \
    --volume ~/.development-proxy/config:/var/config:ro \
    --volume ~/.development-proxy/certs:/var/certs:ro \
    --name development-proxy \
    --network development-proxy \
    traefik:v3.0 \
    --api.insecure=true \
    --providers.docker=true \
    --providers.docker.exposedbydefault=false \
    --providers.file.directory=/var/config \
    --providers.file.watch=true \
    --entrypoints.web.address=:80 \
    --entrypoints.web-secure.address=:443 \
    --entrypoints.traefik.address=:10081 \
    --entrypoints.pg-tcp.address=:5432 > /dev/null && echo "Started.")