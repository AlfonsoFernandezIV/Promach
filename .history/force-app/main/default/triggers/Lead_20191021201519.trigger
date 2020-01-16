Trigger Lead on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            LeadTriggerHandler.assignIDTLeads(trigger.new, null, true, false);
        } else if(Trigger.isUpdate){
            LeadTriggerHandler.assignIDTLeads(trigger.new, trigger.oldMap, false, true);
        }
    } else if(Trigger.isAfter){
        if(Trigger.isBefore){
            
        } else if(Trigger.isAfter){
            
        }
    }
}