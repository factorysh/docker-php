
# This makefile is only used by docker-compose

PHP_VERSION = ""

all: do_docker_compose

do_docker_compose:
	PHP_VERSION=$(PHP_VERSION) docker-compose down --remove-orphans
	PHP_VERSION=$(PHP_VERSION) docker-compose up -d --build nginx
	sleep 1
	PHP_VERSION=$(PHP_VERSION) docker-compose up --abort-on-container-exit --exit-code-from client client
	PHP_VERSION=$(PHP_VERSION) docker-compose down --remove-orphans
