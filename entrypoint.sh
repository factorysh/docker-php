#!/bin/bash

/usr/local/bin/config_msmtp.sh

export WORKERS=${WORKERS:-5}
export USER=$(id -u)
envsubst < "/opt/www.conf.tpl" > "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"

exec "$@"
