#!/bin/bash

/usr/local/bundle/bin/rake -f /usr/src/redmine/Rakefile redmine:email:receive_imap RAILS_ENV="production" \
	host=${RECEIVE_IMAP_HOST} port=${RECEIVE_IMAP_PORT} ssl=${RECEIVE_IMAP_SSL} \
	username=${RECEIVE_IMAP_USERNAME} password=${RECEIVE_IMAP_PASSWORD} \
	project=informea tracker=support status=new priority=normal \
	allow_override=project,tracker,status,priority
