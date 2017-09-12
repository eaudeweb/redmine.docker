#!/bin/bash

# Start cron in background
/usr/sbin/cron

# Register cron jobs
crontab -u root /var/local/redmine/redmine.crontab

# Update redmine configuration
/var/local/redmine/scripts/update_configuration.py

# Start redmine
/docker-entrypoint.sh rails server -b 0.0.0.0
