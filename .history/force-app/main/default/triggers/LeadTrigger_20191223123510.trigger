Trigger LeadTrigger on Lead (before insert, after insert, after update) {

    if(Trigger.isBefore){
        if(Trigger.isInsert){
            LeadTriggerHandler.assignedLeadOwner(Trigger.new);
        } 
    } else if(Trigger.isAfter){
        if(Trigger.isInsert){
            System.debug('Lead Trigger Fired on Insert');
            LeadTriggerHandler.createLeadSharing(Trigger.newMap);
        } else if(Trigger.isUpdate){
            System.debug('Lead Trigger Fired on Update');
            LeadTriggerHandler.assignIDTLeads(Trigger.newMap, Trigger.oldMap, Trigger.isInsert);
        }
    }
}