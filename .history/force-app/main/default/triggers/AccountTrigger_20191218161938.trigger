trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    
    if(Trigger.isBefore){
       if(Trigger.isInsert){

        } else if(Trigger.isUpdate){

        }
    } else if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            System.debug('Account Trigger Fired on Insert');
            AccountUtils.createAccountSharing(Trigger.newMap, Trigger.oldMap, Trigger.isInsert);
        }
    }
}