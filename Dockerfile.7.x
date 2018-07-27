FROM bearstech/debian:stretch

ARG PHP_MINOR_VERSION
ENV PHP_VERSION=7.${PHP_MINOR_VERSION}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN set -eux \
    &&  apt-get update \
    &&  apt-get install -y --no-install-recommends \
                      curl \
                      ca-certificates \
                      apt-transport-https \
                      lsb-release \
                      ca-certificates \
    &&  apt-get clean \
    &&  rm -rf /var/lib/apt/lists/* \
    &&  curl https://packages.sury.org/php/apt.gpg -o /etc/apt/trusted.gpg.d/php-sury.gpg \
    &&  echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/php-sury.list \
    &&  apt-get update \
    &&  apt-get install -y --no-install-recommends \
                      msmtp \
                      php7.${PHP_MINOR_VERSION}-mysql \
                      php7.${PHP_MINOR_VERSION}-curl \
                      php7.${PHP_MINOR_VERSION}-json \
                      php7.${PHP_MINOR_VERSION}-gd \
                      php7.${PHP_MINOR_VERSION}-intl \
                      php7.${PHP_MINOR_VERSION}-mbstring \
                      php7.${PHP_MINOR_VERSION}-xml \
                      php7.${PHP_MINOR_VERSION}-zip \
                      php7.${PHP_MINOR_VERSION}-fpm \
                      php7.${PHP_MINOR_VERSION}-readline \
    &&  if [ "${PHP_MINOR_VERSION}" = "1" ]; then \
            apt-get install -y --no-install-recommends php7.${PHP_MINOR_VERSION}-mcrypt; \
        fi \
    &&  apt-get clean \
    &&  rm -rf /var/lib/apt/lists/* \
    &&  phpdismod \
                     ftp \
                     shmop \
                     wddx \
    &&  ln -s /usr/bin/msmtp /usr/local/bin/sendmail \
    &&  mkdir /var/log/php \
    &&  ln -sf /proc/1/fd/2 /var/log/php/php7.${PHP_MINOR_VERSION}-fpm.log \
    &&  ln -sf /proc/1/fd/2 /var/log/php/www.error.log \
    &&  ln -sf /proc/1/fd/1 /var/log/php/www.access.log \
    &&  ln -sf /dev/null    /var/log/php/www.slow.log \
    &&  ln -sf /proc/1/fd/2 /var/log/msmtp.log

SHELL ["/bin/sh", "-c"]

COPY conf/www.conf /etc/php/7.${PHP_MINOR_VERSION}/fpm/pool.d/www.conf
COPY conf/php7.${PHP_MINOR_VERSION}-fpm.conf /etc/php/7.${PHP_MINOR_VERSION}/fpm/php-fpm.conf

RUN set -eux \
    &&  chmod 700 /etc/php/7.${PHP_MINOR_VERSION}/fpm/pool.d \
    &&  chmod 600 /etc/php/7.${PHP_MINOR_VERSION}/fpm/pool.d/www.conf \
    &&  chown -R www-data /etc/php/7.${PHP_MINOR_VERSION}/fpm/pool.d \
    &&  touch /etc/msmtprc \
    &&  chmod 755 /etc/msmtprc

COPY entrypoint /usr/local/bin/entrypoint
EXPOSE 9000
USER www-data

ENTRYPOINT ["entrypoint"]
CMD /usr/sbin/php-fpm${PHP_VERSION}
