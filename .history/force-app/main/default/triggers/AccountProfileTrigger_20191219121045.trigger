trigger AccountProfileTrigger on Account_Profile__c (before insert, after insert, after update) {

    Boolean isInsert = false;
    Boolean isUpdate = false;

    if(Trigger.isBefore){
        if(Trigger.isInsert){

        } else if(Trigger.isUpdate){

        }
    } else if(Trigger.isAfter){
        if(Trigger.isInsert){
            System.debug('Account Profile Trigger Fired on Insert');
            AccountProfileTriggerHandler.createAcctProfileSharingRules(Trigger.newMap);
        } /* else if(Trigger.isUpdate){
            isUpdate = true;
            System.debug('Account Profile Trigger Fired on Upload');
            AccountProfileTriggerHandler.createSharingRules(Trigger.newMap, Trigger.oldMap, isInsert, isUpdate); 
        } */
    }
}