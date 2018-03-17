#!/usr/bin/env sh

find /usr/local/etc/cron.d -name  "*.job" | xargs cat | crontab -

crond -f
