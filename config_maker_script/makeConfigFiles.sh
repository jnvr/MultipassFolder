#!/bin/sh
    
    #TODO                                                                                                             
    #TODO ----- NAO ESQUECER DE ELIMINAR O FICHEIRO tempCodeRunnerFile.sh ANTES DE METER ISTO NO RELATORIO E NO GITHUB
    #TODO                                                                                                             

    printf "\v $(tput setaf 7)$(tput setab 4)$(tput bold) All configurations are meant to be multi-host and will run a peer in each machine $(tput sgr 0)\n\n"
    echo "Introduce number of Organizations"
    read -r OrgNUM
    echo "Introduce number of Peers per Organization"
    read -r PeerNUM

    lastPeerjter=$((PeerNUM-1))

    ##########################################################################################################
    ##################################### Configuration of configtx.yaml #####################################
    ##########################################################################################################
    
    cat configtx1.yaml > configtx.yaml # Reset modifications in configtx.yaml

    iter=1
    ordererPort=7050
    orgPort=7051
    ordererNumber=2
    while [ "$iter" -le "$OrgNUM" ];do
        printf "\n$(tput setaf 5)$(tput bold)Adding Org$iter to Organizations in configtx.yaml $(tput sgr 0)"
        item=$(cat OrgStructureConftx.yaml) yq -ei '.Organizations += env(item)' configtx.yaml # Add new Org structure to configtx.yaml
        sed  -i 's/!!merge //g' configtx.yaml # To remove an unexpected result of the previous command
        
        # Change values of the new Organization structure
        sed -i s/"OrgTitle"/"Org$iter"/ configtx.yaml
        sed -i s/"OrgName"/"Org$iter\MSP"/ configtx.yaml
        sed -i s/"MSPDirVar"/"crypto-config\/peerOrganizations\/org$iter\.example.com\/msp"/ configtx.yaml
        sed -i s/"readRule"/"\"OR('Org$iter\MSP.admin', 'Org$iter\MSP.peer', 'Org$iter\MSP.client')\""/ configtx.yaml
        sed -i s/"writeRule"/"\"OR('Org$iter\MSP.admin', 'Org$iter\MSP.client')\""/ configtx.yaml
        sed -i s/"adminRule"/"\"OR('Org$iter\MSP.admin')\""/ configtx.yaml
        sed -i s/"endorseRule"/"\"OR('Org$iter\MSP.peer')\""/ configtx.yaml
        sed -i s/"anchorPeer"/"peer0.org$iter\.example.com"/ configtx.yaml
        sed -i s/"portNum"/"$orgPort"/ configtx.yaml
        

        # Add new Org to TwoOrgsChannel profile
        printf "\n$(tput setaf 5)$(tput bold)Adding Org$iter to TwoOrgsChannel profile in configtx.yaml $(tput sgr 0)"
        m="*Org$iter" yq -i '.Profiles.TwoOrgsChannel.Application.Organizations += strenv(m)' configtx.yaml
        sed -i s/"'\*Org$iter'"/"*Org$iter"/ configtx.yaml # Remove quotes created from the previous command
        sed -i '/- Textsample/d' configtx.yaml 

        jter=0
        while [ "$jter" -lt "$PeerNUM" ]; do
            if [ "$iter" -eq 1 ] && [ "$jter" -eq 0 ]; then
                printf "\n$(tput setaf 5)$(tput bold)Adding new orderer for Peer0.Org0 to SampleMultiNodeEtcdRaft.EtcdRaft profile in configtx.yaml $(tput sgr 0)"        
                item=$(cat OrdererStructureConftx.yaml) yq -ei '.Profiles.SampleMultiNodeEtcdRaft.Orderer.EtcdRaft.Consenters += env(item)' configtx.yaml # Add new Orderer structure to configtx.yaml
                sed -i s/"hostOrderer"/"orderer.example.com"/ configtx.yaml
                sed -i s/"ordPort"/"$ordererPort"/ configtx.yaml
                sed -i s/"tlsOrderer"/"crypto-config\/ordererOrganizations\/example.com\/orderers\/orderer.example.com\/tls\/server.crt"/ configtx.yaml
                sed -i '/- insertText/d' configtx.yaml

                # Add an orderer to a peer in SampleMultiNodeEtcdRaft.Orderer profile
                printf "\n$(tput setaf 5)$(tput bold)Adding new orderer for Peer0.Org0 to SampleMultiNodeEtcdRaft.Orderer profile in configtx.yaml $(tput sgr 0)"                
                m="orderer.example.com:$ordererPort" yq -i '.Profiles.SampleMultiNodeEtcdRaft.Orderer.Addresses += strenv(m)' configtx.yaml
                sed -i '/- Textinsert/d' configtx.yaml
                ordererPort=$((ordererPort+1000))
            
            elif [ "$iter" -eq "$OrgNUM" ] && [ "$jter" -eq "$lastPeerjter" ]; then
                
                # Add an orderer to a peer in SampleMultiNodeEtcdRaft.EtcdRaft profile
                printf "\n$(tput setaf 5)$(tput bold)Adding new orderer for Peer$jter.Org$iter to SampleMultiNodeEtcdRaft.EtcdRaft profile in configtx.yaml $(tput sgr 0)"        
                item=$(cat OrdererStructureConftx.yaml) yq -ei '.Profiles.SampleMultiNodeEtcdRaft.Orderer.EtcdRaft.Consenters += env(item)' configtx.yaml # Add new Orderer structure to configtx.yaml        
                sed -i s/"hostOrderer"/"orderer$ordererNumber.example.com"/ configtx.yaml
                sed -i s/"ordPort"/"$ordererPort"/ configtx.yaml
                sed -i s/"tlsOrderer"/"crypto-config\/ordererOrganizations\/example.com\/orderers\/orderer$ordererNumber.example.com\/tls\/server.crt"/ configtx.yaml

                # Add an orderer to a peer in SampleMultiNodeEtcdRaft.Orderer profile
                printf "\n$(tput setaf 5)$(tput bold)Adding new orderer for Peer$jter.Org$iter to SampleMultiNodeEtcdRaft.Orderer profile in configtx.yaml $(tput sgr 0)"                
                m="orderer$ordererNumber.example.com:$ordererPort" yq -i '.Profiles.SampleMultiNodeEtcdRaft.Orderer.Addresses += strenv(m)' configtx.yaml
                ordererNumber=$((ordererNumber+1))
                ordererPort=$((ordererPort+1000))

                # Add an orderer for cli to SampleMultiNodeEtcdRaft.EtcdRaft profile
                printf "\n$(tput setaf 5)$(tput bold)Adding new orderer for cli to SampleMultiNodeEtcdRaft.EtcdRaft profile in configtx.yaml $(tput sgr 0)"        
                item=$(cat OrdererStructureConftx.yaml) yq -ei '.Profiles.SampleMultiNodeEtcdRaft.Orderer.EtcdRaft.Consenters += env(item)' configtx.yaml # Add new Orderer structure to configtx.yaml        
                sed -i s/"hostOrderer"/"orderer$ordererNumber\.example.com"/ configtx.yaml
                sed -i s/"ordPort"/"$ordererPort"/ configtx.yaml
                sed -i s/"tlsOrderer"/"crypto-config\/ordererOrganizations\/example.com\/orderers\/orderer$ordererNumber.example.com\/tls\/server.crt"/ configtx.yaml

                # Add an orderer for cli to SampleMultiNodeEtcdRaft.Orderer profile
                printf "\n$(tput setaf 5)$(tput bold)Adding new orderer for cli to SampleMultiNodeEtcdRaft.Orderer profile in configtx.yaml $(tput sgr 0)"                
                m="orderer$ordererNumber.example.com:$ordererPort" yq -i '.Profiles.SampleMultiNodeEtcdRaft.Orderer.Addresses += strenv(m)' configtx.yaml
                ordererNumber=$((ordererNumber+1))
                ordererPort=$((ordererPort+1000))
            
            else
                # Add an orderer to a peer in SampleMultiNodeEtcdRaft.EtcdRaft profile
                printf "\n$(tput setaf 5)$(tput bold)Adding new orderer for Peer$jter.Org$iter to SampleMultiNodeEtcdRaft.EtcdRaft profile in configtx.yaml $(tput sgr 0)"        
                item=$(cat OrdererStructureConftx.yaml) yq -ei '.Profiles.SampleMultiNodeEtcdRaft.Orderer.EtcdRaft.Consenters += env(item)' configtx.yaml # Add new Orderer structure to configtx.yaml        
                sed -i s/"hostOrderer"/"orderer$ordererNumber\.example.com"/ configtx.yaml
                sed -i s/"ordPort"/"$ordererPort"/ configtx.yaml
                sed -i s/"tlsOrderer"/"crypto-config\/ordererOrganizations\/example.com\/orderers\/orderer$ordererNumber.example.com\/tls\/server.crt"/ configtx.yaml

                # Add an orderer to a peer in SampleMultiNodeEtcdRaft.Orderer profile
                printf "\n$(tput setaf 5)$(tput bold)Adding new orderer for Peer$jter.Org$iter to SampleMultiNodeEtcdRaft.Orderer profile in configtx.yaml $(tput sgr 0)"                
                m="orderer$ordererNumber.example.com:$ordererPort" yq -i '.Profiles.SampleMultiNodeEtcdRaft.Orderer.Addresses += strenv(m)' configtx.yaml
                ordererNumber=$((ordererNumber+1))
                ordererPort=$((ordererPort+1000))
            fi
            jter=$((jter+1))
        done            

        # Add new Org to SampleMultiNodeEtcdRaft profile
        m="*Org$iter" yq -i '.Profiles.SampleMultiNodeEtcdRaft.Consortiums.SampleConsortium.Organizations += strenv(m)' configtx.yaml
        sed -i s/"'\*Org$iter'"/"*Org$iter"/ configtx.yaml # Remove quotes created from the previous command
        sed -i '/- sampleText/d' configtx.yaml        

        orgPort=$((orgPort+PeerNUM*1000))
        iter=$((iter+1))
    done
    sed  -i 's/!!merge //g' configtx.yaml # To remove unexpected results from the previous while loop


    ##############################################################################################################
    ##################################### Configuration of crypto-config.yaml ####################################
    ##############################################################################################################
    
    cat crypto-config1.yaml > crypto-config.yaml # Reset modifications in crypto-config.yaml

    lastPortOrderer=$((ordererPort-1000))
    ordererNumber=$((ordererNumber-1))
    iter=2
    while [ "$iter" -le "$ordererNumber" ]; do
        printf "\n$(tput setaf 6)$(tput bold)Adding orderer$iter to crypto-config.yaml $(tput sgr 0)"
        m="Hostname: orderer$iter" yq -i '.OrdererOrgs[0].Specs += strenv(m)' crypto-config.yaml
        sed -i s/"'\Hostname: orderer$iter'"/"Hostname: orderer$iter"/ crypto-config.yaml # Remove quotes created from the previous command
        iter=$((iter+1))    
    done

    printf "\n$(tput setaf 6)$(tput bold)Adding Org1 to crypto-config.yaml $(tput sgr 0)"
    yq -i ".PeerOrgs[0].Template.Count = $PeerNUM" crypto-config.yaml # Edit peer number of Org1
    yq -i ".PeerOrgs[0].Users.Count = $lastPeerjter" crypto-config.yaml # Edit user number of Org1
    
    iter=1
    while [ "$iter" -lt "$OrgNUM" ];do
        i=$((iter+1))
        printf "\n$(tput setaf 6)$(tput bold)Adding Org$i to crypto-config.yaml $(tput sgr 0)"
        item=$(cat createOrgCryCon.yaml) yq -ei '.PeerOrgs += env(item)' crypto-config.yaml # Add new Org structure to crypto-config.yaml "https://stackoverflow.com/questions/68321476/insert-multiple-lines-of-one-attribute-in-yaml-file-with-yq-v4-x"
        yq -ei ".PeerOrgs[${iter}].Template.Count = ${PeerNUM}" crypto-config.yaml # Edit peer number of Org<#>
        yq -ei ".PeerOrgs[${iter}].Users.Count = ${lastPeerjter}" crypto-config.yaml # Edit user number of Org<#>
        
        # First try where there were problems passing strings: "Error: parsing expression: Lexer error: could not match text"
        # yq -i ".PeerOrgs[${iter}].Domain = ""org$i.example.com""" crypto-config.yaml # 
        # yq -ei ".PeerOrgs[${iter}].Name |= Org$i" crypto-config.yaml

        sed -i s/"nameInput"/"Org$i"/ crypto-config.yaml # Changing organization Name
        sed -i s/"domainInput"/"org$i.example.com"/ crypto-config.yaml # Changing organization Domain
        iter=$((iter+1))
    done
    
    
    ##########################################################################################################
    ############################# Configuration of base/docker-compose-base.yaml #############################
    ##########################################################################################################
    
    sed -i '22,$d' docker-compose-base.yaml # Reset docker-compose-base.yaml file to its original form     
        
    iter=1
    peerPort=7051
    while [ "$iter" -le "$OrgNUM" ]; do
        # Add peer0 to each Org, this is done because peer0 configuration is different when compared to other peers, due to peer0 being the Bootstrap peer in the Organization
        printf "\n$(tput setaf 3)$(tput bold)Adding peer0.Org$iter to docker-compose-base.yaml $(tput sgr 0)"        
        item=$(cat peerStructureDocker.yaml) yq -ei '.services += env(item)' docker-compose-base.yaml
        sed -i s/"peerName"/"peer0"/ docker-compose-base.yaml
        sed -i s/"orgName"/"org$iter.example.com"/ docker-compose-base.yaml
        sed -i s/"peerPort"/"$peerPort"/g docker-compose-base.yaml #In this command it is necessary to use 'g' modifier due to sed only replacing the first instance in a line by default
        sed -i s/"peerchainPort"/"$((peerPort+1))"/ docker-compose-base.yaml
        sed -i s/"peerBoot"/"peer1"/ docker-compose-base.yaml
        sed -i s/"orgBoot"/"org$iter.example.com"/ docker-compose-base.yaml
        peer1Port=$((peerPort+1000))
        sed -i s/"portBoot"/"$peer1Port"/ docker-compose-base.yaml
        sed -i s/"orgMSP"/"Org$iter\MSP"/ docker-compose-base.yaml
        sed -i s/"mspVolume"/"..\/crypto-config\/peerOrganizations\/org$iter.example.com\/peers\/peer0.org$iter.example.com\/msp:\/etc\/hyperledger\/fabric\/msp"/ docker-compose-base.yaml
        sed -i s/"tlsVolume"/"..\/crypto-config\/peerOrganizations\/org$iter.example.com\/peers\/peer0.org$iter.example.com\/tls:\/etc\/hyperledger\/fabric\/tls"/ docker-compose-base.yaml

        # Add the rest of the peers in the Organization
        peer0Port=$peerPort
        peerPort=$((peerPort+1000))
        jter=1
        while [ "$jter" -lt "$PeerNUM" ]; do
            printf "\n$(tput setaf 3)$(tput bold)Adding peer$jter.Org$iter to docker-compose-base.yaml $(tput sgr 0)"
            item=$(cat peerStructureDocker.yaml) yq -ei '.services += env(item)' docker-compose-base.yaml
            sed -i s/"peerName"/"peer$jter"/ docker-compose-base.yaml
            sed -i s/"orgName"/"org$iter.example.com"/ docker-compose-base.yaml
            sed -i s/"peerPort"/"$peerPort"/g docker-compose-base.yaml #In this command it is necessary to use 'g' modifier due to sed only replacing the first instance in a line by default
            sed -i s/"peerchainPort"/"$((peerPort+1))"/ docker-compose-base.yaml
            sed -i s/"peerBoot"/"peer0"/ docker-compose-base.yaml
            sed -i s/"orgBoot"/"org$iter.example.com"/ docker-compose-base.yaml
            sed -i s/"portBoot"/"$peer0Port"/ docker-compose-base.yaml
            sed -i s/"orgMSP"/"Org$iter\MSP"/ docker-compose-base.yaml
            sed -i s/"mspVolume"/"..\/crypto-config\/peerOrganizations\/org$iter.example.com\/peers\/peer$jter.org$iter.example.com\/msp:\/etc\/hyperledger\/fabric\/msp"/ docker-compose-base.yaml
            sed -i s/"tlsVolume"/"..\/crypto-config\/peerOrganizations\/org$iter.example.com\/peers\/peer$jter.org$iter.example.com\/tls:\/etc\/hyperledger\/fabric\/tls"/ docker-compose-base.yaml
            peerPort=$((peerPort+1000))
            jter=$((jter+1))
        done
        iter=$((iter+1))
    done


    ##########################################################################################################
    ################################# Creation of host<#>.yaml for each peer #################################
    ##########################################################################################################

    cat host1Structure.yaml > host1.yaml # Reset host1.yaml config
    rm -r ./configDocs/host*.yaml 2> /dev/null # Reset the rest of host<#>.yaml, the error output is being ignored as it is irrelevant here

    iter=1
    number=2
    numPort=8050
    while [ "$iter" -le "$OrgNUM" ]; do
        jter=0
        while [ "$jter" -lt "$PeerNUM" ]; do
            if [ "$iter" -eq 1 ] && [ "$jter" -eq 0 ]; then
                # Create host1.yaml
                printf "\n$(tput setaf 1)$(tput bold)Configuring host1.yaml $(tput sgr 0)"
                sed -i s/"lastOrderer"/"orderer$ordererNumber.example.com"/ host1.yaml
                sed -i s/"lastPortOrderer"/"$lastPortOrderer"/g host1.yaml
                mv ./host1.yaml ./configDocs
                jter=$((jter+1))
            
            else
                # Create the rest of the host<#>.yaml
                printf "\n$(tput setaf 1)$(tput bold)Configuring host$number.yaml $(tput sgr 0)"
                cat host.yaml > host$number.yaml
                chmod 777 host$number.yaml
                sed -i s/"ordererName"/"orderer$number.example.com"/ host$number.yaml
                sed -i s/"peerName"/"peer$jter"/ host$number.yaml
                sed -i s/"orgName"/"org$iter.example.com"/ host$number.yaml
                sed -i s/"portOrderer"/"$numPort"/g host$number.yaml
                mv ./host$number.yaml ./configDocs                
                number=$((number+1))
                numPort=$((numPort+1000))
                jter=$((jter+1))
            fi
        done
        iter=$((iter+1))
    done


    ##########################################################################################################
    ######################################## Creation of mychannel.sh ########################################
    ##########################################################################################################

    sed -i '5,$d' mychannel.sh # Reset mychannel.sh to its inicial form

    # Join all peers to channel
    printf "\n$(tput setaf 4)$(tput bold)Configuring mychannel.sh $(tput sgr 0)"
    iter=2
    ordPort=9051
    while [ "$iter" -le "$OrgNUM" ]; do
        jter=0
        while [ "$jter" -lt "$PeerNUM" ]; do
            if [ "$iter" -eq 1 ]; then
                echo "docker exec -e CORE_PEER_ADDRESS=peer$jter.org$iter.example.com:$ordPort -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$iter.example.com/peers/peer$jter.org$iter.example.com/tls/ca.crt cli peer channel join -b mychannel.block" >> mychannel.sh
                ordPort=$((ordPort+1000))
                jter=$((jter+1))
            else
                echo "docker exec -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$iter.example.com/users/Admin@org$iter.example.com/msp -e CORE_PEER_ADDRESS=peer$jter.org$iter.example.com:$ordPort -e CORE_PEER_LOCALMSPID="\"Org$iter\MSP\"" -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$iter.example.com/peers/peer$jter.org$iter.example.com/tls/ca.crt cli peer channel join -b mychannel.block" >> mychannel.sh
                ordPort=$((ordPort+1000))
                jter=$((jter+1))
            fi
        done
        iter=$((iter+1))
    done
    
    echo "docker exec cli peer channel update -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" >> mychannel.sh
    iter=2
    corePeerOrg=7051
    while [ "$iter" -le "$OrgNUM" ]; do
        corePeerOrg=$((corePeerOrg+PeerNUM*1000))
        echo "docker exec -e CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$iter.example.com/users/Admin@org$iter.example.com/msp -e CORE_PEER_ADDRESS=peer0.org2.example.com:$corePeerOrg -e CORE_PEER_LOCALMSPID="\"Org${iter}MSP\"" -e CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$iter.example.com/peers/peer0.org$iter.example.com/tls/ca.crt cli peer channel update -o orderer.example.com:7050 -c mychannel -f ./channel-artifacts/Org$iter MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem" >> mychannel.sh
        iter=$((iter+1))
    done

    ##########################################################################################################
    ############################### Creation of host<#>up.sh & host<#>down.sh  ###############################
    ##########################################################################################################

    rm -r ./configDocs/host*.sh 2> /dev/null # Reset host<#>up.sh & host<#>down.sh files created previously, the error output is being ignored as it is irrelevant here
    
    hostNumber=1
    iter=1
    while [ "$iter" -le "$OrgNUM" ]; do
        jter=0
        while [ "$jter" -lt "$PeerNUM" ]; do
            # Creation of host<#>up.sh
            printf "\n$(tput setaf 0)$(tput bold)Creating host${hostNumber}up.sh $(tput sgr 0)"
            echo "docker-compose -f host$hostNumber.yaml up -d" > host${hostNumber}up.sh
            
            # Creation of host<#>down.sh
            printf "\n$(tput setaf 0)$(tput bold)Creating host${hostNumber}down.sh $(tput sgr 0)"            
            sed "1i docker-compose -f host$hostNumber.yaml down -v" hostDownStructure.sh > host${hostNumber}down.sh
            
            mv ./host${hostNumber}up.sh ./configDocs && mv ./host${hostNumber}down.sh ./configDocs
            hostNumber=$((hostNumber+1))
            jter=$((jter+1))
        done
        iter=$((iter+1))
    done

    echo    # To add a new line at the end
    cp ./configtx.yaml ./configDocs/configtx.yaml
    cp ./crypto-config.yaml ./configDocs/crypto-config.yaml
    cp ./docker-compose-base.yaml ./configDocs/docker-compose-base.yaml
    cp ./mychannel.sh ./configDocs/mychannel.sh

