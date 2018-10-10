ARG PHP_VERSION
FROM bearstech/php:${PHP_VERSION}

ARG UID=1001

RUN useradd alice --uid ${UID} --shell /bin/bash
COPY www /var/www/web

USER alice
