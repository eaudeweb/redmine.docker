#!/bin/sh

# External variables
# - REDMINE_API_KEY
GIT_SYNC_FOLDER="/var/local/redmine/repositories"

RESET='\033[0m'
ERROR='\033[0;31m'
WARN='\033[0;33m'
INFO='\033[0;32m'

# Check script can run safely
prerequisites() {
	git=`command -v git`
	if [ -z "$git" ]; then
		echo -e "${ERROR}Command 'git' is missing, failing ...${RESET}"
		exit 1
	fi

	if [ -z "${REDMINE_API_KEY}" ]; then
		echo -e "${ERROR}REDMINE_API_KEY environment variable is missing, ignoring ...${RESET}"
		exit 0
	fi

	if [ ! -d ${GIT_SYNC_FOLDER} ]; then
		echo -e "${ERROR}Cannot find repositories storage ${GIT_SYNC_FOLDER}, ignoring ...${RESET}"
		exit 0
	fi
}

redmine_update() {
	curl -q "http://localhost:3000/sys/fetch_changesets?key=${REDMINE_API_KEY}"
}

# Clone repositories
update_repositories() {
	for REPO_DIR in ${GIT_SYNC_FOLDER}/*
	do
		if [ -d ${REPO_DIR} ]; then
			cd ${REPO_DIR} && git fetch -q origin +refs/heads/*:refs/heads/* && git reset --soft
		fi
	done
}

prerequisites;
update_repositories;
redmine_update;
