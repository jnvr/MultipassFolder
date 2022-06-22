#!/bin/sh

################################################################################################################
#This script is suposed to be run in ...... directory

#TODO ------ VER COMO SE PODE METER O fatalln E infoln A FUNCIONAR (COMO ESTÁ NO SCRIPT DO FABRIC SAMPLES)
#TODO ------ FAZER COM QUE SE POSSA ESCOLHER O NUMERO DE ORGS E PEERS NO SINGLEHOST
#TODO ------ ACHO Q VAI TER Q SE FAZER DESTE SCRIPT UM CRIADOR DOS OBJETOS NECESSÁRIOS PARA A CRIAÇÃO DA REDE E DPS UTILIZAM-SE OS PROCESSOS NORMAIS PARA CRIAR A REDE
################################################################################################################

initConfig() {

    echo "Do you want to use a multi-host configuration?(y/n)"
    read -r hostVar #the flag -r is used to disable backspacing as a means to act like an escape character, aka, backspace can be used to delete characters

    if [ "$hostVar" = "yes" ] || [ "$hostVar" = "y" ]; then

        ####config multi-host####
        multiHostConf

    elif [ "$hostVar" = "no" ] || [ "$hostVar" = "n" ]; then

        ###config one-host###
        singleHostConf

    else

        echo "The answer given is not recognized. Use a variation of y or n in your answer"
        initConfig

    fi
}

multiHostConf() {
    echo "multiHostConf"

    echo "How many machines are going to be used?"
    read -r macNum

    i=0
    while [ "$i" -lt "$macNum" ]; do
        echo "Introduce IP for the machine $i"
        read -r vm"$i"IP
        i=$((i + 1))
    done

    echo "Introduce number of Organizations"
    read -r OrgNUM

}

################################################################################################################
#SingleHost Configuration assumes Multipass is installed and being used as the machine provider
################################################################################################################
singleHostConf() {
    #########DEBUG#########
    multipass delete coiso --purge
    #######################
    #Create Multipass Machine
    echo "A Multipass virtual machine will be created. Introduce its name"
    read -r nameVM
    multipass launch 18.04 --name "$nameVM" -d 7G
    
    #Install Prerequisites
    multipass exec "$nameVM" git clone https://github.com/jnvr/MultipassFolder
    multipass exec "$nameVM" -- chmod --recursive 777 MultipassFolder/jnvr_net/jnvr-network/ # "--" is normally implicit but as flags are needed it must be explicitly defined
    multipass exec "$nameVM" chmod 777 MultipassFolder/initSetup.sh
    multipass exec "$nameVM" -- bash MultipassFolder/initSetup.sh
    # multipass exec "$nameVM" -- echo "cd MultipassFolder/jnvr_net/jnvr-network" >> .bashrc
    multipass exec "$nameVM" -- sed -i '$a cd MultipassFolder/jnvr_net/jnvr-network' .bashrc # https://www.toolbox.com/tech/operating-systems/question/use-sed-to-add-line-to-end-of-file-060909/
    # multipass shell "$nameVM" #DEBUG
    multipass exec "$nameVM" -- bash script-jnvr-network.sh
    multipass exec "$nameVM" -- sed -i '$d' /home/ubuntu/.bashrc
    multipass shell "$nameVM" #DEBUG

    #Initialize Network
    multipass exec "$nameVM" pushd MultipassFolder/jnvr_net/jnvr-network/
    multipass exec "$nameVM" ./script-jnvr-network.sh
    multipass exec "$nameVM" popd
    multipass shell "$nameVM" #DEBUG

}

singleHostEXEC() {

    multipass exec "$mpVM" cp
}

initConfig

echo "Introduce number of Organizations"
read -r OrgNUM

#docker swarm init --advertise-addr $IP1

################# ....................... #################
