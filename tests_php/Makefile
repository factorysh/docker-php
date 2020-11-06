
# This makefile is only used by docker-compose

PHP_VERSION?=""
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
USER:=$(shell id -u)
OS := $(shell uname | tr A-Z a-z)
GOSS_HOST_PATH := ./bin/${OS}/goss
SLEEP:=2

all: do_docker_compose

do_docker_compose: test_with_nginx test_with_nginx_and_traefik test_telegraf test_smtp

test_with_nginx:
	@echo "== Test Nginx for $(PHP_VERSION) with USER $(USER) =="
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose down --remove-orphans
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose build php
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose up -d nginx
	sleep $(SLEEP)
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose up --abort-on-container-exit --exit-code-from client client
	docker-compose exec -T php ls -l /proc/1/fd | grep " [1-2] -> pipe:"
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose down --remove-orphans

test_with_nginx_and_traefik:
	@echo "== Test Nginx & Traefik for $(PHP_VERSION) =="
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose -f traefik-compose.yml down --remove-orphans
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose -f traefik-compose.yml build php
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose -f traefik-compose.yml up -d nginx traefik-php
	sleep $(SLEEP)
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose -f traefik-compose.yml up --abort-on-container-exit --exit-code-from client client
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose -f traefik-compose.yml down --remove-orphans

test_telegraf:
	@echo "== Test Telegraf for $(PHP_VERSION) =="
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose down --remove-orphans
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose run \
		telegraf \
		goss -g /goss/php_status.yaml validate --format documentation
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose down --remove-orphans

test_smtp: image
	@echo "== Test SMTP for $(PHP_VERSION) =="
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose down --remove-orphans
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose build php
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose run \
		--name test_php_smtp_logs \
		-v $(ROOT_DIR)/bin/goss:/usr/local/bin/goss \
		-v $(ROOT_DIR):/goss/ \
		php \
		/usr/local/bin/goss -g /goss/php_smtp.yaml validate --format documentation
	docker logs test_php_smtp_logs
	docker run -ti --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v $(ROOT_DIR)/bin/goss:/usr/local/bin/goss \
		-v $(ROOT_DIR):/goss/ \
		-w /goss \
		docker \
		goss -g php_smtp_logs.yaml validate --format documentation
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose down --remove-orphans

image:
	docker build -t docker -f Dockerfile.docker .
