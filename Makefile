.PHONY: tests

GOSS_VERSION := 0.3.5

pull:
	docker pull bearstech/debian:stretch

7: 7-fpm 7-composer

7-fpm:
	docker build -t bearstech/php:7.0 -f Dockerfile.7 .
	docker tag bearstech/php:7.0 bearstech/php:7
	docker tag bearstech/php:7 bearstech/php:latest

7-cli:
	docker build -t bearstech/php-cli:7.0 -f Dockerfile.7-cli .
	docker tag bearstech/php-cli:7.0 bearstech/php-cli:7
	docker tag bearstech/php-cli:7.0 bearstech/php-cli:latest

7-composer: 7-cli
	docker build -t bearstech/php-composer:7.0 -f Dockerfile.7-composer .
	docker tag bearstech/php-composer:7.0 bearstech/php-composer:7
	docker tag bearstech/php-composer:7.0 bearstech/php-composer:latest

push:
	docker push bearstech/php:7.0
	docker push bearstech/php:7
	docker push bearstech/php:latest
	docker push bearstech/php-cli:7.0
	docker push bearstech/php-cli:7
	docker push bearstech/php-cli:latest
	docker push bearstech/php-composer:7.0
	docker push bearstech/php-composer:7
	docker push bearstech/php-composer:latest

clean:
	rm -rf bin

bin/goss:
	mkdir -p bin
	curl -o bin/goss -L https://github.com/aelsabbahy/goss/releases/download/v${GOSS_VERSION}/goss-linux-amd64
	chmod +x bin/goss

test-7.0: bin/goss
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		bearstech/php:7.0 \
		goss -g php-dev.yaml --vars vars/7_0.yaml validate --max-concurrent 4 --format documentation

test-cli-7.0: bin/goss
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		bearstech/php-cli:7.0 \
		goss -g php-dev.yaml --vars vars/7_0.yaml validate --max-concurrent 4 --format documentation

test-composer-7.0: bin/goss
	@docker run --rm -t \
		-v `pwd`/bin/goss:/usr/local/bin/goss \
		-v `pwd`/tests:/goss \
		-w /goss \
		bearstech/php-composer:7.0 \
		goss -g php-composer.yaml --vars vars/7_0.yaml validate --max-concurrent 4 --format documentation

tests: test-7.0 test-cli-7.0 test-composer-7.0
