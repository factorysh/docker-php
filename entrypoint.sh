#!/bin/bash

/usr/local/bin/config_msmtp.sh

WORKERS=${WORKERS:-5}
sed -i "s/^pm\\.max_children = .*$/pm\\.max_children = ${WORKERS}/" "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"

exec "$@"
