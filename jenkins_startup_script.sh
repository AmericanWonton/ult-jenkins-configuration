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
creds_listing="creds_listing"
#Need to change this based on a windows OS or a linux OS
docker_socket=""

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
        docker_socket="//var/run/docker.sock:/var/run/docker.sock"
        ;;
    *linux*)
        echo "We should be using linux: ${the_OS}" | tee -a $LOG_FILE
        
        mount_location="${current_path}\jenkins_mount_location_linux"
        docker_socket="/var/run/docker.sock:/var/run/docker.sock"
        ;;
    *)
        echo "Undefined os type, we'll use linux: ${the_OS}" | tee -a $LOG_FILE
        
        mount_location="${current_path}\jenkins_mount_location_linux"
        docker_socket="/var/run/docker.sock:/var/run/docker.sock"
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
        Result=`docker run --env-file $current_path/$creds_listing/env-creds.list \
        --name jenkins_proj \
        -u root \
        --group-add 0 \
        -v jenkins_volume1:/var/jenkins_home \
        -v ${docker_socket} \
        --name jenkins \
        --rm -d -p 5000:7070 americanwonton/jenkins_proj`
        
        if [ $? -ne 0 ];then
            echo "There was an issue with starting the docker container" | tee -a $LOG_FILE
            echo "${Result}" | tee -a $LOG_FILE
            exit 1
        else 
            echo "Docker container started on http://localhost:7070" | tee -a $LOG_FILE
            echo "${Result}" | tee -a $LOG_FILE
        fi
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
