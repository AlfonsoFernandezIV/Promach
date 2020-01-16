public without sharing class ZipManagementTriggerHandler {

    public static void handleZipUserChange(Map<Id,Zip_Postal_Code_Management__c> newZipMap, Map<Id,Zip_Postal_Code_Management__c> oldZipMap){
        System.debug('In handleZipUserChange method');
        Set<String> zipPostalCodes = new Set<String>();

        for(Zip_Postal_Code_Management__c zip : newZipMap.values()){
            Zip_Postal_Code_Management__c oldZip = oldZipMap.get(zip.Id);
            if(zip.User__c != oldZip.User__c){
                System.debug('zip.Zip_or_Postal_Code__c ' + zip.Zip_or_Postal_Code__c);
                zipPostalCodes.add(zip.Zip_or_Postal_Code__c);
            }
        }

        getObjectIds(zipPostalCodes);
    }

    public static void getObjectIds(Set<String> zipPostalCodes){
        System.debug('In getObjectIds method ' + zipPostalCodes);

        List<Account> accounts = new List<Account>();
        List<String> zipsForSoql = new List<String>();
        List<Opportunity> opps = new List<Opportunity>();
        List<Account_Profile__c> accProfs = new List<Account_Profile__c>();
        List<Lead> leads = new List<Lead>();
        List<Id> accountIds = new List<Id>();
        List<Id> accProfIds = new List<Id>();
        List<Id> oppIds = new List<Id>();
        List<Id> leadIds = new List<Id>();

        for(String zip : zipPostalCodes){
            String likeZip = zip + '%';
            zipsForSoql.add(likeZip);
        }

        accounts = [SELECT Id, ShippingPostalCode, OwnerId FROM Account WHERE ShippingPostalCode LIKE: zipPostalCodes];
        opps = [SELECT Id, Account.ShippingPostalCode, Account.OwnerId FROM Opportunity WHERE Account.ShippingPostalCode LIKE: zipPostalCodes];
        accProfs = [SELECT Id, Account__r.ShippingPostalCode, Account__r.OwnerId FROM Account_Profile__c WHERE Account__r.ShippingPostalCode LIKE: zipPostalCodes];
        leads = [SELECT Id, PostalCode, OwnerId FROM Lead WHERE PostalCode LIKE: zipPostalCodes];
        
        if(!accounts.isEmpty()){
            for(Account acc : accounts){
                accountIds.add(acc.Id);
            }
        }

        if(!accountIds.isEmpty()){
            System.debug('accountIds ' + accountIds.size());
            AccountUtils.updateAccountSharing(accountIds); 
        }

        if(!opps.isEmpty()){    
            for(Opportunity opp : opps){
                oppIds.add(opp.Id);
            }
        }

        if(!oppIds.isEmpty()){    
            System.debug('oppIds ' + oppIds.size());
            OpportunityTriggerHandler.updateOpportunitySharing(oppIds);
        }

        if(!accProfs.isEmpty()){
            for(Account_Profile__c ap : accProfs){
                accProfIds.add(ap.Id);
            }
        }

        if(!accProfIds.isEmpty()){
            System.debug('accProfIds ' + accProfIds.size());
            AccountProfileTriggerHandler.updateAccountProfileSharing(accProfIds);
        }

        if(!leads.isEmpty()){
            for(Lead l : leads){
                leadIds.add(l.Id);
            }
        }

        if(!leadIds.isEmpty()){
            System.debug('leadIds ' + leadIds.size());
            LeadTriggerHandler.updateLeadSharingRules(leadIds);
        }
    }

    public static List<Account> getAccountsFromZip(String zip){
        return [SELECT Id, ShippingPostalCode, OwnerId FROM Account WHERE ShippingPostalCode LIKE: zip + '%'];
    }
}