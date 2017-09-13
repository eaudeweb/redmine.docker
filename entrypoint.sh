#!/usr/bin/env bash

# Start cron in background
/usr/sbin/cron

crontab -u root /var/local/redmine/redmine.crontab

while ! nc -z mysql 3306; do
    echo "Waiting for mysql server mysql:3306 ..."
    sleep 1
done

/var/local/redmine/scripts/update_configuration.py

/docker-entrypoint.sh rails server -b 0.0.0.0
