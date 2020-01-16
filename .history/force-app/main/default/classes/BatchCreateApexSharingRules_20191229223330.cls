public with sharing class BatchCreateApexSharingRules implements Database.Batchable<sObject>{

    private final Id zipMgmtUserId;
    
    public BatchCreateApexSharingRules(Id zipUserId) {
        this.zipMgmtUserId = zipUserId;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Brand__c, CurrencyIsoCode, User__c, Zip_or_Postal_Code__c FROM Zip_Postal_Code_Management__c WHERE User__c =: ' + zipMgmtUserId;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Zip_Postal_Code_Management__c> batch){

        List<Account> accounts = new List<Account>();
        List<Opportunity> opps = new List<Opportunity>();
        List<Account_Profile__c> accProfs = new List<Account_Profile__c>();
        List<Lead> leads = new List<Lead>();        
        List<String> zips = new List<String>();
        List<String> zipsForSoql = new List<String>();

        for(Zip_Postal_Code_Management__c zip : batch){
            zips.add(zip.Zip_or_Postal_Code__c);
        }

        for(String zip : zips){
            System.debug('zips ' + zips);
            String likeZip = zip + '%';
            System.debug('likeZip ' + likeZip);
            zipsForSoql.add(likeZip);
        }

        accounts = [SELECT Id, ShippingPostalCode, OwnerId FROM Account WHERE ShippingPostalCode LIKE: zipsForSoql];
        opps = [SELECT Id, Account.ShippingPostalCode, Account.OwnerId FROM Opportunity WHERE Account.ShippingPostalCode LIKE: zipsForSoql];
        accProfs = [SELECT Id, Account__r.ShippingPostalCode, Account__r.OwnerId FROM Account_Profile__c WHERE Account__r.ShippingPostalCode LIKE: zipsForSoql];
        leads = [SELECT Id, PostalCode, OwnerId FROM Lead WHERE PostalCode LIKE: zipsForSoql];
    }

    public void finish(Database.BatchableContext BC){

    }
}
