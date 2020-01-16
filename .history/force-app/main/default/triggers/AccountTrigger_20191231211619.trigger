trigger AccountTrigger on Account (after insert, after update) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            AccountUtils.createAccountShares(Trigger.newMap);
        } else if(Trigger.isUpdate){
            AccountUtils.updateAccountShares(Trigger.newMap, Trigger.oldMap);
        }
    }
}