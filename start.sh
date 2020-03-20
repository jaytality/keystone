#!/bin/bash

#
# CONFIG SETTINGS
# change these as needed!
#
NET_NAME='corenetwork'
SQL_PASS='password'
SSL_MAIL='sslemail@address.local'

# portainer specific
PORTAINER_URL='portainer.local'
PORTAINER_PORT='9000'

############################## DO NOT EDIT BELOW THIS LINE ##############################

NOCOLOR='\e[0m'
RED='\e[31m'
GREEN='\e[32m'
ORANGE='\e[33m'
BLUE='\e[34m'
PURPLE='\e[35m'
CYAN='\e[36m'
LIGHTGRAY='\e[37m'
DARKGRAY='\e[1;30m'
LIGHTRED='\e[1;31m'
LIGHTGREEN='\e[1;32m'
YELLOW='\e[1;33m'
LIGHTBLUE='\e[1;34m'
LIGHTPURPLE='\e[1;35m'
LIGHTCYAN='\e[1;36m'
WHITE='\e[1;37m'

destroy_all() {
    echo
    echo -e "${LIGHTRED}THIS IS IRREVERSIBLE${NOCOLOR}"
    read -p "Do you really want to remove everything? [y/N]: " remove
    until [[ "$remove" =~ ^[yYnN]*$ ]]; do
        echo "$remove: invalid selection."
        echo
        read -p "Do you really want to remove everything? [y/N]: " remove
    done
    if [[ "$remove" =~ ^[yY]$ ]]; then
        echo
        # stop all containers
        echo -ne "[ ${RED}STOPPING    ${NOCOLOR} ] keystone containers ...\033[0K\r"
        docker stop nginx-gen > /dev/null 2>&1
        docker stop nginx-letsencrypt > /dev/null 2>&1
        docker stop nginx-web > /dev/null 2>&1
        docker stop db-admin > /dev/null 2>&1
        docker stop db-core > /dev/null 2>&1
        echo -ne "[ ${LIGHTRED}STOPPED     ${NOCOLOR} ] keystone containers\033[0K\r"
        echo

        # removing containers
        echo -ne "[ ${RED}REMOVING    ${NOCOLOR} ] keystone containers ...\033[0K\r"
        docker rm nginx-gen > /dev/null 2>&1
        docker rm nginx-letsencrypt > /dev/null 2>&1
        docker rm nginx-web > /dev/null 2>&1
        docker rm db-admin > /dev/null 2>&1
        docker rm db-core > /dev/null 2>&1
        echo -ne "[ ${LIGHTRED}REMOVED     ${NOCOLOR} ] keystone containers\033[0K\r"
        echo

        # removing docker network
        echo -ne "[ ${RED}REMOVING    ${NOCOLOR} ] keystone network: ${NET_NAME} ...\033[0K\r"
        docker network rm ${NET_NAME} > /dev/null 2>&1
        echo -ne "[ ${LIGHTRED}REMOVED     ${NOCOLOR} ] keystone network: ${NET_NAME}\033[0K\r"
        echo

        echo
    else
        echo
        echo -e "${LIGHTGREEN}Destruction Aborted!${NOCOLOR} Phew..."
        echo
    fi
}

show_menu() {
    case "$1" in
        'main')
        echo
        echo -e "Keystone Launcher"
        echo -e "================="
        echo
        echo -e "What do you want to deploy?"
        echo -e "   1) Deploy Keystone Core infrastructure"
        echo -e "   2) [ ${LIGHTGREEN}START${NOCOLOR} ] keystone infrastructure containers"
        echo -e "   3) [ ${LIGHTRED}STOP ${NOCOLOR} ] keystone infrastructure containers"
        echo
        echo -e "   5) ${RED}DESTROY EVERYTHING${NOCOLOR}"
        echo
        echo
        echo
        echo
        echo -e "   0) ${WHITE}EXIT${NOCOLOR}"
        echo
        ;;
    esac
}

#
# OUTPUT/INTERFACE
#
clear
show_menu main

# take input
read -p "Select an option: " option
until [[ "$option" =~ ^[0-8]$ ]]; do
    echo -e "$option: invalid selection."
    read -p "Select an option: " option
done

case "$option" in
    1)
        # clearing .git so it doesn't cause issues
        #rm -rf ./.git

        echo
        echo -e "[ ${LIGHTPURPLE}STARTING    ${NOCOLOR} ] Keystone Core Infrastructure"
        echo

        #
        # docker network create
        #
        if [ ! "$(docker network ls | grep ${NET_NAME})" ]; then
            echo -ne "[ ${GREEN}DEPLOYING   ${NOCOLOR} ] CORE: docker container network ${NET_NAME} ...\033[0K\r"
            docker network create -d bridge --subnet 172.25.0.0/16 --gateway 172.25.0.1 --ip-range= ${NET_NAME} > /dev/null 2>&1
            echo -ne "[ ${LIGHTGREEN}SUCCESS     ${NOCOLOR} ] CORE: docker network ${NET_NAME} successfully created, continuing..."
        else
            echo -e "[ ${LIGHTRED}EXISTS      ${NOCOLOR} ] ${NET_NAME} docker network already exists, skipping..."
        fi
        echo

        #
        # launch:
        #   nginx-web
        #   nginx-letsencrypt
        #   nginx-gen
        #
        echo -ne "[ ${GREEN}DEPLOYING   ${NOCOLOR} ] CORE: proxy containers ...\033[0K\r"
        echo -ne "[ ${GREEN}CONFIGURING ${NOCOLOR} ] CORE: proxy network ...\033[0K\r"
        printf "\nNETWORK=${NET_NAME}\n" >> ./core/proxy/.env
        echo -ne "[ ${LIGHTGREEN}SUCCESS     ${NOCOLOR} ] CORE: proxy network configured\033[0K\r"
        echo -ne "[ ${GREEN}STARTING    ${NOCOLOR} ] CORE: proxy containers ...\033[0K\r"
        cd core/proxy && docker-compose up -d > /dev/null 2>&1
        echo -ne "[ ${LIGHTGREEN}SUCCESS     ${NOCOLOR} ] CORE: proxy containers started\033[0K\r"
        cd ../..
        echo

        #
        # launch:
        #    db-core
        #    db-admin
        #
        echo -ne "[ ${GREEN}DEPLOYING   ${NOCOLOR} ] CORE: database containers ...\033[0K\r"
        cd core/database

        # create folders
        mkdir -p data/logs
        mkdir -p data/db
        mkdir -p data/pma/sessions

        echo -ne "[ ${GREEN}CONFIGURING ${NOCOLOR} ] CORE: db core container ...\033[0K\r"
        printf "\nMYSQL_PASSWORD=${SQL_PASS}\n" >> .env
        printf "\nNET_NAME=${NET_NAME}\n" >> .env
        echo -ne "[ ${LIGHTGREEN}SUCCESS     ${NOCOLOR} ] CORE: db core container configured\033[0K\r"

        echo -ne "[ ${GREEN}STARTING    ${NOCOLOR} ] CORE: database containers ...\033[0K\r"
        docker-compose up -d > /dev/null 2>&1
        echo -ne "[ ${LIGHTGREEN}SUCCESS     ${NOCOLOR} ] CORE: database containers started\033[0K\r"

        cd ../..
        echo

        #
        # launch:
        #   portainer
        #
        cd core/portainer
        echo -ne "[ ${GREEN}DEPLOYING   ${NOCOLOR} ] CORE: portainer orchestration containers ...\033[0K\r"
        echo -ne "[ ${GREEN}CONFIGURING ${NOCOLOR} ] CORE: portainer orchestration container ...\033[0K\r"
        printf "\nPORTAINER_URL=${PORTAINER_URL}\n" >> .env
        printf "\nPORTAINER_PORT=${PORTAINER_PORT}\n" >> .env
        printf "\nSSL_MAIL=${SSL_MAIL}\n" >> .env
        printf "\nNET_NAME=${NET_NAME}\n" >> .env
        echo -ne "[ ${LIGHTGREEN}SUCCESS     ${NOCOLOR} ] CORE: portainer orchestration container configured\033[0K\r"

        echo -ne "[ ${GREEN}STARTING    ${NOCOLOR} ] CORE: portainer orchestration containers ...\033[0K\r"
        docker-compose up -d > /dev/null 2>&1
        echo -ne "[ ${LIGHTGREEN}SUCCESS     ${NOCOLOR} ] CORE: portainer orchestration containers started\033[0K\r"

        cd ../..
        echo

        # end of deployments
        echo
        exit;;

    2)
        echo
        echo -ne "[ ${GREEN}STARTING    ${NOCOLOR} ] CORE: all containers ...\033[0K\r"
        cd core/portainer && docker-compose up -d && cd ../.. > /dev/null 2>&1
        cd core/database && docker-compose up -d && cd ../.. > /dev/null 2>&1
        cd core/proxy && docker-compose up -d && cd ../.. > /dev/null 2>&1
        echo -ne "[ ${LIGHTRED}STARTED     ${NOCOLOR} ] CORE: all containers\033[0K\r"
        echo
        exit;;

    3)
        echo
        echo -ne "[ ${RED}STOPPING    ${NOCOLOR} ] CORE: all containers ...\033[0K\r"
        cd core/portainer && docker-compose down && cd ../.. > /dev/null 2>&1
        cd core/database && docker-compose down && cd ../.. > /dev/null 2>&1
        cd core/proxy && docker-compose down && cd ../.. > /dev/null 2>&1
        echo -ne "[ ${LIGHTRED}STOPPED     ${NOCOLOR} ] CORE: all containers\033[0K\r"
        echo
        exit;;

    5)
        echo
        echo -e "${WHITE}INITIATING DESTRUCT SEQUENCE...${NOCOLOR}"
        destroy_all
        exit;;
    0)
        echo
        echo -e "Goodbye!"
        exit;;
esac

