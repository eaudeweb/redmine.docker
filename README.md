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

    cp .env.example .env
    vim .env


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

## Adding support for repositories

To track changes from remote repositories, enter the redmine repository and clone them locally, for instance:

```
#> docker exec -ti redmine bash
#> cd /var/local/redmine/repositories
#> git clone --mirror https://github.com/account/repo.git
```

A cron task will update the repository every 15 minutes.

### Local development and testing

If you want to test changes locally:

1. build a custom image locally `docker build -t eaudeweb/redmine-local .`
1. Copy `docker-compose.dev.yml` to `docker-compose.override.yml` to include the local image.


#### To reset your password

Enter MySQL container

```
docker exec -ti redmine_mysql mysql -ps3cr3t redmine -e "UPDATE users SET auth_source_id = NULL WHERE id = XX"
```


[![Docker](https://dockerbuildbadges.quelltext.eu/status.svg?organization=eaudeweb&repository=redmine)](https://hub.docker.com/r/eaudeweb/redmine/builds)

2017
