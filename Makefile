.PHONY: tests

GOSS_VERSION := 0.3.5

all: pull build

pull:
	docker pull bearstech/debian:stretch

build: 7.0 7.1 7.2

7.2 : 7.2-fpm 7.2-composer 7.2-cli

7.1: 7.1-fpm 7.1-composer 7.1-cli

7.0: 7.0-fpm 7.0-composer 7.0-cli

7.0-fpm:
	docker build -t bearstech/php:7.0 -f Dockerfile.7.0 .

7.0-cli:
	docker build -t bearstech/php-cli:7.0 -f Dockerfile.7.0-cli .

7.0-composer: 7.0-cli
	docker build \
				-t bearstech/php-composer:7.0 \
				-f Dockerfile.7.x-composer \
				--build-arg PHP_MINOR_VERSION=0 \
				.

7.1-fpm:
	docker build \
				-t bearstech/php:7.1 \
				-f Dockerfile.7.x \
				--build-arg PHP_MINOR_VERSION=1 \
				.

7.1-cli:
	docker build \
				-t bearstech/php-cli:7.1 \
				-f Dockerfile.7.x-cli \
				--build-arg PHP_MINOR_VERSION=1 \
				.

7.1-composer: 7.1-cli
	docker build \
				-t bearstech/php-composer:7.1 \
				-f Dockerfile.7.x-composer \
				--build-arg PHP_MINOR_VERSION=1 \
				.

7.2-fpm:
	docker build \
				-t bearstech/php:7.2 \
				-f Dockerfile.7.x \
				--build-arg PHP_MINOR_VERSION=2 \
				.
	docker tag bearstech/php:7.2 bearstech/php:latest

7.2-cli:
	docker build \
					-t bearstech/php-cli:7.2 \
					-f Dockerfile.7.x-cli \
					--build-arg PHP_MINOR_VERSION=2 \
					.
	docker tag bearstech/php-cli:7.2 bearstech/php-cli:latest

7.2-composer: 7.2-cli
	docker build \
				-t bearstech/php-composer:7.2 \
				-f Dockerfile.7.x-composer \
				--build-arg PHP_MINOR_VERSION=2 \
				.
	docker tag bearstech/php-composer:7.2 bearstech/php-composer:latest

push:
	docker push bearstech/php:7.0
	docker push bearstech/php:7.1
	docker push bearstech/php:7.2
	docker push bearstech/php:latest
	docker push bearstech/php-cli:7.0
	docker push bearstech/php-cli:7.1
	docker push bearstech/php-cli:7.2
	docker push bearstech/php-cli:latest
	docker push bearstech/php-composer:7.0
	docker push bearstech/php-composer:7.1
	docker push bearstech/php-composer:7.2
	docker push bearstech/php-composer:latest

clean:
	rm -rf bin

tests/bin/goss:
	mkdir -p tests/bin
	curl -o tests/bin/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x tests/bin/goss

test-7.0: tests/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		--entrypoint "" \
		bearstech/php:7.0 \
		goss -g php-dev.yaml --vars vars/7_0.yaml validate --max-concurrent 4 --format documentation

test-cli-7.0: tests/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		bearstech/php-cli:7.0 \
		goss -g php-dev.yaml --vars vars/7_0.yaml validate --max-concurrent 4 --format documentation

test-composer-7.0: tests/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		bearstech/php-composer:7.0 \
		/bin/bash -c "goss -g php-composer.yaml --vars vars/7_0.yaml validate --max-concurrent 4 --format documentation && goss -g php_test_composer.yaml validate --format documentation"

test-7.1: tests/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		--entrypoint "" \
		bearstech/php:7.1 \
		goss -g php-dev.yaml --vars vars/7_1.yaml validate --max-concurrent 4 --format documentation

test-cli-7.1: tests/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		bearstech/php-cli:7.1 \
		goss -g php-dev.yaml --vars vars/7_1.yaml validate --max-concurrent 4 --format documentation

test-composer-7.1: tests/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		bearstech/php-composer:7.1 \
		/bin/bash -c "goss -g php-composer.yaml --vars vars/7_1.yaml validate --max-concurrent 4 --format documentation && goss -g php_test_composer.yaml validate --format documentation"

test-7.2: tests/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		--entrypoint "" \
		bearstech/php:7.2 \
		goss -g php-dev.yaml --vars vars/7_2.yaml validate --max-concurrent 4 --format documentation

test-cli-7.2: tests/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		bearstech/php-cli:7.2 \
		goss -g php-dev.yaml --vars vars/7_2.yaml validate --max-concurrent 4 --format documentation

test-composer-7.2: tests/bin/goss
	@docker run --rm -t \
		-v `pwd`/tests/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		bearstech/php-composer:7.2 \
		/bin/bash -c "goss -g php-composer.yaml --vars vars/7_2.yaml validate --max-concurrent 4 --format documentation && goss -g php_test_composer.yaml validate --format documentation"

test-html-7.0: tests/bin/goss
	make -C tests do_docker_compose PHP_VERSION=7.0

test-html-7.1: tests/bin/goss
	make -C tests do_docker_compose PHP_VERSION=7.1

test-html-7.2: tests/bin/goss
	make -C tests do_docker_compose PHP_VERSION=7.2

test-html: test-html-7.0 test-html-7.1 test-html-7.2

tests-7.0: test-7.0 test-cli-7.0 test-composer-7.0 test-html-7.0

tests-7.1: test-7.1 test-cli-7.1 test-composer-7.1 test-html-7.1

tests-7.2: test-7.2 test-cli-7.2 test-composer-7.2 test-html-7.2

tests: tests-7.0 tests-7.1 tests-7.2
