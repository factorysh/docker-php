#!/usr/bin/env bash

# Test from the outside if docker logs sees smtp logs

# It should looks like this
# Nov 04 15:22:42 host=mails tls=off auth=on user=test from=test@example.com
# recipients=toto@toto.com mailsize=102 smtpstatus=250 smtpmsg='250 Ok: queued
# as LilHC9UgLoGz7IiNZmuXSGaNTKqFsENYlOkOmik33zc=@mailhog.example'
# exitcode=EX_OK

TEST_LINE="host=mails tls=off auth=on user=test from=test@example.com"
FILE="/goss/smtp_logs_output"

if grep "$TEST_LINE" "$FILE" ; then
	exit 0
else
	exit 1
fi
