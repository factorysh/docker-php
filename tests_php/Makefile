
# This makefile is only used by docker-compose

PHP_VERSION = ""

all: do_docker_compose

do_docker_compose: test_with_nginx test_with_nginx_and_traefik

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
