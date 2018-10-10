#!/bin/bash

/usr/local/bin/config_msmtp.sh

WORKERS=${WORKERS:-5} USER=$(id -u) envsubst < "/opt/www.conf.tpl" > "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"

exec "$@"
