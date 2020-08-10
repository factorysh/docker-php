#!/bin/bash

/usr/local/bin/config_msmtp.sh

WORKERS=${WORKERS:-5} SLOWLOGTIMEOUT=${SLOWLOGTIMEOUT:-0} TIMEOUT=${TIMEOUT:-0} MEMORYLIMIT=${MEMORYLIMIT:-128M} USER=$(id -un) envsubst < "/opt/www.conf.tpl" > "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"

/usr/local/bin/entrypoint.d.sh

exec "$@"
