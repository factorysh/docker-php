
# This makefile is only used by docker-compose

PHP_VERSION = ""
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
USER:=$(shell id -u)
SLEEP:=2

all: do_docker_compose

do_docker_compose: test_with_nginx test_with_nginx_and_traefik test_telegraf test_smtp

test_with_nginx:
	@echo "== Test Nginx for $(PHP_VERSION) with USER $(USER) =="
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose down --remove-orphans
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose build nginx php
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose up -d nginx
	sleep $(SLEEP)
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose up --abort-on-container-exit --exit-code-from client client
	docker exec tests_php_php_1 ls -l /proc/1/fd | grep " [1-2] -> pipe:"
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose down --remove-orphans

test_with_nginx_and_traefik:
	@echo "== Test Nginx & Traefik for $(PHP_VERSION) =="
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose -f traefik-compose.yml down --remove-orphans
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose -f traefik-compose.yml build nginx php
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose -f traefik-compose.yml up -d nginx traefik
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

test_smtp:
	@echo "== Test SMTP for $(PHP_VERSION) =="
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose down --remove-orphans
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose build nginx php
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose run \
		-v $(ROOT_DIR)/bin/goss:/usr/local/bin/goss \
		-v $(ROOT_DIR):/goss/ \
		php \
		/usr/local/bin/goss -g /goss/php_smtp.yaml validate --format documentation
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose down --remove-orphans
