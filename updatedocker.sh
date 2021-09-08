#!/bin/sh
echo "locked" > /code/updatelock
docker system prune -a -f
echo "Docker cache was pruned"
cd /code/gewisweb || exit
make updatedocker
echo "New docker images were pulled"
rm -f /code/latestcommit
rm -f /code/updatelock
sh /code/build.sh
