trigger ZipManagementTrigger on Zip_Postal_Code_Management__c (after update) {
    
    Apex_Sharing_Toggle__c ast = Apex_Sharing_Toggle__c.getInstance(UserInfo.getUserId());
    System.debug('ast.AllApexSharing__c ' + ast.AllApexSharing__c);
    if(!ast.AllApexSharing__c){
        return;
    } else if(Trigger.isAfter){
        if(Trigger.isUpdate){
            ZipManagementTriggerHandler.handleZipUserChange(Trigger.newMap, Trigger.oldMap);
        }
    }
}