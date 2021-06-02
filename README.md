PHP docker images by bearstech
===============================

3 variants of PHP7 from Debian :

- composer: [bearstech/php-composer](https://hub.docker.com/r/bearstech/php-composer/)
- cli: [bearstech/php-cli](https://hub.docker.com/r/bearstech/php-cli/)
- fpm: [bearstech/php](https://hub.docker.com/r/bearstech/php/)

All variants are available as tag for PHP 7.0, 7.1, 7.2 and 7.3

Dockerfiles
-----------

Dockerfiles are available at https://github.com/factorysh/docker-php

Usage
-----

```
docker run --rm bearstech/php:7.3
docker run --rm bearstech/php-cli:7.3
docker run --rm bearstech/php-composer:7.3
```

Composer
--------

In `bearstech/php-composer` images, `composer` is the latest stable version : 2.x now.
The `composer1` command is here to help your migration to *Composer 2*, `composer1` version 1.10.x.

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

Session
-------

Default session handler is a file.

If you set `SESSION_REDIS_URL`, the will use Redis as a session handler.

See https://github.com/phpredis/phpredis

Entrypoint.d
------------

All php images implements the concept of `entrypoint.d`.

With `entrypoint.d` user can trigger custom actions before application startup
(entrypoint).

Just put your scripts and executable in the `/entrypoint.d` directory of your php
containers. On startup, each executable file inside this directory will be
run in an independent bash process.

Entrypoint.d runs files marked as executable, in **alphabetical order**. You can look
for an example inside `/entrypoint.d`

Since each container runs `entrypoint.d` scripts, this is not **the
recommanded way** to run migrations :
**if you have N replicas, migrations will be run N times**
