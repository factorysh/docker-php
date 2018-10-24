PHP docker images by bearstech
===============================

3 variants of PHP7 from Debian Stretch :

- composer: [bearstech/php-composer](https://hub.docker.com/r/bearstech/php-composer/)
- cli: [bearstech/php-cli](https://hub.docker.com/r/bearstech/php-cli/)
- fpm: [bearstech/php](https://hub.docker.com/r/bearstech/php/)

All variants are available as tag for PHP 7.0, 7.1 and 7.2

Dockerfiles
-----------

Dockerfiles are available at https://github.com/factorysh/docker-php

Usage
-----

```
docker run --rm bearstech/php:7.2
docker run --rm bearstech/php-cli:7.2
docker run --rm bearstech/php-composer:7.2
```

User
----

fpm images needs a specific user, not root.
In your `Dockerfile`, use something like :

```
RUN useradd alice --shell /bin/bash
COPY www /var/www/web
USER alice
```

If you are using a `volume`, be carefuls with uids :

```
ARG UID=1001
RUN useradd alice --uid ${UID} --shell /bin/bash
COPY www /var/www/web
USER alice
```

and build the image with a `build-arg` like :
```
--build-arg UID=`id -u`
```
