#!/bin/bash

if [ -n "${SESSION_REDIS_URL}" ]; then
	conf="
php_admin_value[session.save_handler] = redis
php_admin_value[session.save_path] = ${SESSION_REDIS_URL}
"
	echo "$conf" >> "/etc/php/${PHP_VERSION}/fpm/pool.d/www.conf"
	echo "Redis session"
else
	echo "Plain old session"
fi

