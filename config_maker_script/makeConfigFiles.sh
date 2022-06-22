#!/bin/sh

    printf "\v $(tput setaf 7)$(tput setab 4)$(tput bold) All configurations will run a peer in each machine $(tput sgr 0)\n\n"
    echo "Introduce number of Organizations"
    read -r OrgNUM

    echo "Introduce number of Peers per Organization"
    read -r PeerNUM

    yq -i ".PeerOrgs[0].Template.Count = $PeerNUM" crypto-config.yaml # Edit peer number of Org1
    
    
    # for((iter=1;iter<n;iter++)); do
    #     item=$(cat createOrg.yaml) yq -ei '.PeerOrgs += env(item)' crypto-config.yaml # Add new Org structure to cryptoconfig.yaml "https://stackoverflow.com/questions/68321476/insert-multiple-lines-of-one-attribute-in-yaml-file-with-yq-v4-x"
    #     yq -i ".PeerOrgs[$iter].Template.Count = $PeerNUM" crypto-config.yaml
    # done
    
    iter=2
    while [ "$iter" -le "$OrgNUM" ]
    do 
        item=$(cat createOrg.yaml) yq -ei '.PeerOrgs += env(item)' crypto-config.yaml # Add new Org structure to cryptoconfig.yaml "https://stackoverflow.com/questions/68321476/insert-multiple-lines-of-one-attribute-in-yaml-file-with-yq-v4-x"
        yq -i ".PeerOrgs[$iter].Template.Count = $PeerNUM" crypto-config.yaml # Edit peer number of Org# 
        yq -i ".PeerOrgs[$iter].Name = Org$iter" crypto-config.yaml
        iter=$((iter+1))
    done