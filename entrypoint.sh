#!/bin/bash

set -eux

#get list of context from container : workers, max_spare_servers, start_servers
IFS=" " read -r -a context <<< "$(php /usr/local/bin/workers.php)"

WORKERS=${context[0]} MAX_SPARE_SERVERS=${context[1]} START_SERVERS=${context[2]} SLOWLOGTIMEOUT=${SLOWLOGTIMEOUT:-0} TIMEOUT=${TIMEOUT:-0} MEMORYLIMIT=${MEMORYLIMIT:-128M} USER=$(id -un) envsubst < "/opt/www.conf.tpl" > "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"

/usr/local/bin/entrypoint.d.sh

exec "$@"