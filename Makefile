.PHONY: run stop build login push all

help:
		@echo "Makefile commands:"
		@echo "run"
		@echo "stop"
		@echo "build"
		@echo "login"
		@echo "push"
		@echo "all = build login push"

.DEFAULT_GOAL := all

run: build
		@docker-compose up -d --force-recreate --remove-orphans

stop:
		@docker-compose down

all: build login push

build:
		@docker build -t web.docker-registry.gewis.nl/gewisweb_automation:latest -f . .

login:
		@docker login web.docker-registry.gewis.nl

push:
		@docker push web.docker-registry.gewis.nl/gewisweb_automation:latest
