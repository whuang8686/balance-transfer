var path = require('path');
var fs = require('fs');
var util = require('util');
var hfc = require('fabric-client');
var helper = require('./helper.js');
var logger = helper.getLogger('event');



var registeredEvent = async function(eventName, peerNames, channelName, username, org_name) {
	try {

        var client = await helper.getClientForOrg(org_name, username);
        var tx_id = client.newTransactionID();
        var channel = client.getChannel(channelName);
        var channel_event_hub = channel.getChannelEventHubsForOrg();
		let request = {
    		targets : peerNames,
    		chaincodeId: channelName,
    		fcn: 'invoke',
    		args: ['doSomething', 'with this data'],
    		txId: tx_id
		};
		
		//return channel.sendTransactionProposal(request);
		//}).then((results) => {
		// a real application would check the proposal results
		//console.log('Successfully endorsed proposal to invoke chaincode');
		let results = await channel.sendTransactionProposal(request);
		// the returned object has both the endorsement results
		// and the actual proposal, the proposal will be needed
		// later when we send a transaction to the orederer
		var proposalResponses = results[0];
		var proposal = results[1];

		// Build the promise to register a event listener with the NodeSDK.
		// The NodeSDK will then send a request to the peer's channel-based event
		// service to start sending blocks. The blocks will be inspected to see if
		// there is a match with a chaincode event listener.
		let event_monitor = new Promise((resolve, reject) => {
  			let regid = null;
   			let handle = setTimeout(() => {
        		if (regid) {
            		// might need to do the clean up this listener
            		channel_event_hub.unregisterChaincodeEvent(regid);
            		console.log('Timeout - Failed to receive the chaincode event');
       	    	}
        		reject(new Error('Timed out waiting for chaincode event'));
    		}, 20000);

    		regid = channel_event_hub.registerChaincodeEvent(channelName, '^evtsender*',
        		(event, block_num, txnid, status) => {
        		// This callback will be called when there is a chaincode event name
        		// within a block that will match on the second parameter in the registration
        		// from the chaincode with the ID of the first parameter.
        		console.log('Successfully got a chaincode event with transid:'+ txnid + ' with status:'+status);

        		// might be good to store the block number to be able to resume if offline
        		storeBlockNumForLater(block_num);

        		// to see the event payload, the channel_event_hub must be connected(true)
       	 		let event_payload = event.payload.toString('utf8');
        		if(event_payload.indexOf('CHAINCODE') > -1) {
            		clearTimeout(handle);
            		// Chaincode event listeners are meant to run continuously
            		// Therefore the default to automatically unregister is false
            		// So in this case we want to shutdown the event listener once
            		// we see the event with the correct payload
            		channel_event_hub.unregisterChaincodeEvent(regid);
            		console.log('Successfully received the chaincode event on block number '+ block_num);
            		resolve('RECEIVED');
        		} else {
            		console.log('Successfully got chaincode event ... just not the one we are looking for on block number '+ block_num);
        		}
    		}, (error)=> {
        		clearTimeout(handle);
        		console.log('Failed to receive the chaincode event ::'+error);
        		reject(error);
    		}
        		// no options specified
        		// startBlock will default to latest
        		// endBlock will default to MAX
        		// unregister will default to false
        		// disconnect will default to false
    		);
		});
		
		// build the promise to send the proposals to the orderer
	    let send_trans = channel.sendTransaction({proposalResponses: results[0], proposal: results[1]});

    	// now that we have two promises all set to go... execute them
    	return Promise.all([event_monitor, send_trans]);
		
		//return 'RegisteredEvent ok' + eventName +  peerNames + channelName + username + org_name;
	} catch(error) {
		logger.error('Failed to get registered user: with error: %s',error.toString());
		return 'failed '+ error.toString();
	}
};


exports.registeredEvent = registeredEvent;



