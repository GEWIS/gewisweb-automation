#!/bin/sh
echo "Creating build lock"
echo "locked" >/code/LOCK_UPDATE_DOCKER
# Next two lines are disabled because it may adversely affect the host
#docker system prune -a -f
#echo "Docker cache was pruned"
cd /code/gewisweb || exit
echo "Pulling new docker images and rebuilding without cache"
make updatedocker
echo "Removing locks"
rm -f /code/LATEST_BUILD
rm -f /code/LOCK_UPDATE_DOCKER
echo "Proceeding with fresh regular build procedure"
sh /code/build.sh
