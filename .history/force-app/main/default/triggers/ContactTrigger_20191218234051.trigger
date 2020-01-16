trigger ContactTrigger on Contact (before insert, before update, after insert, after update) {

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            System.debug('Contact Trigger Fired on Insert');
            ContactTriggerHandler.getContactAccountInfo(Trigger.newMap, null, Trigger.isInsert);
        } else if(Trigger.isUpdate){
            System.debug('Contact Trigger Fired on Update');
            ContactTriggerHandler.getContactAccountInfo(Trigger.newMap, Trigger.oldMap, Trigger.isInsert);
        }
    }
}