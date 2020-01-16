public without sharing class ZipManagementTriggerHandler {

    public static void handleZipUserChange(Map<Id,Zip_Postal_Code_Management__c> newZipMap, Map<Id,Zip_Postal_Code_Management__c> oldZipMap){
        System.debug('In handleZipUserChange method');
        Set<String> zipPostalCodes = new Set<String>();

        for(Zip_Postal_Code_Management__c zip : newZipMap.values()){
            Zip_Postal_Code_Management__c oldZip = oldZipMap.get(zip.Id);
            if(zip.User__c != oldZip.User__c){
                zipPostalCodes.add(zip.Zip_or_Postal_Code__c);
            }
        }

        getObjectIds(zipPostalCodes);
    }

    public static void getObjectIds(Set<String> zipPostalCodes){
        System.debug('In getObjectIds method ' + zipPostalCodes);
        List<Account> accounts = [SELECT Id, ShippingPostalCode FROM Account WHERE ShippingPostalCode IN: zipPostalCodes];
        /* List<Opportunity> opps = [SELECT Id, Account.ShippingPostalCode FROM Opportunity WHERE Account.ShippingPostalCode IN: zipPostalCodes];
        List<Account_Profile__c> accProfs = [SELECT Id, Account__r.ShippingPostalCode FROM Account_Profile__c WHERE Account__r.ShippingPostalCode IN: zipPostalCodes];
        List<Lead> leads = [SELECT Id, PostalCode FROM Lead WHERE PostalCode IN: zipPostalCodes]; */
        List<Id> accountIds = new List<Id>();
        List<Id> accProfIds = new List<Id>();
        List<Id> oppIds = new List<Id>();
        List<Id> leadIds = new List<Id>();

        if(!accounts.isEmpty()){
            for(Account acc : accounts){
                accountIds.add(acc.ShippingPostalCode);
            }
        }

        if(!accountIds.isEmpty()){
            System.debug('accountIds ' + accountIds.size());
            AccountUtils.updateAccountSharing(accountIds); 
        }

        /* if(!opps.isEmpty()){    
            for(Opportunity opp : opps){
                oppIds.add(opp.Account.ShippingPostalCode);
            }
        }

        if(!oppIds.isEmpty()){    
            System.debug('oppIds ' + oppIds.size());
            OpportunityTriggerHandler.updateOpportunitySharing(oppIds);
        }

        if(!accProfs.isEmpty()){
            for(Account_Profile__c ap : accProfs){
                accProfIds.add(ap.Account__r.ShippingPostalCode);
            }
        }

        if(!accProfIds.isEmpty()){
            System.debug('accProfIds ' + accProfIds.size());
            AccountProfileTriggerHandler.updateAccountProfileSharing(accProfIds);
        }

        if(!leads.isEmpty()){
            for(Lead l : leads){
                leadIds.add(l.PostalCode);
            }
        }

        if(!leadIds.isEmpty()){
            System.debug('leadIds ' + leadIds.size());
            LeadTriggerHandler.updateLeadSharingRules(leadIds);
        } */
    }
}