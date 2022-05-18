#!/bin/sh

#Create the Channel
   export CHANNEL_NAME=channel1
   peer channel create -o orderer.jnvr.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/jnvr.com/orderers/orderer.jnvr.com/msp/tlscacerts/tlsca.jnvr.com-cert.pem

#Join Org1 0rg2 Org3 and Org4 to the Channel
    peer channel join -b channel1.block
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.jnvr.com/users/Admin@org2.jnvr.com/msp/ CORE_PEER_ADDRESS=peer0.org2.jnvr.com:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.jnvr.com/peers/peer0.org2.jnvr.com/tls/ca.crt peer channel join -b channel1.block
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.jnvr.com/users/Admin@org3.jnvr.com/msp/ CORE_PEER_ADDRESS=peer0.org3.jnvr.com:7051 CORE_PEER_LOCALMSPID="Org3MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.jnvr.com/peers/peer0.org3.jnvr.com/tls/ca.crt peer channel join -b channel1.block    
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.jnvr.com/users/Admin@org4.jnvr.com/msp/ CORE_PEER_ADDRESS=peer0.org4.jnvr.com:7051 CORE_PEER_LOCALMSPID="Org4MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.jnvr.com/peers/peer0.org4.jnvr.com/tls/ca.crt peer channel join -b channel1.block

#Set the Anchors Peers in all Orgs
    peer channel update -o orderer.jnvr.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/jnvr.com/orderers/orderer.jnvr.com/msp/tlscacerts/tlsca.jnvr.com-cert.pem
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.jnvr.com/users/Admin@org2.jnvr.com/msp/ CORE_PEER_ADDRESS=peer0.org2.jnvr.com:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.jnvr.com/peers/peer0.org2.jnvr.com/tls/ca.crt peer channel update -o orderer.jnvr.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org2MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/jnvr.com/orderers/orderer.jnvr.com/msp/tlscacerts/tlsca.jnvr.com-cert.pem
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.jnvr.com/users/Admin@org3.jnvr.com/msp/ CORE_PEER_ADDRESS=peer0.org3.jnvr.com:7051 CORE_PEER_LOCALMSPID="Org3MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.jnvr.com/peers/peer0.org3.jnvr.com/tls/ca.crt peer channel update -o orderer.jnvr.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org3MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/jnvr.com/orderers/orderer.jnvr.com/msp/tlscacerts/tlsca.jnvr.com-cert.pem
    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.jnvr.com/users/Admin@org4.jnvr.com/msp/ CORE_PEER_ADDRESS=peer0.org4.jnvr.com:7051 CORE_PEER_LOCALMSPID="Org4MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.jnvr.com/peers/peer0.org4.jnvr.com/tls/ca.crt peer channel update -o orderer.jnvr.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org4MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/jnvr.com/orderers/orderer.jnvr.com/msp/tlscacerts/tlsca.jnvr.com-cert.pem

# #Make chaincode package
#    export CHANNEL_NAME=channel1
#    export CHAINCODE_NAME=foodcontrol
#    export CHAINCODE_VERSION=1
#    export CC_RUNTIME_LANGUAGE=golang
#    export CC_SRC_PATH="../../../chaincode/$CHAINCODE_NAME/"
#    export ORDERER_CA=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/jnvr.com/orderers/orderer.jnvr.com/msp/tlscacerts/tlsca.jnvr.com-cert.pem
#    peer lifecycle chaincode package ${CHAINCODE_NAME}.tar.gz --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} --label ${CHAINCODE_NAME}_${CHAINCODE_VERSION} >&log.txt

# #Install Chaincode
#    peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz
#    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.jnvr.com/users/Admin@org2.jnvr.com/msp/ CORE_PEER_ADDRESS=peer0.org2.jnvr.com:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.jnvr.com/peers/peer0.org2.jnvr.com/tls/ca.crt peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz
#    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.jnvr.com/users/Admin@org3.jnvr.com/msp/ CORE_PEER_ADDRESS=peer0.org3.jnvr.com:7051 CORE_PEER_LOCALMSPID="Org3MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.jnvr.com/peers/peer0.org3.jnvr.com/tls/ca.crt peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz
#    CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.jnvr.com/users/Admin@org4.jnvr.com/msp/ CORE_PEER_ADDRESS=peer0.org4.jnvr.com:7051 CORE_PEER_LOCALMSPID="Org4MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.jnvr.com/peers/peer0.org4.jnvr.com/tls/ca.crt peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz

# #Endorsing Policies


