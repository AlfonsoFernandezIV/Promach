trigger ContactTrigger on Contact (after insert, after update) {

    if(Trigger.isAfter){
        if(Trigger.isInsert){
            System.debug('Contact Trigger Fired on Insert');
            ContactTriggerHandler.createContactShares(Trigger.newMap);
        } else if(Trigger.isUpdate){
            System.debug('Contact Trigger Fired on Update');
            for(Contact con : Trigger.new){
                Contact oldCon = Trigger.oldMap.get(con.Id);
                String conAcct = con.AccountId;
                String oldConAcct = oldCon.AccountId;
                System.debug('oldConAcct ' + con.AccountId);
                System.debug('oldConAcct ' + Trigger.oldMap.get(con.Id).AccountId);
                System.debug('conAcct ' + conAcct);
                System.debug('oldConAcct ' + oldConAcct);
                if(conAcct != oldConAcct){
                    ContactTriggerHandler.getContactAccountInfo(Trigger.newMap, Trigger.oldMap);
                }
            }
        }
    }
}