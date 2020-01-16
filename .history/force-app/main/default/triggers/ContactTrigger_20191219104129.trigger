trigger ContactTrigger on Contact (after insert, after update) {

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            System.debug('Contact Trigger Fired on Insert');
            ContactTriggerHandler.createContactShares(Trigger.newMap);
        } else if(Trigger.isUpdate){
            System.debug('Contact Trigger Fired on Update');
            for(Contact con : Trigger.new){
                Contact oldCon = Trigger.oldMap.get(con.Id);
                if(con.AccountId != oldCon.AccountId){
                    ContactTriggerHandler.updateContactShares(Trigger.newMap, Trigger.oldMap);
                }
            }
        }
    }
}