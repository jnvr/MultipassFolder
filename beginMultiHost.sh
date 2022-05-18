#!/bin/sh

################################################################################################################
#This script is suposed to be run in ...... directory

#TODO ------ VER COMO SE PODE METER O fatalln E infoln A FUNCIONAR (COMO ESTÁ NO SCRIPT DO FABRIC SAMPLES) 
################################################################################################################

initConfig (){

    echo "Do you want to use a multi-host configuration?(y/n)"
    read -r hostVar #the flag -r is used to disable backspacing as a means to act like an escape character, aka, backspace can be used to delete characters

    if [ "$hostVar" = "yes" ] || [ "$hostVar" = "y" ];then

        ####config multi-host####
        multiHostConf

    elif [ "$hostVar" = "no" ] || [ "$hostVar" = "n" ];then

        ###config one-host###
        singleHostConf

    else
        
        echo "The answer given is not recognized. Use a variation of y or n in your answer"
        initConfig

    fi
}

multiHostConf(){
    echo "multiHostConf"

    echo "How many machines are going to be used?"
    read -r macNum

    i=0
    while [ "$i" -lt "$macNum" ]; do
        echo "Introduce IP for the machine $i"
        read -r vm"$i"IP
        i=$((i+1))
    done

    echo "Introduce number of Organizations"
    read -r OrgNUM


}

################################################################################################################
#SingleHost Configuration assumes Multipass is installed and being used as the machine provider
#This configuration also assumes that there is a folder  
################################################################################################################
singleHostConf(){
    #This is assuming that MULTIPASS MACHINES WILL BE USED
    # echo "Do you want to create a Multipass VM?(y/n)"
    # read -r mpCreate

    echo "A Multipass virtual machine will be created, introduce its name"
    read -r mpVM
    multipass launch --name "$mpVM" -d 7G

    singleHostEXEC

}

singleHostEXEC(){

    multipass exec "$mpVM" cp  
}


initConfig

echo "Introduce number of Organizations"
read -r OrgNUM






#docker swarm init --advertise-addr $IP1 


################# ....................... #################