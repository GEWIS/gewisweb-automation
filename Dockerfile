FROM ubuntu:latest as gewisweb_automation

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        cron \
        docker \
        docker.io \
        docker-compose \
        git \
        jq \
        make \
    && apt-get upgrade -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /code

COPY --chown=www-data:www-data ./crontab /etc/cron.d/crontab
RUN chmod 0644 /etc/cron.d/crontab && crontab /etc/cron.d/crontab

COPY --chown=www-data:www-data ./docker-entrypoint.sh ./docker-entrypoint.sh
RUN chmod 0775 ./docker-entrypoint.sh

COPY --chown=www-data:www-data . .

ENTRYPOINT ["/bin/sh", "/code/docker-entrypoint.sh"]
