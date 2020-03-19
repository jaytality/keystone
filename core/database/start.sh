#!/bin/sh

# create folders
mkdir -p data/logs
mkdir -p data/db
mkdir -p data/pma/sessions

# create log files as necessary
[ -e "data/logs/access.log" ] || touch "data/logs/access.log"
[ -e "data/logs/error.log" ] || touch "data/logs/error.log"

docker-compose up -d
