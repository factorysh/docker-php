
# This makefile is only used by docker-compose

PHP_VERSION?=""
ROOT_DIR:=$(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
USER:=$(shell id -u)
OS := $(shell uname | tr A-Z a-z)
GOSS_HOST_PATH := ./bin/${OS}/goss
SLEEP:=2

all: do_docker_compose

do_docker_compose: test_with_nginx test_with_nginx_and_traefik test_telegraf test_smtp test_redis

test_with_nginx:
	@echo "== Test Nginx for $(PHP_VERSION) with USER $(USER) =="
	for i in $(docker container ls -f label=com.docker.compose.project=tests_php -q -a); do docker  container kill $i; done
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose down --remove-orphans
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose build php
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose up -d nginx
	sleep $(SLEEP)
	#PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose run client wget -O - nginx:8000/info.php
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose up --abort-on-container-exit --exit-code-from client client
	docker-compose exec -T php ls -l /proc/1/fd | grep " [1-2] -> pipe:"
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose down --remove-orphans

test_with_nginx_and_traefik:
	@echo "== Test Nginx & Traefik for $(PHP_VERSION) =="
	for i in $(docker container ls -f label=com.docker.compose.project=tests_php -q); do docker  container kill $i; done
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose -f traefik-compose.yml down --remove-orphans
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose -f traefik-compose.yml build php
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose -f traefik-compose.yml up -d nginx traefik-php
	sleep $(SLEEP)
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose -f traefik-compose.yml up --abort-on-container-exit --exit-code-from client client
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose -f traefik-compose.yml down --remove-orphans

test_telegraf:
	@echo "== Test Telegraf for $(PHP_VERSION) =="
	for i in $(docker container ls -f label=com.docker.compose.project=tests_php -q); do docker  container kill $i; done
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose down --remove-orphans
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose run \
		--rm \
		telegraf \
		goss -g /goss/php_status.yaml validate --format documentation
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose down --remove-orphans

test_smtp: image
	@echo "== Test SMTP for $(PHP_VERSION) =="
	for i in $(docker container ls -f label=com.docker.compose.project=tests_php -q); do docker  container kill $i; done
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose down --remove-orphans
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose build php
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose run \
		--name test_php_smtp_logs \
		-v $(ROOT_DIR)/bin/goss:/usr/local/bin/goss \
		-v $(ROOT_DIR):/goss/ \
		php \
		/usr/local/bin/goss -g /goss/php_smtp.yaml validate --format documentation > ./smtp_logs_output
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose run \
		--name test_php_smtp_logs_inspect \
		-v $(ROOT_DIR)/bin/goss:/usr/local/bin/goss \
		-v $(ROOT_DIR):/goss/ \
		php \
		/usr/local/bin/goss -g /goss/php_smtp_logs.yaml validate --format documentation
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose down --remove-orphans
image:
	docker build -t docker -f Dockerfile.docker .

test_redis:
	@echo "== Test SMTP for $(PHP_VERSION) =="
	for i in $(docker container ls -f label=com.docker.compose.project=tests_php -q -a); do docker  container kill $i && docker container rm $i; done
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose -f docker-compose.yml -f redis-compose.yml down --remove-orphans
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose -f docker-compose.yml -f redis-compose.yml build php
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose -f docker-compose.yml -f redis-compose.yml up -d nginx
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose -f docker-compose.yml -f redis-compose.yml run \
		--rm \
		-v $(ROOT_DIR)/bin/goss:/usr/local/bin/goss:ro \
		-v $(ROOT_DIR)/php_redis.yaml:/goss/php_redis.yaml:ro \
		client \
		/usr/local/bin/goss -g /goss/php_redis.yaml validate --format documentation
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose -f docker-compose.yml -f redis-compose.yml exec -T redis redis-cli KEYS "*"
	PHP_VERSION=$(PHP_VERSION) USER=$(USER) docker-compose -f docker-compose.yml -f redis-compose.yml down --remove-orphans
