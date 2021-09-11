#!/bin/sh
echo "Preparing environment variables"
printenv | sed 's/^\(.*\)$/export \1/g' | grep -E "^export (USERNAME|PASSWORD)" > ./config/bash.env
if [ -f /code/gewisweb ]
then
    cd /code/gewisweb || exit
else
    cd /code \
    && git clone https://github.com/GEWIS/gewisweb \
    && cd /code/gewisweb \
    && git branch --set-upstream-to=origin/master master
fi
echo "Successfully enterered gewisweb"
docker login -u "$USERNAME" -p "$PASSWORD" web.docker-registry.gewis.nl
echo "Starting cron"
cron -f -L 7
