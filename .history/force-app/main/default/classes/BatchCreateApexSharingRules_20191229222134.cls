public with sharing class BatchCreateApexSharingRules implements Database.Batchable<sObject>{

    private final List<Id> zipMgmtUserId;
    
    public BatchCreateApexSharingRules(List<Id> zipUserId) {
        this.zipMgmtUserId.add(zipUserId);
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Brand__c, CurrencyIsoCode, User__c, Zip_or_Postal_Code__c FROM Zip_Postal_Code_Management__c WHERE User__c =: ' + zipMgmtUserId;
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Zip_Postal_Code_Management__c> batch){

        List<Account> accounts = new List<Account>();
        List<Lead> leads = new List<Lead>();        
        List<String> zips = new List<String>();

        for(Zip_Postal_Code_Management__c zip : batch){
            zips.add(zip.Zip_or_Postal_Code__c);
        }

        
    }

    public void finish(Database.BatchableContext BC){

    }
}
