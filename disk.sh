#!/bin/bash

# config
max_usage=90
bar_width=50
# colors
white="\033[39m"
green="\033[1;32m"
red="\033[1;31m"
dim="\033[2m"
undim="\033[0m"

# disk usage: only for /dev/disk3s3s1
while read -r line; do
    # skip the header line
    if [[ "$line" == *"Filesystem"* ]]; then
        continue
    fi
    # exclude file systems other than /dev/disk3s3s1
    if [[ "$line" != *"/dev/disk3s1"* ]]; then
        continue
    fi
    # get disk usage
    usage=$(echo "$line" | awk '{print $5}' | sed 's/%//')
    used_width=$((($usage*$bar_width)/100))
    # color is green if usage < max_usage, else red
    if [ "${usage}" -ge "${max_usage}" ]; then
        color=$red
    else
        color=$green
    fi
    # print green/red bar until used_width
    bar="[${color}"
    for ((i=0; i<$used_width; i++)); do
        bar+="="
    done
    # print dimmmed bar until end
    bar+="${white}${dim}"
    for ((i=$used_width; i<$bar_width; i++)); do
        bar+="="
    done
    bar+="${undim}]"
    # print usage line & bar
    echo -e "${undim}Disk Usage:${color} ${usage} % ${undim}"
    echo -e "${bar}" | sed -e 's/^/  /'
done < <(df -H -P)