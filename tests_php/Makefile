
# This makefile is only used by docker-compose

PHP_VERSION = ""
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

all: do_docker_compose

do_docker_compose: test_with_nginx test_with_nginx_and_traefik test_telegraf test_smtp

test_with_nginx:
	PHP_VERSION=$(PHP_VERSION) docker-compose down --remove-orphans
	PHP_VERSION=$(PHP_VERSION) docker-compose up -d --build nginx
	sleep 1
	PHP_VERSION=$(PHP_VERSION) docker-compose up --abort-on-container-exit --exit-code-from client client
	PHP_VERSION=$(PHP_VERSION) docker-compose down --remove-orphans

test_with_nginx_and_traefik:
	PHP_VERSION=$(PHP_VERSION) docker-compose -f traefik-compose.yml down --remove-orphans
	PHP_VERSION=$(PHP_VERSION) docker-compose -f traefik-compose.yml build nginx
	PHP_VERSION=$(PHP_VERSION) docker-compose -f traefik-compose.yml up -d nginx traefik
	sleep 1
	PHP_VERSION=$(PHP_VERSION) docker-compose -f traefik-compose.yml up --abort-on-container-exit --exit-code-from client client
	PHP_VERSION=$(PHP_VERSION) docker-compose -f traefik-compose.yml down --remove-orphans

test_telegraf:
	PHP_VERSION=$(PHP_VERSION) docker-compose down --remove-orphans
	PHP_VERSION=$(PHP_VERSION) docker-compose run \
		telegraf \
		goss -g /goss/php_status.yaml validate --format documentation
	PHP_VERSION=$(PHP_VERSION) docker-compose down --remove-orphans

test_smtp:
	PHP_VERSION=$(PHP_VERSION) docker-compose down --remove-orphans
	PHP_VERSION=$(PHP_VERSION) docker-compose run \
		-v $(ROOT_DIR)/bin/goss:/usr/local/bin/goss \
		-v $(ROOT_DIR):/goss/ \
		php \
		'goss -g /goss/php_smtp.yaml validate --format documentation'
	PHP_VERSION=$(PHP_VERSION) docker-compose down --remove-orphans
