#!/usr/bin/env bash

# Generated environment for CRON jobs
/usr/bin/printenv | sed 's/^\(.*\)$/export \1/g' | grep -E "^export TZ|RECEIVE_IMAP" > /var/local/redmine/scripts/env_receive_imap.sh
/usr/bin/printenv | sed 's/^\(.*\)$/export \1/g' | grep -E "^export TZ|REDMINE_API_KEY" > /var/local/redmine/scripts/env_update_repositories.sh

# Start cron in background
/usr/sbin/cron

crontab -u root /var/local/redmine/crontab

while ! nc -z mysql 3306; do
    echo "Waiting for mysql server mysql:3306 ..."
    sleep 1
done

/var/local/redmine/scripts/update_configuration.py

gem install bundler --pre

bundle install

/docker-entrypoint.sh rails server -b 0.0.0.0
