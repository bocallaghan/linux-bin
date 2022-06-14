#!/bin/bash

# Update the underlying ubuntu OS and all packages automatically

# Please note, best installed as a cronjob to run daily
# install this script to the folder /usr/local/bin by following these steps:

# Copy the script to the right folder (assumes your already on the server with a copy of this script)
#   sudo cp os_update.sh /usr/local/bin
# make executable
#   sudo chmod +x /usr/local/bin/auto-os-update.sh
# Open the crontab editor
#   sudo crontab -e
# Add an entry for this script to run every day at 01:05
#   05 01 * * 6 /usr/local/bin/auto-os-update.sh

version=1.0
# Version Log
# 1.0 - Initial version tested on Ubuntu 20.04 LTS

logfile="/var/log/auto-os-update.log"

if [ $EUID -ne "0" ]
then
    echo -e "\tError: This script can only be run as a root user."
    echo -e "\tExiting with error code 1"
    exit 1
fi

# Empty the log file
:> $logfile

echo -e "Ubuntu auto-update script v$version"
printf '%-25s | %-3s | %s\n' "$0" "$version" "Ubuntu auto-update script" &>>$logfile
printf '%-25s | %-3s | %s\n' "$0" "$version" "Author: @callaghan001" &>>$logfile

echo -e "\t Updating the apt-get cache"
printf '%-25s | %-3s | %s\n' "$0" "$version" "Updating the apt-get cache" &>>$logfile
apt-get update &>> $logfile

if [ $? -ne "0" ]
then
    echo -e "\t Updating the cache failed - this utility will now exit"
    exit 2
fi

echo -e "\t Upgrading packages"
printf '%-25s | %-3s | %s\n' "$0" "$version" "Upgrading packages" &>>$logfile
apt-get upgrade -y &>> $logfile

if [ $? -ne "0" ]
then
    echo -e "\t Updating the system packages failed - this utility will now exit"
    exit 3
fi

echo -e "\t Upgrading the distribution"
printf '%-25s | %-3s | %s\n' "$0" "$version" "Upgrading the distribution" &>>$logfile
apt-get dist-upgrade -y &>> $logfile

if [ $? -ne "0" ]
then
    echo -e "\t Updating the system distribution failed - this utility will now exit"
    exit 4
fi

echo -e "\t Cleaning up"
printf '%-25s | %-3s | %s\n' "$0" "$version" "Cleaning up" &>>$logfile
apt-get autoremove -y &>> $logfile
apt-get autoclean -y &>> $logfile

echo -e "Upgrade activites completed"
printf '%-25s | %-3s | %s\n' "$0" "$version" "Upgrade activites completed" &>>$logfile