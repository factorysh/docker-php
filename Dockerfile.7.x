ARG PHP_MINOR_VERSION
FROM bearstech/php-cli:7.${PHP_MINOR_VERSION}

ARG PHP_MINOR_VERSION
# Yes, twice ARG, it's a bug

ENV PHP_VERSION=7.${PHP_MINOR_VERSION}
ENV DEBIAN_FRONTEND noninteractive

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG HTTP_PROXY=""
RUN set -eux \
    &&  export http_proxy=${HTTP_PROXY} \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
                      dumb-init \
                      php7.${PHP_MINOR_VERSION}-fpm \
                      php7.${PHP_MINOR_VERSION}-intl \
                      php7.${PHP_MINOR_VERSION}-json \
                      php7.${PHP_MINOR_VERSION}-readline \
                      php7.${PHP_MINOR_VERSION}-redis \
                      php7.${PHP_MINOR_VERSION}-zip \
    &&  apt-get clean \
    &&  rm -rf /var/lib/apt/lists/* \
    &&  phpdismod \
                     ftp \
                     shmop \
                     wddx \
    &&  ln -s /usr/sbin/php-fpm7.${PHP_MINOR_VERSION} /usr/sbin/php-fpm \
    &&  mkdir /var/log/php \
    &&  ln -sf /proc/1/fd/2 /var/log/php/php7.${PHP_MINOR_VERSION}-fpm.log \
    &&  ln -sf /proc/1/fd/2 /var/log/php/www.error.log \
    &&  ln -sf /proc/1/fd/1 /var/log/php/www.access.log \
    &&  ln -sf /proc/1/fd/2 /var/log/php/www.slow.log

SHELL ["/bin/sh", "-c"]

COPY conf/php7.${PHP_MINOR_VERSION}.ini /etc/php/7.${PHP_MINOR_VERSION}/fpm/php.ini
COPY conf/www.conf /opt/www.conf.tpl
COPY conf/php7.${PHP_MINOR_VERSION}-fpm.conf /etc/php/7.${PHP_MINOR_VERSION}/fpm/php-fpm.conf

RUN set -eux \
    &&  chmod 777 /etc/php/7.${PHP_MINOR_VERSION}/fpm/pool.d \
    &&  chmod 444 /opt/www.conf.tpl \
    &&  rm -f /etc/php/7.${PHP_MINOR_VERSION}/fpm/pool.d/www.conf \
    &&  touch /etc/msmtprc \
    &&  chmod 666 /etc/msmtprc

LABEL sh.factory.probe.fpm.path=/__status

EXPOSE 9000

COPY entrypoint.sh /usr/local/bin/
COPY workers.php /usr/local/bin/

# Entrypoint.d
COPY entrypoint.d.sh /usr/local/bin/
COPY entrypoint.d /entrypoint.d/

ENTRYPOINT ["entrypoint.sh"]
CMD ["dumb-init", "/usr/sbin/php-fpm"]

# generated labels

ARG GIT_VERSION
ARG GIT_DATE
ARG BUILD_DATE

LABEL \
    com.bearstech.image.revision.date=${GIT_DATE} \
    org.opencontainers.image.authors=Bearstech \
    org.opencontainers.image.revision=${GIT_VERSION} \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.url=https://github.com/factorysh/docker-php \
    org.opencontainers.image.source=https://github.com/factorysh/docker-php/blob/${GIT_VERSION}/Dockerfile.7.x
