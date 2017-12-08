#!/usr/bin/env bash

# Generated environment for CRON jobs
/usr/bin/printenv | sed 's/^\(.*\)$/export \1/g' | grep -E "^export TZ|RECEIVE_IMAP" > /var/local/redmine/scripts/receive_imap_env.sh
/usr/bin/printenv | sed 's/^\(.*\)$/export \1/g' | grep -E "^export TZ|GIT_SYNC_" > /var/local/redmine/scripts/update-repositories.env.sh

# Start cron in background
/usr/sbin/cron

crontab -u root /var/local/redmine/redmine.crontab

while ! nc -z mysql 3306; do
    echo "Waiting for mysql server mysql:3306 ..."
    sleep 1
done

/var/local/redmine/scripts/update_configuration.py

gem install bundler --pre

bundle install

/docker-entrypoint.sh rails server -b 0.0.0.0
