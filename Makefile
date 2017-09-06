
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
