#!/bin/bash

#
# CONFIG SETTINGS
# change these as needed!
#
SQL_USER='root'
SQL_PASS='password'

NET_NAME='corenetwork'

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
    docker network rm ${NET_NAME} > /dev/null 2>&1
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
        echo
        echo
        echo
        echo -e "   5) ${WHITE}EXIT${NOCOLOR}"
        echo
        echo
        echo -e "   0) ${RED}DESTROY EVERYTHING${NOCOLOR}"
        echo
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
        echo
        echo -e "[ ${LIGHTPURPLE}STARTING    ${NOCOLOR} ] Keystone Core Infrastructure"
        echo
        
        # create a docker network
        echo -ne "[ ${GREEN}DEPLOYING   ${NOCOLOR} ] CORE: docker container network ${NET_NAME} ...\033[0K\r"
        docker network create -d bridge --subnet 172.25.0.0/16 --gateway 172.25.0.1 --ip-range= ${NET_NAME}
        echo -e "[ ${LIGHTGREEN}SUCCESS     ${NOCOLOR} ] CORE: docker network ${NET_NAME} successfully created"

        # launch proxy
        echo -ne "[ ${GREEN}DEPLOYING   ${NOCOLOR} ] CORE: proxy containers ...\033[0K\r"
        echo -ne "[ ${GREEN}CONFIGURING ${NOCOLOR} ] CORE: proxy network ...\033[0K\r"
        echo "NETWORK=${NET_NAME}" > ./core/proxy/.env
        echo -ne "[ ${LIGHTGREEN}SUCCESS     ${NOCOLOR} ] CORE: proxy network configured"
        echo -ne "[ ${GREEN}STARTING    ${NOCOLOR} ] CORE: proxy container ...\033[0K\r"
        cd core/proxy && docker-compose up -d
        echo -e "[ ${LIGHTGREEN}SUCCESS     ${NOCOLOR} ] CORE: proxy containers started"
        exit;;
esac
