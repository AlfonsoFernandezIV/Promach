trigger OpportunityTrigger on Opportunity (after insert, after update) {
    
    Apex_Sharing_Toggle__c ast = Apex_Sharing_Toggle__c.getInstance(UserInfo.getUserId());
    if(ast.AllApexSharing__c){
        return;
    } else if(Trigger.isAfter){
        if(Trigger.isInsert){
            OpportunityTriggerHandler.insertOppSharingRUles(Trigger.newMap);
        } else if(Trigger.isUpdate){
            OpportunityTriggerHandler.updateOppSharingRules(Trigger.newMap, Trigger.oldMap);
        }
    }
}