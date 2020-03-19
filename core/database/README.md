# Database

This is a core mysql/phpmyadmin service that all the projects on a single machine can connect to

## Installation

1. Clone the Project
1. Edit the .env file with a `MYSQL_PASSWORD=` variable with your desired root password
1. Run `./start.sh` to begin! (NOTE - you might have to chmod ./start.sh so it can run on your OS)

## Usage

This will create two containers:

* core_db
* core_pma

You can interact with the service at any of the hostnames specified in `docker-compose.yml` via a PHPMyAdmin interface

### Connecting Locally via MySQL Workbench or CLI

The IP address of the **core_db** service will accept connections from Workbench or CLI - using root, and the root password
you specified in the .env file

By default, this IP address is **172.25.0.200** - you can change this if you need by editing the `docker-compose.yml`

### Provisioning to other projects

In other projects, add the following `external_links` to the docker-compose file, under each service. As an example:

```
version: '3.3'

services:
  webserver:
    image: php:7.2
    build:
      context: .
      dockerfile: Dockerfile
    external_links:
      - core_mysql
    environment:
      VIRTUAL_HOST: db.hostname.tld
      DB_HOST: core_mysql
    container_name: project_web
    volumes:
      - ../www:/var/www/html
    restart: always

networks:
    default:
      external:
        name: devproxy
```
