## Eau de Web Redmine setup (helpdesk.eaudeweb.ro)


### Prerequisites

- Install [Docker](https://docs.docker.com/installation/)
- Install [Compose](https://docs.docker.com/compose/install/)

### First time installation

Clone the repository

    cd /var/local/deploy
    git clone https://github.com/eaudeweb/redmine.docker
    cd redmine.docker


Edit the secrets

    cp .redmine.secret.example .redmine.secret
    vim .redmine.secret


Start redmine

    docker-compose up -d


Initial configuration

- Login using admin/admin and change password for admin user
- Go to /admin and load the default configuration
- Enable CKEditor: /settings > General > Text formatting
- Go to /settings?tab=repositories, Enable WS for repository management, generate an API key and configure fixing keywords
- Write the API key into .redmine.secret (SYNC_API_KEY), this is needed by cron job redmine_github_sync
- Create projects (enable Kanbans or Agile module)
- Configure trackers and workflows
- Add users
- etc.

[![Docker](https://dockerbuildbadges.quelltext.eu/status.svg?organization=eaudeweb&repository=redmine.docker)](https://hub.docker.com/r/eaudeweb/redmine.docker/builds)

2017
