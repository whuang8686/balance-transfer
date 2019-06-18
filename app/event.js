var path = require('path');
var fs = require('fs');
var util = require('util');
var hfc = require('fabric-client');
var helper = require('./helper.js');
var logger = helper.getLogger('event');



var registeredEvent = async function(eventName, peerNames, channelName, chaincodeName, username, org_name) {
	try {

        var client = await helper.getClientForOrg(org_name, username);
        var channel = client.getChannel(channelName);
        var tx_id = client.newTransactionID();
        let channel_event_hub = channel.newChannelEventHub(peerNames);
		
        var promises = [];
        let event_hubs = channel.getChannelEventHubsForOrg();
        event_hubs.forEach((eh) => {
            let event_monitor_execute = new Promise((resolve, reject) => {
            let regid1 = null;
            let handle = setTimeout(() => {
                    if (regid1) {
                             // might need to do the clean up this listener
                            eh.unregisterChaincodeEvent(regid1);
                            logger.info('Timeout - Failed to receive the chaincode event');
                    }
               reject(new Error('Timed out waiting for chaincode event'));
            }, 50000);
            eh.connect(true);
            regid1 = eh.registerChaincodeEvent(chaincodeName,'evtsender',(event,block_num,tx,status) => {

                    logger.info('Successfully got a chaincode event with transid:'+tx + ' with status:'+status);
                    let event_payload = event.payload;
                    logger.info('Successfully got a chaincode event with payload:'+ event_payload.toString('utf8'));
              //      if(event_payload.indexOf('CHAINCODE') > -1) {
                    if(block_num){
                            clearTimeout(handle);
                            eh.unregisterChaincodeEvent(regid1);
                            logger.info('Successfully received the chaincode event on block number '+ block_num);
                            resolve('RECEIVED');
                    } else {
                            logger.info('Successfully got chaincode event ... just not the one we are looking for on block number '+ block_num);
                    }
            }, (error)=> {
                    clearTimeout(handle);
                    logger.info('Failed to receive the chaincode event ::'+error);
                    reject(error);
            }
            );

        });
           return promises.push(event_monitor_execute);
        });

    	// now that we have two promises all set to go... execute them
    	
		
		//return 'RegisteredEvent ok' + eventName +  peerNames + channelName + username + org_name;
	} catch(error) {
		logger.error('Failed to get registered user: with error: %s',error.toString());
		return 'failed '+ error.toString();
	}
};


exports.registeredEvent = registeredEvent;



