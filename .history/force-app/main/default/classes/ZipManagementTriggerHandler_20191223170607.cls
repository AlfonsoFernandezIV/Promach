public without sharing class ZipManagementTriggerHandler {

    public static void handleZipUserChange(Map<Id,Zip_Postal_Code_Management__c> newZipMap, Map<Id,Zip_Postal_Code_Management__c> oldZipMap){
        System.debug('In handleZipUserChange method');
        Set<String> zipPostalCodes = new Set<String>();

        for(Zip_Postal_Code_Management__c zip : newZipMap.values()){
            Zip_Postal_Code_Management__c oldZip = newZipMap.get(zip.Id);
            if(zip.User__c != oldZip.User__c){
                zipPostalCodes.add(zip.Zip_or_Postal_Code__c);
            }
        }

        getObjectIds(zipPostalCodes);
    }

    public static void getObjectIds(Set<String> zipPostalCodes){
        List<Account> accounts = new List<Account>();
        List<Opportunity> opps = new List<Opportunity>();
        List<Account_Profile__c> accProfs = new List<Account_Profile__c>();
        List<Lead> leads = new List<Lead>();
        List<Id> accountIds = new List<Id>();
        List<Id> accProfIds = new List<Id>();
        List<Id> oppIds = new List<Id>();
        List<Id> leadIds = new List<Id>();

        accounts = [SELECT Id FROM Account WHERE ShippingPostalCode IN: zipPostalCodes];
        opps = [SELECT Id FROM Opportunity WHERE Account.ShippingPostalCode IN: zipPostalCodes];
        accProfs = [SELECT Id FROM Account_Profile__c WHERE Account__r.ShippingPostalCode IN: zipPostalCodes];
        leads = [SELECT Id FROM Lead WHERE PostalCode IN: zipPostalCodes];

        if(!accounts.isEmpty()){
            for(Account acc : accounts){
                accountIds.add(acc.ShippingPostalCode);
            }
        }

        if(!accountIds.isEmpty()){
            AccountUtils.updateAccountSharing(accountIds);
        }

        if(!opps.isEmpty()){    
            for(Opportunity opp : opps){
                oppIds.add(opp.Account.ShippingPostalCode);
            }
        }

        if(!oppIds.isEmpty()){    
            oppIds.add(opp.Account.ShippingPostalCode);
        }

        if(!accProfs.isEmpty()){
            for(Account_Profile__c ap : accProfs){
                accProfIds.add(ap.Account__r.ShippingPostalCode);
            }
        }

        if(!leads.isEmpty()){
            for(Lead l : leads){
                leadIds.add(l.PostalCode);
            }
        }

        
    }

    
}