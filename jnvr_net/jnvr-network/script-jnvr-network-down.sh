#!/bin/sh

#This scripts assumes it is being run in the jnvr_network directory.
#There also is the assumption that the structure of the example is being followed.

####################################!!!!!ATENTION!!!!!####################################
#This script eliminates ALL DOCKER CONTAINERS AND VOLUMES IN YOUR MACHINE, meaning if 
#there is a network already running, THAT NETWORK'S CONTAINERS AND VOLUMES will be DELETED
##########################################################################################   

rm -r ./channel-artifacts
mkdir ./channel-artifacts
sudo rm -r ./crypto-config
mkdir ./crypto-config
docker rm -f $(docker ps -aq)
docker volume rm -f $(docker volume ls -q)
NETWORK_NAME=$(grep 'CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE' /home/osboxes/Desktop/jnvr_net/jnvr-network/base/peer-base.yaml)
#IFS variable is changed in order to modify how Bash recognizes word boundaries while splitting a sequence of character strings, normaly it is set to ' ' as I've defined it is set to '='
old_IFS=$IFS
IFS==
#Heredoc is being used here to pass the value of NETWORK_NAME as an input to the read comand, EOF here functions as a delimiter token
read -r thing NETWORK_NAME <<EOF 
$NETWORK_NAME 
EOF
IFS=$old_IFS
docker network rm $NETWORK_NAME
