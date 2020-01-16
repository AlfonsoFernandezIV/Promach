Trigger Lead on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(Trigger.isBefore){
        if(Trigger.isBefore){
            LeadTriggerHandler.assignIDTLeads(trigger.new, null);
        } else if(Trigger.isAfter){
            LeadTriggerHandler.assignIDTLeads(trigger.new, trigger.oldMap);
        }
    } else if(Trigger.isAfter){
        if(Trigger.isBefore){
            
        } else if(Trigger.isAfter){
            
        }
    }
}