#!/bin/bash

echo " =========================================================================== "
echo "---Update and Upgrade---"
sudo apt update -y && sudo apt upgrade -y
echo " =========================================================================== "
echo "---Install Git---"
sudo apt-get install git
echo " =========================================================================== "
echo " =========================================================================== " >>versions.txt
echo "---Install Curl---"
sudo apt install curl
curl --version >versions.txt
echo " =========================================================================== " >>versions.txt
echo " =========================================================================== "
echo "---Installing Docker---"
sudo apt-get remove docker docker-engine docker.io
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
USER_NAME=$(whoami)
sudo usermod -a -G docker $USER_NAME
docker --version >>versions.txt
echo " =========================================================================== " >>versions.txt
echo " =========================================================================== "
echo "---Installing Docker-Compose---"
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo docker-compose --version >>versions.txt
echo " =========================================================================== " >>versions.txt
echo " =========================================================================== "
echo "---Install Fabric-Samples---"
sudo curl -sSL https://bit.ly/2ysbOFE | sudo bash -s
export PATH=./fabric-samples/bin:$PATH
echo " =========================================================================== "
echo "---Install NodeJS---"
wget http://nodejs.org/dist/v16.14.0/node-v16.14.0-linux-x64.tar.gz
sudo tar -C /usr/local --strip-components 1 -xzf node-v16.14.0-linux-x64.tar.gz
npm --version >>versions.txt
echo " =========================================================================== "
echo " =========================================================================== " >>versions.txt
echo "---Install Go---"
wget https://go.dev/dl/go1.18.1.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.18.1.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version >>versions.txt

rm node-v16.14.0-linux-x64.tar.gz
rm go1.18.1.linux-amd64.tar.gz

sudo cp -R ./sharedFolder/4host-swarm-clis/ ./fabric-samples/
cd ./fabric-samples || exit
sudo chmod -R 755 4host-swarm-clis/
