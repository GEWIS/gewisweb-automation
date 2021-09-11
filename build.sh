#!/bin/sh
cd /code/gewisweb || exit
LATEST_COMMIT=$(git log -n 1 --format="%H")
if [ -f /code/LATEST_BUILD ]; then
    LATEST_BUILD=$(cat /code/LATEST_BUILD)
    if [ "$LATEST_COMMIT" = "$LATEST_BUILD" ]; then
        echo "The latest commit has already been built"
        exit
    fi
fi
if [ -f /code/LOCK_BUILD ]; then
    echo "Build is already ongoing"
    exit
fi
if [ -f /code/LOCK_UPDATE_DOCKER ]; then
    echo "Images are currently being refreshed"
    exit
fi
echo "Creating build lock"
echo "locked" >/code/LOCK_BUILD
echo "Pulling sources"
git pull
echo "Building images"
make build
echo "Pushing images"
make push
echo "Successfully built and pushed commit $LATEST_COMMIT"
echo "$LATEST_COMMIT" >/code/LATEST_BUILD
echo "Removing build lock"
rm -f /code/LOCK_BUILD
