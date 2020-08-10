#!/bin/bash

/usr/local/bin/config_msmtp.sh

/usr/local/bin/entrypoint.d.sh

exec "$@"
