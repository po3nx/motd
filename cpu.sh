#!/bin/bash
green="\033[1;32m"
red="\033[1;31m"
nc='\033[0m'
white="\033[39m"
dim="\033[2m"
undim="\033[0m"
max_usage=80
usage=`ps -A -o %cpu | awk '{s+=$1} END {print s}'`
pct=`bc -l <<< "${usage}/800"` # 800 because 8 cores on my machine
perc=`bc -l <<< "${pct}*100"` 
if [ "$(printf "%.0f" "$perc")" -ge "${max_usage}" ]; then
    color=$red
else
    color=$green
fi
printf "CPU usage: ${color}"
printf %.2f `echo "${perc}" | bc -l`
echo "%"
bar="=================================================="

count=${#bar}
index=`bc -l <<< "${pct} * ${count}"`
index=`printf "%.0f" "${index}"`
printf "  [${color}${bar:0:$index}${white}${dim}${bar:$index:$count}${undim}]\n"

