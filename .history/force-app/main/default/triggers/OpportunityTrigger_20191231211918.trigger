trigger OpportunityTrigger on Opportunity (after insert, after update) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            OpportunityTriggerHandler.insertOppSharingRUles(Trigger.newMap);
        } else if(Trigger.isUpdate){
            OpportunityTriggerHandler.updateOppSharingRules(Trigger.newMap, Trigger.oldMap);
        }
    }
}