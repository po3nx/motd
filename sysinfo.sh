#!/bin/bash
# colors
green="\e[1;32m"
red="\e[1;31m"
yellow="\e[1;33m"
blue="\e[1;36m"
undim="\e[0m"

# get load averages
IFS=" " read LOAD1 LOAD5 LOAD15 <<<$(sysctl -n vm.loadavg | awk '{ print $2,$3,$4 }' | sed 's/\.[0-9]*//g')
# get free memory
IFS=" " read USED AVAIL TOTAL <<<$(top -l 1 -s 0 | awk '/PhysMem/ {print $8,$10,$6}' | sed 's/M//g')
TOTAL=$((USED+AVAIL))

mem=$(top -l 1 -s 0 | grep PhysMem | awk -F ': ' '{print $2}') 
#ttl_mem=$(hostinfo | awk '/available:/ {print $4" "$5}')
ttl_mem=$(hostinfo | awk '/available:/ {print $4}')
# get processes
PROCESS=`ps -eo user=|sort|uniq -c | awk '{ print $2 " " $1 }'`
PROCESS_ALL=`echo "$PROCESS"| awk '{sum += $2} END {print sum}'`
PROCESS_ROOT=`echo "$PROCESS"| grep root | awk {'print $2'}`
PROCESS_USER=`echo "$PROCESS"| grep -v root | awk {'print $2'} | awk '{ SUM += $1} END { print SUM }'`
# get processors
PROCESSOR_NAME=`sysctl -n machdep.cpu.brand_string`
PROCESSOR_COUNT=`sysctl -n hw.ncpu`

# get uptime
boot=$(sysctl -n kern.boottime)
boot=${boot/\{ sec = }
boot=${boot/,*}
# Get current date in seconds.
now=$(date +%s)
s=$((now - boot))

#UPTIME_SECONDS=$(sysctl -n kern.boottime | awk -F'[=,]' '{print $2}')
UPTIME_MINUTES=$((s/ 60))
UPTIME_HOURS=$((UPTIME_MINUTES / 60))
UPTIME_DAYS=$((UPTIME_HOURS / 24))
UPTIME="${green}${UPTIME_DAYS} ${yellow}days ${green}$((${UPTIME_HOURS} - ${UPTIME_DAYS}*24)) ${yellow}hours ${green}$((${UPTIME_MINUTES} - ${UPTIME_HOURS}*60)) ${yellow}minutes${undim}"

#get GPU
gpu="$(system_profiler SPDisplaysDataType |\
        awk -F': ' '/^\ *Chipset Model:/ {printf $2 ", "}')"
gpu="${gpu//\/ \$}"
gpu="${gpu%,*}"

# get computer name
COMP_NAME=$(scutil --get ComputerName)

# get battery status
BATT_STATUS=$(pmset -g batt | awk 'NR==2 {print $3}' | sed 's/;//')
#${blue}Memory...........:${green} $USED ${yellow}used,${green} $AVAIL ${yellow}avail,${green} $TOTAL ${yellow}total${undim}

printf "
System Info:
  ${blue}OS...............:${green} `sed -nE '/SOFTWARE LICENSE AGREEMENT FOR/s/([A-Za-z]+ ){5}|\\$//gp' /System/Library/CoreServices/Setup\ Assistant.app/Contents/Resources/en.lproj/OSXSoftwareLicense.rtf | sed 's/\\\f0\\\\//g' | sed 's/\\\//g'` `sw_vers -productVersion` ${undim}
  ${blue}Model............:${green} `sysctl -n hw.model` ${undim}
  ${blue}Computer Name....:${green} ${COMP_NAME} ${undim}
  ${blue}Kernel...........:${green} `uname -sr` ${undim}
  ${blue}Uptime...........:${green} $UPTIME ${undim}
  ${blue}Load.............:${green} $LOAD1 ${yellow}(1m),${green} $LOAD5 ${yellow}(5m),${green} $LOAD15 ${yellow}(15m)${undim}
  ${blue}Processes........:${green} $PROCESS_ROOT ${yellow}(root),${green} $PROCESS_USER ${yellow}(user),${green} $PROCESS_ALL ${yellow}(total)${undim}
  ${blue}CPU..............:${green} $PROCESSOR_NAME ${yellow}($PROCESSOR_COUNT Cores)${undim} 
  ${blue}GPU..............:${green} $gpu ${undim}
  ${blue}Memory Status....:${green} $mem 
  ${blue}Total Memory.....:${green} $ttl_mem ${yellow}GB ${undim} 
  ${blue}Disk ............:${green} $(df -PH -t apfs | grep '/System/Volumes/Data' | awk '{printf "%c[1;32m"$3"%c[1;33m used / %c[1;32m"$2" %c[1;33m total",27,27,27,27}' ) ${undim}
  ${blue}Battery Status...:${green} %s ${undim}"  "$BATT_STATUS"
