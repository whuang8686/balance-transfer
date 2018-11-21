#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi

starttime=$(date +%s)

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "  ./testAPIs.sh -l golang|node"
  echo "    -l <language> - chaincode language (defaults to \"golang\")"
}
# Language defaults to "golang"
LANGUAGE="golang"

# Parse commandline args
while getopts "h?l:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    l)  LANGUAGE=$OPTARG
    ;;
  esac
done

##set chaincode path
function setChaincodePath(){
	LANGUAGE=`echo "$LANGUAGE" | tr '[:upper:]' '[:lower:]'`
	case "$LANGUAGE" in
		"golang")
		CC_SRC_PATH="github.com/fxchaincode"
		;;
		"node")
		CC_SRC_PATH="$PWD/artifacts/src/github.com/fxchaincode"
		;;
		*) printf "\n ------ Language $LANGUAGE is not supported yet ------\n"$
		exit 1
	esac
}

setChaincodePath

echo "1.POST request Enroll on Org1  ..."
echo
ORG1_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Jim&orgName=Org1')
echo $ORG1_TOKEN
ORG1_TOKEN=$(echo $ORG1_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG1 token is $ORG1_TOKEN"
echo
echo "2.POST request Enroll on Org2 ..."
echo
ORG2_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Barry&orgName=Org2')
echo $ORG2_TOKEN
ORG2_TOKEN=$(echo $ORG2_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "ORG2 token is $ORG2_TOKEN"
echo
echo

echo "3.FXTradeTransfer"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
	"fcn":"FXTradeTransfer",
	"args":["S","0001","0005",	"2018/04/26",	"2018/12/21",	"USD/CNH" ,	"USD"	,"800000"    ,"CNH",    "5104977.6"  	,"6.381222"  	,"FW",  "true"]
}')
echo "Transacton ID is $TRX_ID"
echo
echo

echo "4.FXTradeTransfer"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
	"fcn":"FXTradeTransfer",
	"args":["S","0005","0004",	"2018/04/30",	"2018/09/21",	"GBP/USD" ,	"GBP"	,"500000"    ,"USD",    "691133.25"  	,"1.382267"  	,"FW",  "true"]
}')
echo "Transacton ID is $TRX_ID"
echo
echo

echo "5.FXTradeTransfer"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
	"fcn":"FXTradeTransfer",
	"args":["S","0002","0001",	"2018/05/02",	"2019/04/04",	"USD/CNH" ,	"USD"	,"3030000"	 ,"CNH",    "19518351"	  ,"6.4417"   ,"FW",  "true"]
}')
echo "Transacton ID is $TRX_ID"
echo
echo

echo "6.FXTradeTransfer"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
	"fcn":"FXTradeTransfer",
	"args":["B","0001","0007",	"2018/05/02",	"2018/09/21",	"USD/CNH" ,	"USD"	,"1000000"	 ,"CNH",    "6397165"	    ,"6.397165"  	,"FW",  "true"]
}')
echo "Transacton ID is $TRX_ID"
echo
echo

echo "7.FXTradeTransfer"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
	"fcn":"FXTradeTransfer",
	"args":["S","0002","0008",	"2018/05/02",	"2019/04/04",	"USD/CNH" ,	"USD"	,"2370000"	 ,"CNH",    "15275598"	  ,"6.4454"   ,"FW",  "true"]
}')
echo "Transacton ID is $TRX_ID"
echo
echo

echo "8.FXTradeTransfer"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
	"fcn":"FXTradeTransfer",
	"args":["B","0005","0001",	"2018/04/26",	"2018/12/21",	"USD/CNH" ,	"USD"	,"800000"    ,"CNH",	  "5088977.6"	  ,"6.361222"  	,"FW",  "true"]
}')
echo "Transacton ID is $TRX_ID"
echo
echo

echo "9.FXTradeTransfer"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
	"fcn":"FXTradeTransfer",
	"args":["B","0004","0005",	"2018/04/30",	"2018/09/21",	"GBP/USD" ,	"GBP"	,"500000"    ,"USD",	  "681133.5"	  ,"1.362267"  	,"FW",  "true"]
}')
echo "Transacton ID is $TRX_ID"
echo
echo

echo "10.FXTradeTransfer"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
	"fcn":"FXTradeTransfer",
	"args":["B","0001","0002",	"2018/05/02",	"2019/04/04",	"USD/CNH" ,	"USD"	,"3030000"	 ,"CNH",  	"19457751"	  ,"6.4217"     ,"FW",  "true"]
}')
echo "Transacton ID is $TRX_ID"
echo
echo

echo "11.FXTradeTransfer"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
	"fcn":"FXTradeTransfer",
	"args":["S","0001","0005",	"2018/04/18",	"2018/12/21",	"USD/CNH" ,	"USD"	,"1600000"	 ,"CNH",  	"10128697.6"	,"6.330436"  	,"SPOT","true"]
}')
echo "Transacton ID is $TRX_ID"
echo
echo

echo "12.FXTradeTransfer"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
	"fcn":"FXTradeTransfer",
	"args":["S","0001","0007",	"2018/07/20",	"2018/09/20",	"EUR/CNH" ,	"EUR"	,"500000"    ,"CNH",	  "3992502"	    ,"7.985004"  	,"SPOT","true"]
}')
echo "Transacton ID is $TRX_ID"
echo
echo

echo "13.FXTradeTransfer"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
	"fcn":"FXTradeTransfer",
	"args":["B","0005","0001",	"2018/04/18",	"2018/12/21",	"USD/CNH" ,	"USD"	,"1600000"	 ,"CNH",  	"10096697.6"	,"6.310436"  	,"SPOT","true"]
}')
echo "Transacton ID is $TRX_ID"
echo
echo

echo "14.FXTradeTransfer"
echo
TRX_ID=$(curl -s -X POST \
  http://localhost:4000/channels/mychannel/chaincodes/mycc \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.org1.example.com","peer1.org1.example.com"],
	"fcn":"FXTradeTransfer",
	"args":["B","0007","0001",	"2018/07/20",	"2018/09/20",	"EUR/CNH" ,	"EUR"	,"500000"    ,"CNH",	  "3982502"	    ,"7.965004"  	,"SPOT","true"]
}')
echo "Transacton ID is $TRX_ID"
echo
echo

echo "6.GET query chaincode on peer1 of Org1"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes/mycc?peer=peer0.org1.example.com&fcn=queryCpty&args=%5B%220001%22%5D" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "7.GET query Block by blockNumber"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/blocks/1?peer=peer0.org1.example.com" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "8.GET query Transaction by TransactionID"
echo
curl -s -X GET http://localhost:4000/channels/mychannel/transactions/$TRX_ID?peer=peer0.org1.example.com \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "9.GET query Transaction by TransactionID"
echo
curl -s -X GET http://localhost:4000/channels/mychannel/transactions/$TRX_ID2?peer=peer0.org1.example.com \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

############################################################################
### TODO: What to pass to fetch the Block information
############################################################################
#echo "GET query Block by Hash"
#echo
#hash=????
#curl -s -X GET \
#  "http://localhost:4000/channels/mychannel/blocks?hash=$hash&peer=peer1" \
#  -H "authorization: Bearer $ORG1_TOKEN" \
#  -H "cache-control: no-cache" \
#  -H "content-type: application/json" \
#  -H "x-access-token: $ORG1_TOKEN"
#echo
#echo

echo "10.GET query ChainInfo"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel?peer=peer0.org1.example.com" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "11.GET query Installed chaincodes"
echo
curl -s -X GET \
  "http://localhost:4000/chaincodes?peer=peer0.org1.example.com" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "12.GET query Instantiated chaincodes"
echo
curl -s -X GET \
  "http://localhost:4000/channels/mychannel/chaincodes?peer=peer0.org1.example.com" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo

echo "13.GET query Channels"
echo
curl -s -X GET \
  "http://localhost:4000/channels?peer=peer0.org1.example.com" \
  -H "authorization: Bearer $ORG1_TOKEN" \
  -H "content-type: application/json"
echo
echo


echo "Total #13 execution time : $(($(date +%s)-starttime)) secs ..."
