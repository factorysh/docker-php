#!/bin/bash

set -e

if [ "$WORKERS" == "auto" ]
then
	memoryLimit=${MEMORYLIMIT:-128M}
	unit=$(expr substr "$memoryLimit" \( length "$memoryLimit" \) 1)
	cpus=$(grep -c processor /proc/cpuinfo)
	ram=$(grep MemTotal: /proc/meminfo | sed -r "s/.* ([0-9]+) kB/\1/g")
fi

WORKERS=${WORKERS:-5} SLOWLOGTIMEOUT=${SLOWLOGTIMEOUT:-0} TIMEOUT=${TIMEOUT:-0} MEMORYLIMIT=${MEMORYLIMIT:-128M} USER=$(id -un) envsubst < "/opt/www.conf.tpl" > "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"

/usr/local/bin/entrypoint.d.sh

exec "$@"
