trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert || Trigger.isUpdate){
            System.debug('Account Trigger Fired on Insert');
            AccountUtils.detectAccountChange(Trigger.newMap, Trigger.oldMap, Trigger.isInsert);
        }
    }
}