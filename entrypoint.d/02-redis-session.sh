#!/bin/bash

if [ -z "${REDIS_SESSION_URL}" ]; then
	conf="
php_flag[session.save_handler] = redis
php_flag[session.path] = ${REDIS_SESSION_URL}
"
	echo "$conf" >> "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"
	echo "Redis session"
else
	echo "Plain old session"
fi

