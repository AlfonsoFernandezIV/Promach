trigger OpportunityTrigger on Opportunity (after insert, after update) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            Boolean isInsert = true;
            System.debug('Opp Trigger Fired');
            OpportunityTriggerHandler.createSharingRules(Trigger.newMap, Trigger.oldMap, Trigger.isInsert);
        } else if(Trigger.isUpdate){
            isUpdate = true;
            OpportunityTriggerHandler.createSharingRules(Trigger.newMap, Trigger.oldMap, Trigger.isInsert);
        }
    }
}