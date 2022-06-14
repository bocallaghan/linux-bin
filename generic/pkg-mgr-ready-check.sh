#!/bin/bash

version=1.0
# Version Log
# 1.0 - Initial version tested on Ubuntu 20.04 LTS


if [ $EUID -ne "0" ]
then
    echo -e "\tError: This script can only be run as a root user."
    echo -e "\tExiting with error code 1"
    exit 1
else
    echo -e "Checking if the package manager is ready for use"
fi

# Get the current OS distribution.
os_type=$(cat /etc/os-release | grep -Po '(?:^ID=)(.+)' | sed "s/\"//g" | sed "s/ID=//")

# Function: package_manager_name
#           Returns the correct package manager to use based on the distribution.
package_manager_name(){
    
    if [ $os_type = "sles" ]
    then
        echo "zypper"
    elif [ $os_type = "rhel" ] || [ $os_type = "amzn" ]
    then
        echo "yum"
    else
        echo "apt-get"
    fi
}

package_manager=$(package_manager_name)

# Function: package_manager_is_ready
#           Detect if package manager is ready for use
#           Returns 1 if ready and 0 if not
package_manager_is_ready() {
    
    timeout=0
    # If we detect no running package manager processes we proceed
    # otherwise we wait 30 seconds
    # this 30 second wait will repeat a maximum of 6 times
    until [[ $(ps -aux | grep -c $package_manager) -eq 1 || $timeout -gt 4 ]]
    do
        ((timeout++))
        sleep 30
    done

    # if we've hit 5 on the timeout counter then package manager is not ready
    if [ $timeout -gt 4 ]
    then
        echo 0
    else
        echo 1
    fi
}

timeout=0
# If we detect no running package manager processes we proceed
# otherwise we wait 30 seconds
# this 30 second wait will repeat a maximum of 6 times
until [[ $(ps -aux | grep -c $package_manager) -eq 1 || $timeout -gt 4 ]]
do
    ((timeout++))
    sleep 30
done

# if we've hit 5 on the timeout counter then package manager is not ready
if [ $timeout -gt 4 ]
then
    echo -e "\tAfter 5 checks, there is still a $package_manager process running - cannot continue - please try again later."
    exit 2
else
    echo -e "\t$package_manager is ready."
    exit 0
fi