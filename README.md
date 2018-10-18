PHP docker images
=================

3 variants of PHP7 from Debian Stretch : cli, compose and fpm
for PHP 7.0, 7.1 and 7.2


Build
-----

    make

Tests
-----

    make tests

Usage
-----

### User

fpm images needs a specific user, not root, in your `Dockerfile`, use something like :

    RUN useradd alice --shell /bin/bash
    COPY www /var/www/web
    USER alice

If you are using a `volume`, be carefuls with uids :

    ARG UID=1001
    RUN useradd alice --uid ${UID} --shell /bin/bash
    COPY www /var/www/web
    USER alice

and build the image with a `build-arg` like :

    --build-arg UID=`id -u`
