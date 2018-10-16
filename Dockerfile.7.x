ARG PHP_MINOR_VERSION
FROM bearstech/php-cli:7.${PHP_MINOR_VERSION}

ARG PHP_MINOR_VERSION
# Yes, twice ARG, it's a bug

ENV PHP_VERSION=7.${PHP_MINOR_VERSION}

USER root
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN set -eux \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
                      php7.${PHP_MINOR_VERSION}-fpm \
                      php7.${PHP_MINOR_VERSION}-intl \
                      php7.${PHP_MINOR_VERSION}-json \
                      php7.${PHP_MINOR_VERSION}-readline \
                      php7.${PHP_MINOR_VERSION}-zip \
    &&  apt-get clean \
    &&  rm -rf /var/lib/apt/lists/* \
    &&  phpdismod \
                     ftp \
                     shmop \
                     wddx \
                     zip \
    &&  ln -s /usr/sbin/php-fpm7.${PHP_MINOR_VERSION} /usr/sbin/php-fpm \
    &&  mkdir /var/log/php \
    &&  ln -sf /proc/1/fd/2 /var/log/php/php7.${PHP_MINOR_VERSION}-fpm.log \
    &&  ln -sf /proc/1/fd/2 /var/log/php/www.error.log \
    &&  ln -sf /proc/1/fd/1 /var/log/php/www.access.log \
    &&  ln -sf /dev/null    /var/log/php/www.slow.log

SHELL ["/bin/sh", "-c"]

COPY conf/php7.${PHP_MINOR_VERSION}.ini /etc/php/7.${PHP_MINOR_VERSION}/fpm/php.ini
COPY conf/www.conf /etc/php/7.${PHP_MINOR_VERSION}/fpm/pool.d/www.conf
COPY conf/php7.${PHP_MINOR_VERSION}-fpm.conf /etc/php/7.${PHP_MINOR_VERSION}/fpm/php-fpm.conf

RUN set -eux \
    &&  chmod 700 /etc/php/7.${PHP_MINOR_VERSION}/fpm/pool.d \
    &&  chmod 600 /etc/php/7.${PHP_MINOR_VERSION}/fpm/pool.d/www.conf \
    &&  chown -R www-data /etc/php/7.${PHP_MINOR_VERSION}/fpm/pool.d \
    &&  chown www-data /etc/msmtprc

COPY entrypoint.sh /usr/local/bin/

LABEL sh.factory.probe.fpm.path=/__path

EXPOSE 9000
USER www-data

ENTRYPOINT ["entrypoint.sh"]
CMD ["/usr/sbin/php-fpm"]
