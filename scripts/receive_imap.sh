#!/bin/bash

export PATH=/usr/local/bin:$PATH
export GEM_HOME=/usr/local/bundle
export GEM_PATH=/usr/local/bundle/gems:/usr/local/lib/ruby/gems/2.4.0
export BUNDLE_APP_CONFIG=/usr/local/bundle
export BUNDLE_BIN=/usr/local/bundle/bin
export BUNDLE_PATH=/usr/local/bundle

/usr/local/bundle/bin/rake -f /usr/src/redmine/Rakefile redmine:email:receive_imap RAILS_ENV="production" \
	host=${RECEIVE_IMAP_HOST} port=${RECEIVE_IMAP_PORT} ssl=${RECEIVE_IMAP_SSL} \
	username=${RECEIVE_IMAP_USERNAME} password=${RECEIVE_IMAP_PASSWORD} \
	project=${RECEIVE_IMAP_PROJECT} tracker=task status=new priority=normal category=helpdesk \
	folder=${RECEIVE_IMAP_FOLDERS} project_from_subaddress=${RECEIVE_IMAP_USERNAME}
	allow_override=project,tracker,status,priority \
	unknown_user=create no_permission_check=1 \
	move_on_success=DONE move_on_failure=ERRORS
