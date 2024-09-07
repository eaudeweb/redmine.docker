#!/bin/bash

export PATH=/usr/local/bin:$PATH
export GEM_HOME=/usr/local/bundle
export BUNDLE_APP_CONFIG=/usr/local/bundle

/usr/local/bundle/bin/rake -f /usr/src/redmine/Rakefile  redmine:check_periodictasks RAILS_ENV="production"
