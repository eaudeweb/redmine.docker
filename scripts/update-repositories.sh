#!/bin/sh

REPO_BASEDIR="${GIT_SYNC_FOLDER}"
REPO_LIST="${GIT_SYNC_REPO_LIST}"
REDMINE_URL="${GIT_SYNC_REDMINE_URL}"

RESET='\033[0m'
ERROR='\033[0;31m'
WARN='\033[0;33m'
INFO='\033[0;32m'

# Check script can run safely
prerequisites() {
	if [ -z "${REPO_BASEDIR}" ]; then
        echo -e "${ERROR}REPO_BASEDIR environment variable is missing (set checkout base path), failing ...${RESET}"
        exit 1	
	fi

	if [ -z "${REPO_LIST}" ]; then
        echo -e "${ERROR}REPO_LIST environment variable is missing (add list of repos separated by a single space), failing ...${RESET}"
        exit 1	
	fi

	git=`command -v git`
	if [ -z "$git" ]; then
        echo -e "${ERROR}Command 'git' is missing, failing ...${RESET}"
        exit 1
	fi

	if [ ! -d ${REPO_BASEDIR} ]; then
		echo -e "${WARN}Creating repositories base directory ${REPO_BASEDIR} ...${RESET}"
		mkdir -p "${REPO_BASEDIR}"
	fi

	if [ ! -d ${REPO_BASEDIR} ]; then
		echo -e "${ERROR}Cannot find repositories storage ${REPO_BASEDIR} ...${RESET}"
		exit 1
	fi

	echo 
}

redmine_update() {
	curl -q "${REDMINE_URL}"
}

# Clone repositories
clone_or_update() {
	for repo in $REPO_LIST
	do
		DIRNAME=`basename ${repo}`
		REPO_DESTDIR="${REPO_BASEDIR}${DIRNAME}.git"
		if [ ! -d ${REPO_DESTDIR} ]
		then
			echo -e "${INFO}Cloning ${repo} to ${REPO_DESTDIR}${RESET}"
			git clone -q --mirror ${repo} ${REPO_DESTDIR}
		else
			echo -e "${INFO}Updating ${REPO_DESTDIR}${RESET}"
			cd ${REPO_DESTDIR} && git fetch -q --all
		fi
	done
}

prerequisites;
clone_or_update;
redmine_update;