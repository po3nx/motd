#!/bin/bash

GOLDEN='\033[38;5;220m'
GREEN='\033[32m'
RESET='\033[0m'

SCRIPT_DIR=$(dirname "$0")

colorize_apple_logo() {
  local color=$1
  while IFS= read -r line; do
    printf "${color}%s${RESET}\n" "$line"
  done < "$SCRIPT_DIR/apple.txt"
}

user=$(whoami)
date=$(date)
printf "Welcome, ${user}. It's currently ${date}\n\n"

temp_logo=$(mktemp)
if tput colors > /dev/null 2>&1 && [ $(tput colors) -ge 256 ]; then
  colorize_apple_logo "$GOLDEN" > "$temp_logo"
else
  colorize_apple_logo "$GREEN" > "$temp_logo"
fi

# Display the Apple logo on the left and other information on the right
paste <(cat "$temp_logo") <("$SCRIPT_DIR/sysinfo.sh" --no-color && 
 "$SCRIPT_DIR/services.sh" &&
 "$SCRIPT_DIR/cpu.sh" &&
 "$SCRIPT_DIR/disk.sh" &&
 "$SCRIPT_DIR/flag.sh") | column -t -s '||'

# Clean up the temporary file
rm "$temp_logo"

echo