#!/bin/bash

########################################
# This script starts Jenkins based on the paramaters passed from a 
#Makefile command
#Example command ./jenkins_startup_script.sh full
########################################

#What function to run
the_function=$1

#Declare logging functionality
date="$(date +'%d-%m-%Y__%H-%M-%S-%3N')"
current_path=$(pwd)
LOG_PATH="${current_path}/logging"

touch "${LOG_PATH}/${date}_jenkins_startup.log"
chmod 777 "${LOG_PATH}/${date}_jenkins_startup.log"
LOG_FILE="${LOG_PATH}/${date}_jenkins_startup.log"

echo "Current Log path: ${LOG_FILE}" | tee -a $LOG_FILE

#Determine which OS is running,(used for mounts later)
mount_location=""
the_OS=$OSTYPE
case "$the_OS" in 
    *msys*)
        echo "We should be using windows: ${the_OS}" | tee -a $LOG_FILE

        mount_location="${current_path}\jenkins_mount_location_windows"
        ;;
    *linux*)
        echo "We should be using linux: ${the_OS}" | tee -a $LOG_FILE
        
        mount_location="${current_path}\jenkins_mount_location_linux"
        ;;
    *)
        echo "Undefined os type, we'll use linux: ${the_OS}" | tee -a $LOG_FILE
        
        mount_location="${current_path}\jenkins_mount_location_linux"
        ;;
esac


#Run the jenkins start function based on what is passed
case $the_function in
    "full")
        #Run the full build for Jenkins 

        #Kill any running docker containers
        docker container kill jenkins | tee -a $LOG_FILE
        if [$? -eq 0]
        then 
            echo "Docker container for jenkins killed for restart" | tee -a $LOG_FILE
        else 
            echo "Docker container for jenkins might not have been running" | tee -a $LOG_FILE
        fi

        #Build the jenkins container
        docker build -t jenkins_proj . | tee -a $LOG_FILE
        if [$? -eq 0]
        then 
            echo "Docker container for jenkins rebuilt" | tee -a $LOG_FILE
        else 
            echo "Docker container for jenkins had an issue building..." | tee -a $LOG_FILE
        fi

        #Tag and push the jenkins container
        docker tag jenkins_proj americanwonton/jenkins_proj && docker push americanwonton/jenkins_proj

        #Pull any relevant docker info pushed
        docker pull americanwonton/jenkins_proj:latest

        #Run the jenkins container from the background

    ;;
    "oof")

    ;;
    "")
        #No command passed, error out
    ;;
    *)
        #Unrecognized command passed, error out
    ;;
esac
