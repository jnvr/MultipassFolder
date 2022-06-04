#!/bin/sh

#This scripts assumes it is being run in the jnvr_network directory.
#There also is the assumption that the structure of the example is being followed.

####################################!!!!!ATENTION!!!!!####################################
#This script eliminates ALL DOCKER CONTAINERS AND VOLUMES IN YOUR MACHINE, meaning if 
#there is a network already running, THAT NETWORK'S CONTAINERS AND VOLUMES will be DELETED
##########################################################################################   
export PATH=./fabric-samples/bin:$PATH
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


#Generate Cryptographic Material:
   cryptogen generate --config=./crypto-config.yaml

#Create Genesis Block 
   configtxgen -profile FourOrgsOrdererGenesis -channelID system-channel -outputBlock ./channel-artifacts/genesis.block
   configtxgen -profile FourOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID channel1
   configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate  ./channel-artifacts/Org1MSPanchors.tx -channelID channel1 -asOrg Org1MSP
   configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate  ./channel-artifacts/Org2MSPanchors.tx -channelID channel1 -asOrg Org2MSP
   configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate  ./channel-artifacts/Org3MSPanchors.tx -channelID channel1 -asOrg Org3MSP
   configtxgen -profile FourOrgsChannel -outputAnchorPeersUpdate  ./channel-artifacts/Org4MSPanchors.tx -channelID channel1 -asOrg Org4MSP

#Start Docker containers
   export CHANNEL_NAME=channel1
   export VERBOSE=false
   export FABRIC_CFG_PATH=$PWD
   CHANNEL_NAME=$CHANNEL_NAME docker-compose -f docker-compose-cli-couchdb.yaml up -d

#Copy Docker Script into container cli
   docker cp ./script-jnvr-network-docker.sh cli:/opt/gopath/src/github.com/hyperledger/fabric/peer

#Initiate cli shell
   docker exec -it cli /bin/sh

# #Run script in cli container
#    docker exec --user root cli /opt/gopath/src/github.com/hyperledger/fabric/peer/script_jnvr_network_docker.sh     

