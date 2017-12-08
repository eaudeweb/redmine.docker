#!/usr/bin/env bash

# Generated environment for CRON jobs
echo "export TZ=\"${TZ}\""  >> /var/local/redmine/scripts/update-repositories-env.sh
echo "export GIT_SYNC_FOLDER=\"${GIT_SYNC_FOLDER}\""  >> /var/local/redmine/scripts/update-repositories-env.sh
echo "export GIT_SYNC_REPO_LIST=\"${GIT_SYNC_REPO_LIST}\""  >> /var/local/redmine/scripts/update-repositories-env.sh
echo "export GIT_SYNC_REDMINE_URL=\"${GIT_SYNC_REDMINE_URL}\""  >> /var/local/redmine/scripts/update-repositories-env.sh

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
