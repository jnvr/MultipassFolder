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