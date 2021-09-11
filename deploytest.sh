#!/bin/sh
ENDPOINT_ID="1"
STACK_ID="62"
if [ -f /code/LATEST_BUILD ]; then
    LATEST_BUILD=$(cat /code/LATEST_BUILD)
    if [ -f /code/LATEST_DEPLOY_TEST ]; then
        LATEST_DEPLOY_TEST=$(cat /code/LATEST_DEPLOY_TEST)
        if [ "$LATEST_DEPLOY_TEST" = "$LATEST_BUILD" ]; then
            echo "The latest commit has already been deployed (test)"
            exit
        fi
    fi
else
    echo "Images have not yet been built"
    exit
fi
if [ -f /code/LOCK_DEPLOY_TEST ]; then
    echo "Test deployment is already ongoing"
    exit
fi
if [ -f /code/LOCK_BUILD ]; then
    echo "Images are currently being built"
    exit
fi
if [ -f /code/LOCK_UPDATE_DOCKER ]; then
    echo "Images are currently being refreshed"
    exit
fi
echo "Creating test deployment lock"
echo "locked" >/code/LOCK_DEPLOY_TEST
echo "Logging into Portainer"
JWT=$(curl -X POST https://docker.gewis.nl/api/auth -d '{"username": "'"$USERNAME"'", "password": "'"$PASSWORD"'"}' | jq -r '.jwt')
echo "Retrieving gewisweb_web:development image ID"
IMAGE_ID=$(curl -g -X GET "https://docker.gewis.nl/api/endpoints/$ENDPOINT_ID/docker/images/json?filters={\"reference\":[\"web.docker-registry.gewis.nl/gewisweb_web:development\"]}" -H "Authorization: Bearer $JWT" | jq -r '[.[] ] | .[0].Id')
echo "The retrieved Image ID is $IMAGE_ID"
echo "Stopping stack"
curl -X POST "https://docker.gewis.nl/api/stacks/$STACK_ID/stop" -H "Authorization: Bearer $JWT"
echo "Deleting gewisweb_web:development image"
curl -X DELETE "https://docker.gewis.nl/api/endpoints/$ENDPOINT_ID/docker/images/$IMAGE_ID?force=false" -H "Authorization: Bearer $JWT"
echo "Starting stack"
curl -X POST "https://docker.gewis.nl/api/stacks/$STACK_ID/start" -H "Authorization: Bearer $JWT"
echo "Logging out of Portainer"
curl -X POST https://docker.gewis.nl/api/auth/logout -H "Authorization: Bearer $JWT"
echo "Successfully deployed (test) commit $LATEST_COMMIT"
echo "$LATEST_COMMIT" >/code/LATEST_DEPLOY_TEST
echo "Removing test deployment lock"
rm -f /code/LOCK_DEPLOY_TEST
