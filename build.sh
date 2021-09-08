#!/bin/sh
git log -n 1 --format="%H" | read latestcommit
if [ -f /code/latestcommit ]
  then
  cat /code/latestcommit | read latestbuild
  if [ $latestcommit = $latestbuild ]
  then
    echo "The latest commit has already been built"
    exit
  fi
fi
if [ -f /code/lock ]
then
  echo "Build is already ongoing"
  exit
fi
if [ -f /code/updatelock ]
then
  echo "Images are currently being refreshed"
  exit
fi
echo "Creating build lock"
echo "locked" > /code/lock
cd /code/gewisweb || exit
echo "Pulling sources"
git pull
echo "Building images"
make build
echo "Pushing images"
make push
echo "Removing build lock"
rm -f /code/lock
