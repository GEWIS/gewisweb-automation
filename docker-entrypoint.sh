#!/bin/sh
cd /code/gewisweb \
  || cd /code \
    && git clone https://github.com/GEWIS/gewisweb \
    && cd /code/gewisweb \
    && git branch --set-upstream-to=origin/master master \
  || exit
echo "Successfully enterered gewisweb"
docker login -u "${USERNAME}" -p "${PASSWORD}" web.docker-registry.gewis.nl
echo "Starting cron"
cron -f -L 7
