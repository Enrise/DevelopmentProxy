echo "Starting development hosts proxy..."
docker network create enrise-dev-proxy > /dev/null 2>&1 || true
(docker run \
    -d \
    --rm \
    -p 80:80 \
    -p 8080:8080 \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    --name enrise-dev-proxy \
    --network enrise-dev-proxy \
    traefik:v2.2 \
    --api.insecure=true \
    --providers.docker=true \
    --providers.docker.exposedbydefault=false \
    --entrypoints.web.address=:80 > /dev/null \
    || true) && echo "Development hosts proxy is running."
