trigger ZipManagementTrigger on Zip_Postal_Code_Management__c (after update) {
    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            ZipManagementTriggerHandler.handleZipUserChange(Trigger.newMap, Trigger.oldMap);
        }
    }
}