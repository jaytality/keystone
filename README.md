# Keystone

> ### **Keystone**
> ###### key·​stone | \ ˈkē-ˌstōn
>
> _Something on which associated things depend for support._
>
> <sub>[Merriam-Webster Definition #2](https://www.merriam-webster.com/dictionary/keystone)</sub>
>

This project was developed for rapidly deploying a core set of services that I'd need for hosting web-based projects locally for development.
This project can also be deployed for production (no matter how the SysOps and Engineers feel about Docker in production haha)

## Requirements

* Docker must be installed on the server
* Bash script must be supported

## What's Deployed

* A **devproxy** (default name) docker network is created; so everything sits on a `172.25.0.0/16` network range

| container | description |
| --------- | ----------- |
| **nginx-proxy** | web proxy server to redirect URLs to different containers |
| **nginx-letsencrypt** | free SSL certificate generation (for production deployments) |
| **nginx-gen** | proxy config generation when new containers are made |
| **core_db** | database server container (MySQL) |
| **core_pma** | database admin webUI container (phpMyAdmin) |
| **portainer** | Portainer.io container orchestration webUI container |

## Configuration

Edit the start of `start.sh` with the settings you'd like:

```
#
# CONFIG SETTINGS
# change these as needed!
#
NET_NAME='devproxy'
SQL_PASS='password'
SSL_MAIL='sslemail@address.local'

# portainer specific
PORTAINER_URL='portainer.local'
PORTAINER_PORT='9000'
```

| setting | description |
| ------- | ----------- |
| **NET_NAME** | the internal docker network name you'll be setting for all the deployed containers |
| **SQL_PASS** | the root SQL password you'll be setting for the MySQL/phpMyAdmin containers |
| **SSL_MAIL** | the email address SSL certificates will be registered with Let's Encrypt with |
| **PORTAINER_URL** | the URL you'll access to interact with Portainer to manage everything through a pretty GUI |
| **PORTAINER_PORT** | Portainer port that'll get proxied to your `PORTAINER_URL` so you don't have to `:portnumber` after the URL |

## Local Hosts

You'll need to edit your OS's hosts file to be able to access certain features

| host | ip | description |
| ---- | -- | ----------- |
| portainer.local | 127.0.0.1 | access portainer for container orchestration |
| phpmyadmin.local | 127.0.0.1 | access database admin UI |

- - - - -

Then, as per usual, `chmod +x ./start.sh`, and run it!
