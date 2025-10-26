#!/usr/bin/env bash
# shellcheck source=/dev/null
# Simple wrapper to run Ansible
# EXEC: ./bootstrap.sh --tags "vim" -vv --check
set -e

# pretty messages
source lib/printer.func

# duration calculator
START_EPOCH=$(date +%s)
START_HDATE=$(date)
#echo "DEBUG: Writing start time: $START_EPOCH to /tmp/ansible_start_time"
echo "$START_EPOCH" > /tmp/ansible_start_time

#VERIFY=$(cat /tmp/ansible_start_time)
#echo "DEBUG: File immediately contains: $VERIFY"

#CTIME=$(stat --format="%Z"    /tmp/ansible_start_time)
#echo "File ctime: $CTIME"

# Load variables into the environment quietly
source ./my-vars.env >/dev/null 2>&1

print_goal "Starting mac-ops config of ${myHostName%.*} on $START_HDATE..."

cd ansible
ansible-playbook site.yml -i inventory/localhost "$@"
