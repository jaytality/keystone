# Keystone

> ### **Keystone**
>
> _A central stone at the summit of an arch, locking the whole together._

This project was developed for rapidly deploying a core set of services that I'd need for hosting web-based projects

## Requirements

* Docker must be installed on the server
* Bash script must be supported

## What's Deployed

* A **corenetwork** docker network is created; so everything sits on a `172.32.0.0/16` network range

| container | description |
| --------- | ----------- |
| **nginx-proxy** | web proxy server to redirect URLs to different containers |
| **nginx-letsencrypt** | free SSL certificate generation (for production deployments) |
| **nginx-gen** | proxy config generation when new containers are made |
| **db-core** | database server container |
| **db-admin** | database admin webUI container |
| **portainer** | Portainer.io container orchestration webUI container |

## Hosts

You'll need to edit your OS's hosts file to be able to access certain features

| host | ip | description |
| ---- | -- | ----------- |
| portainer.local | 127.0.0.1 | access portainer for container orchestration |
| dbadmin.local | 127.0.0.1 | access database admin UI |
