#!/bin/bash

# set column width
COLUMNS=3
# colors
green="\e[1;32m"
red="\e[1;31m"
undim="\e[0m"

services=("nginx" "php" "redis" "mariadb" "mongodb" "Terminal")
# sort services
IFS=$'\n' services=($(sort <<<"${services[*]}"))
unset IFS

service_status=()
# get status of all services
for service in "${services[@]}"; do
    if launchctl list | grep -q "${service}"; then
        service_status+=("active")
    else
        service_status+=("inactive")
    fi
done

out=""
for i in ${!services[@]}; do
    # color green if service is active, else red
    if [[ "${service_status[$i]}" == "active" ]]; then
        out+="${services[$i]}:,${green}${service_status[$i]}${undim},"
    else
        out+="${services[$i]}:,${red}${service_status[$i]}${undim},"
    fi
    # insert \n every $COLUMNS column
    if [ $((($i+1) % $COLUMNS)) -eq 0 ]; then
        out+="\n"
    fi
done
out+="\n"

printf "\nServices:\n"
printf "$out" | column -ts $',' | sed -e 's/^/  /'