/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_AccountTrigger on Account (before delete, before insert, before update, after delete, after insert, after undelete, after update){

        dlrs.RollupService.triggerHandler();

        if(Trigger.isBefore){
            if(Trigger.isDelete){

            }else if(Trigger.isInsert){

            }else if(Trigger.isUpdate){

            } 
        }else if (Trigger.isAfter){
            if(Trigger.isDelete){

            }else if(Trigger.isInsert){

            } else if(Trigger.isUndelete){

            }else if(Trigger.isUpdate){

            } 
        }
    }