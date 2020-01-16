trigger OpportunityTrigger on Opportunity (after insert, after update) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            System.debug('Opp Trigger Fired');
            OpportunityTriggerHandler.insertOppSharingRUles(Trigger.newMap);
        } else if(Trigger.isUpdate){
            isUpdate = true;
            OpportunityTriggerHandler.updateOppSharingRules(Trigger.newMap, Trigger.oldMap);
        }
    }
}