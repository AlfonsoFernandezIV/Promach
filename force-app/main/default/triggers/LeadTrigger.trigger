Trigger LeadTrigger on Lead (before insert, after insert, after update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            LeadTriggerHandler.assignedLeadOwner(Trigger.new);
        } 
    } else if(Trigger.isAfter){
        if(Trigger.isInsert){
            LeadTriggerHandler.createLeadSharing(Trigger.newMap);
        } else if(Trigger.isUpdate){
            LeadTriggerHandler.updateLeadSharing(Trigger.newMap, Trigger.oldMap);
        }
    }
}