trigger AccountTrigger on Account (after insert, after update) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            System.debug('Account Trigger Fired on Insert');
            AccountUtils.createAccountShares(Trigger.newMap);
        } else if(Trigger.isUpdate){
            System.debug('Account Trigger Fired on Update');
            AccountUtils.updateAccountShares(Trigger.newMap, Trigger.oldMap);
        }
    }
}