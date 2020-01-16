trigger AccountProfileTrigger on Account_Profile__c (after insert, after update) {

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            System.debug('Account Profile Trigger Fired on Insert');
            AccountProfileTriggerHandler.createAcctProfileSharingRules(Trigger.newMap);
        }
        else if(Trigger.isUpdate){
            System.debug('Account Profile Trigger Fired on Upload');
            AccountProfileTriggerHandler.updateAcctProfileSharingRules(Trigger.newMap, Trigger.oldMap); 
        }
    }
}