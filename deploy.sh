#!/bin/sh
ENDPOINT_ID="1"
STACK_ID_PROD="78"
STACK_ID_DEV="62"
#LATEST_BUILD=$(cat /code/LATEST_BUILD)
echo "Logging into Portainer"
JWT=$(curl -X POST https://docker.gewis.nl/api/auth -d '{"username": "'"$USERNAME"'", "password": "'"$PASSWORD"'"}' | jq -r '.jwt')
echo "Retrieving image IDs"
IMAGE_ID_PROD=$(curl -g -X GET "https://docker.gewis.nl/api/endpoints/$ENDPOINT_ID/docker/images/json?filters={\"reference\":[\"web.docker-registry.gewis.nl/gewisweb_web:production\"]}" -H "Authorization: Bearer $JWT" | jq -r '[.[] ] | .[0].Id')
IMAGE_ID_DEV=$(curl -g -X GET "https://docker.gewis.nl/api/endpoints/$ENDPOINT_ID/docker/images/json?filters={\"reference\":[\"web.docker-registry.gewis.nl/gewisweb_web:development\"]}" -H "Authorization: Bearer $JWT" | jq -r '[.[] ] | .[0].Id')
IMAGE_ID_NGINX=$(curl -g -X GET "https://docker.gewis.nl/api/endpoints/$ENDPOINT_ID/docker/images/json?filters={\"reference\":[\"web.docker-registry.gewis.nl/gewisweb_nginx:latest\"]}" -H "Authorization: Bearer $JWT" | jq -r '[.[] ] | .[0].Id')
IMAGE_ID_POSTFIX=$(curl -g -X GET "https://docker.gewis.nl/api/endpoints/$ENDPOINT_ID/docker/images/json?filters={\"reference\":[\"juanluisbaptiste/postfix:latest\"]}" -H "Authorization: Bearer $JWT" | jq -r '[.[] ] | .[0].Id')
IMAGE_ID_GLIDE=$(curl -g -X GET "https://docker.gewis.nl/api/endpoints/$ENDPOINT_ID/docker/images/json?filters={\"reference\":[\"web.docker-registry.gewis.nl/gewisweb_glide:latest\"]}" -H "Authorization: Bearer $JWT" | jq -r '[.[] ] | .[0].Id')
IMAGE_ID_MEMCACHED=$(curl -g -X GET "https://docker.gewis.nl/api/endpoints/$ENDPOINT_ID/docker/images/json?filters={\"reference\":[\"memcached:latest\"]}" -H "Authorization: Bearer $JWT" | jq -r '[.[] ] | .[0].Id')
IMAGE_ID_MATOMO=$(curl -g -X GET "https://docker.gewis.nl/api/endpoints/$ENDPOINT_ID/docker/images/json?filters={\"reference\":[\"web.docker-registry.gewis.nl/gewisweb_matomo:latest\"]}" -H "Authorization: Bearer $JWT" | jq -r '[.[] ] | .[0].Id')
echo "Retrieved image IDs"
echo "Stopping stacks"
curl -X POST "https://docker.gewis.nl/api/stacks/$STACK_ID_DEV/stop" -H "Authorization: Bearer $JWT"
curl -X POST "https://docker.gewis.nl/api/stacks/$STACK_ID_PROD/stop" -H "Authorization: Bearer $JWT"
echo "Deleting images"
curl -X DELETE "https://docker.gewis.nl/api/endpoints/$ENDPOINT_ID/docker/images/$IMAGE_ID_PROD?force=false" -H "Authorization: Bearer $JWT"
curl -X DELETE "https://docker.gewis.nl/api/endpoints/$ENDPOINT_ID/docker/images/$IMAGE_ID_NGINX?force=false" -H "Authorization: Bearer $JWT"
curl -X DELETE "https://docker.gewis.nl/api/endpoints/$ENDPOINT_ID/docker/images/$IMAGE_ID_POSTFIX?force=false" -H "Authorization: Bearer $JWT"
curl -X DELETE "https://docker.gewis.nl/api/endpoints/$ENDPOINT_ID/docker/images/$IMAGE_ID_GLIDE?force=false" -H "Authorization: Bearer $JWT"
curl -X DELETE "https://docker.gewis.nl/api/endpoints/$ENDPOINT_ID/docker/images/$IMAGE_ID_MEMCACHED?force=false" -H "Authorization: Bearer $JWT"
curl -X DELETE "https://docker.gewis.nl/api/endpoints/$ENDPOINT_ID/docker/images/$IMAGE_ID_MATOMO?force=false" -H "Authorization: Bearer $JWT"
echo "Starting production stack"
curl -X POST "https://docker.gewis.nl/api/stacks/$STACK_ID_PROD/start" -H "Authorization: Bearer $JWT"
echo "Deleting gewisweb_web:development image"
curl -X DELETE "https://docker.gewis.nl/api/endpoints/$ENDPOINT_ID/docker/images/$IMAGE_ID_DEV?force=false" -H "Authorization: Bearer $JWT"
echo "Starting development stack"
curl -X POST "https://docker.gewis.nl/api/stacks/$STACK_ID_DEV/start" -H "Authorization: Bearer $JWT"
echo "Logging out of Portainer"
curl -X POST https://docker.gewis.nl/api/auth/logout -H "Authorization: Bearer $JWT"
echo "Successfully deployed commit $LATEST_BUILD"
