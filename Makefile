
include Makefile.lint
include Makefile.build_args

.PHONY: tests get_goss tests_php/tools

GOSS_VERSION := 0.3.7

OS := $(shell uname | tr A-Z a-z)

COMPOSER_VERSION = $(shell curl -s https://getcomposer.org/ | grep '<p class="latest">' | ruby -e 'puts /<strong>([0-9.]+)/.match(ARGF.read)[1]')
SHA384_COMPOSER_SETUP = $(shell curl -s https://composer.github.io/installer.sha384sum | cut -f 1 -d ' ')
SHA256_COMPOSER_BIN = $(shell curl -s https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar.sha256sum | cut -f 1 -d ' ')

SURY_VERSIONS=$(shell mkdir -p /tmp/docker-php && curl -o /tmp/docker-php/Packages -s https://packages.sury.org/php/dists/stretch/main/binary-amd64/Packages)
VERSION_7_1=$(shell echo "${SURY_VERSIONS}" > /dev/null && grep -C3 "Package: php7.1-fpm$$" /tmp/docker-php/Packages | grep Version | cut -f 2 -d ' ')
VERSION_7_2=$(shell echo "${SURY_VERSIONS}" > /dev/null && grep -C3 "Package: php7.2-fpm$$" /tmp/docker-php/Packages | grep Version | cut -f 2 -d ' ')
VERSION_7_3=$(shell echo "${SURY_VERSIONS}" > /dev/null && grep -C3 "Package: php7.3-fpm$$" /tmp/docker-php/Packages | grep Version | cut -f 2 -d ' ')
VERSION_7_0=$(shell curl -sL https://packages.debian.org/fr/stretch/php | grep '<h1>.*php .1:' | sed -E 's/.*\(1:([0-9.+]+)\).*/\1/')
VERSION_7_3=$(shell curl -sL https://packages.debian.org/fr/buster/php | grep '<h1>.*php .2:' | sed -E 's/.*\(2:([0-9.+]+)\).*/\1/')

all: pull build

variables:
	@echo "Composer: ${COMPOSER_VERSION}"
	@echo "Composer setup hash: ${SHA384_COMPOSER_SETUP}"
	@echo "Commposer bin hash: ${SHA256_COMPOSER_BIN}"
	@echo "${VERSION_7_0}"
	@echo "${VERSION_7_1}"
	@echo "${VERSION_7_2}"
	@echo "${VERSION_7_3}"

update_composer_version:
	for f in tests_php/vars/*; do \
		sed -i 's/composer_version:.*/composer_version: $(COMPOSER_VERSION)/' $$f; \
	done
	git add tests_php/vars/*
	git commit -m "update to composer $(COMPOSER_VERSION)"

pull:
	docker pull bearstech/debian:stretch
	docker pull bearstech/debian:buster

build: 7.0 7.1 7.2 7.3

7.3 : 7.3-fpm 7.3-composer 7.3-cli

7.2 : 7.2-fpm 7.2-composer 7.2-cli

7.1: 7.1-fpm 7.1-composer 7.1-cli

7.0: 7.0-fpm 7.0-composer 7.0-cli

# debian packages

7.0-fpm: 7.0-cli
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--no-cache \
		-t bearstech/php:7.0 \
		-f Dockerfile.debian \
		--build-arg PHP_VERSION=$(VERSION_7_0) \
		--build-arg PHP_MINOR_VERSION=0 \
		.

7.0-cli:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--no-cache \
		-t bearstech/php-cli:7.0 \
		-f Dockerfile.debian-cli \
		--build-arg DEBIAN_VERSION=stretch \
		--build-arg PHP_VERSION=$(VERSION_7_0) \
		--build-arg PHP_MINOR_VERSION=0 \
		.

7.0-composer: 7.0-cli
	 docker build \
		$(DOCKER_BUILD_ARGS) \
	   	--no-cache \
		-t bearstech/php-composer:7.0 \
		-f Dockerfile.7.x-composer \
		--build-arg PHP_MINOR_VERSION=0 \
		--build-arg SHA384_COMPOSER_SETUP=$(SHA384_COMPOSER_SETUP) \
		--build-arg SHA256_COMPOSER_BIN=$(SHA256_COMPOSER_BIN) \
		--build-arg COMPOSER_VERSION=$(COMPOSER_VERSION) \
		.

7.3-fpm: 7.3-cli
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--no-cache \
		-t bearstech/php:7.3 \
		-f Dockerfile.debian \
		--build-arg PHP_VERSION=$(VERSION_7_3) \
		--build-arg PHP_MINOR_VERSION=3 \
		.

7.3-cli:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--no-cache \
		-t bearstech/php-cli:7.3 \
		-f Dockerfile.debian-cli \
		--build-arg DEBIAN_VERSION=buster \
		--build-arg PHP_VERSION=$(VERSION_7_3) \
		--build-arg PHP_MINOR_VERSION=3 \
		.

7.3-composer: 7.3-cli
	 docker build \
		$(DOCKER_BUILD_ARGS) \
	   	--no-cache \
		-t bearstech/php-composer:7.3 \
		-f Dockerfile.7.x-composer \
		--build-arg PHP_MINOR_VERSION=3 \
		--build-arg SHA384_COMPOSER_SETUP=$(SHA384_COMPOSER_SETUP) \
		--build-arg SHA256_COMPOSER_BIN=$(SHA256_COMPOSER_BIN) \
		--build-arg COMPOSER_VERSION=$(COMPOSER_VERSION) \
		.

# sury packages

7.1-fpm: 7.1-cli
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--no-cache \
		-t bearstech/php:7.1 \
		-f Dockerfile.7.x \
		--build-arg PHP_MINOR_VERSION=1 \
		.

7.1-cli:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--no-cache \
		-t bearstech/php-cli:7.1 \
		-f Dockerfile.7.x-cli \
		--build-arg PHP_MINOR_VERSION=1 \
		--build-arg PHP_VERSION=$(VERSION_7_1) \
		.

7.1-composer: 7.1-cli
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--no-cache \
		-t bearstech/php-composer:7.1 \
		-f Dockerfile.7.x-composer \
		--build-arg PHP_MINOR_VERSION=1 \
		--build-arg SHA384_COMPOSER_SETUP=$(SHA384_COMPOSER_SETUP) \
		--build-arg SHA256_COMPOSER_BIN=$(SHA256_COMPOSER_BIN) \
		--build-arg COMPOSER_VERSION=$(COMPOSER_VERSION) \
		.

7.2-fpm: 7.2-cli
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--no-cache \
		-t bearstech/php:7.2 \
		-f Dockerfile.7.x \
		--build-arg PHP_MINOR_VERSION=2 \
		.
	docker tag bearstech/php:7.2 bearstech/php:latest

7.2-cli:
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--no-cache \
		-t bearstech/php-cli:7.2 \
		-f Dockerfile.7.x-cli \
		--build-arg PHP_MINOR_VERSION=2 \
		--build-arg PHP_VERSION=$(VERSION_7_2) \
		.
	docker tag bearstech/php-cli:7.2 bearstech/php-cli:latest

7.2-composer: 7.2-cli
	 docker build \
		$(DOCKER_BUILD_ARGS) \
		--no-cache \
		-t bearstech/php-composer:7.2 \
		-f Dockerfile.7.x-composer \
		--build-arg PHP_MINOR_VERSION=2 \
		--build-arg SHA384_COMPOSER_SETUP=$(SHA384_COMPOSER_SETUP) \
		--build-arg SHA256_COMPOSER_BIN=$(SHA256_COMPOSER_BIN) \
		--build-arg COMPOSER_VERSION=$(COMPOSER_VERSION) \
		.
	docker tag bearstech/php-composer:7.2 bearstech/php-composer:latest

push:
	docker push bearstech/php:7.0
	docker push bearstech/php:7.1
	docker push bearstech/php:7.2
	docker push bearstech/php:7.3
	docker push bearstech/php:latest
	docker push bearstech/php-cli:7.0
	docker push bearstech/php-cli:7.1
	docker push bearstech/php-cli:7.2
	docker push bearstech/php-cli:7.3
	docker push bearstech/php-cli:latest
	docker push bearstech/php-composer:7.0
	docker push bearstech/php-composer:7.1
	docker push bearstech/php-composer:7.2
	docker push bearstech/php-composer:7.3
	docker push bearstech/php-composer:latest

remove_image:
	docker rmi bearstech/php:7.0
	docker rmi bearstech/php:7.1
	docker rmi bearstech/php:7.2
	docker rmi bearstech/php:latest
	docker rmi bearstech/php-cli:7.0
	docker rmi bearstech/php-cli:7.1
	docker rmi bearstech/php-cli:7.2
	docker rmi bearstech/php-cli:latest
	docker rmi bearstech/php-composer:7.0
	docker rmi bearstech/php-composer:7.1
	docker rmi bearstech/php-composer:7.2
	docker rmi bearstech/php-composer:latest

clean:
	rm -rf bin


get_goss:
	$(eval TARGET ?= linux)
	mkdir -p tests_php/bin/${TARGET}/${GOSS_VERSION}
	curl -o tests_php/bin/${TARGET}/${GOSS_VERSION}/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-${TARGET}-amd64
	chmod 755 tests_php/bin/${TARGET}/${GOSS_VERSION}

tests_php/bin/darwin/${GOSS_VERSION}/goss:
	$(eval TARGET = darwin)
	make get_goss

tests_php/bin/linux/${GOSS_VERSION}/goss:
	make get_goss

tests_php/tools: tests_php/bin/linux/${GOSS_VERSION}/goss tests_php/bin/${OS}/${GOSS_VERSION}/goss

test-7.0: tests_php/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests_php/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_php:/goss \
		-w /goss \
		--entrypoint "" \
		bearstech/php:7.0 \
		goss -g php-dev.yaml --vars vars/7_0.yaml validate --max-concurrent 4 --format documentation

test-cli-7.0: tests_php/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests_php/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_php:/goss \
		-w /goss \
		bearstech/php-cli:7.0 \
		goss -g php-dev.yaml --vars vars/7_0.yaml validate --max-concurrent 4 --format documentation

test-composer-7.0: tests_php/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests_php/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_php:/goss \
		-w /goss \
		bearstech/php-composer:7.0 \
		/bin/bash -c "goss -g php-composer.yaml --vars vars/7_0.yaml validate --max-concurrent 4 --format documentation && goss -g php_test_composer.yaml validate --format documentation"

test-7.1: tests_php/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests_php/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_php:/goss \
		-w /goss \
		--entrypoint "" \
		bearstech/php:7.1 \
		goss -g php-dev.yaml --vars vars/7_1.yaml validate --max-concurrent 4 --format documentation

test-cli-7.1: tests_php/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests_php/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_php:/goss \
		-w /goss \
		bearstech/php-cli:7.1 \
		goss -g php-dev.yaml --vars vars/7_1.yaml validate --max-concurrent 4 --format documentation

test-composer-7.1: tests_php/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests_php/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_php:/goss \
		-w /goss \
		bearstech/php-composer:7.1 \
		/bin/bash -c "goss -g php-composer.yaml --vars vars/7_1.yaml validate --max-concurrent 4 --format documentation && goss -g php_test_composer.yaml validate --format documentation"

test-7.2: tests_php/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests_php/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_php:/goss \
		-w /goss \
		--entrypoint "" \
		bearstech/php:7.2 \
		goss -g php-dev.yaml --vars vars/7_2.yaml validate --max-concurrent 4 --format documentation

test-cli-7.2: tests_php/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests_php/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_php:/goss \
		-w /goss \
		bearstech/php-cli:7.2 \
		goss -g php-dev.yaml --vars vars/7_2.yaml validate --max-concurrent 4 --format documentation

test-composer-7.2: tests_php/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests_php/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_php:/goss \
		-w /goss \
		bearstech/php-composer:7.2 \
		/bin/bash -c "goss -g php-composer.yaml --vars vars/7_2.yaml validate --max-concurrent 4 --format documentation && goss -g php_test_composer.yaml validate --format documentation"

test-7.3: tests_php/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests_php/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_php:/goss \
		-w /goss \
		--entrypoint "" \
		bearstech/php:7.3 \
		goss -g php-dev.yaml --vars vars/7_3.yaml validate --max-concurrent 4 --format documentation

test-cli-7.3: tests_php/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests_php/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_php:/goss \
		-w /goss \
		bearstech/php-cli:7.3 \
		goss -g php-dev.yaml --vars vars/7_3.yaml validate --max-concurrent 4 --format documentation

test-composer-7.3: tests_php/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests_php/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests_php:/goss \
		-w /goss \
		bearstech/php-composer:7.3 \
		/bin/bash -c "goss -g php-composer.yaml --vars vars/7_3.yaml validate --max-concurrent 4 --format documentation && goss -g php_test_composer.yaml validate --format documentation"

test-html-7.0: tests_php/bin/goss
	make -C tests_php do_docker_compose PHP_VERSION=7.0

test-html-7.1: tests_php/bin/goss
	make -C tests_php do_docker_compose PHP_VERSION=7.1

test-html-7.2: tests_php/bin/goss
	make -C tests_php do_docker_compose PHP_VERSION=7.2

test-html-7.3: tests_php/bin/goss
	make -C tests_php do_docker_compose PHP_VERSION=7.3

test-html: test-html-7.0 test-html-7.1 test-html-7.2 test-html-7.3

tests-7.0: test-7.0 test-cli-7.0 test-composer-7.0 test-html-7.0

tests-7.1: test-7.1 test-cli-7.1 test-composer-7.1 test-html-7.1

tests-7.2: test-7.2 test-cli-7.2 test-composer-7.2 test-html-7.2

tests-7.3: test-7.3 test-cli-7.3 test-composer-7.3 test-html-7.3

down:

tests: tests-7.0 tests-7.1 tests-7.2 tests-7.3
