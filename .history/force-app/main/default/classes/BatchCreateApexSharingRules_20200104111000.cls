public with sharing class BatchCreateApexSharingRules implements Database.Batchable<sObject>{

    private final Id zipMgmtUserId;
    
    public BatchCreateApexSharingRules(){}
    
    public BatchCreateApexSharingRules(Id zipUserId) {
        this.zipMgmtUserId = zipUserId;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
     	String query;
        if(zipMgmtUserId != null){
            query = 'SELECT Brand__c, User__c, Zip_or_Postal_Code__c FROM Zip_Postal_Code_Management__c WHERE User__c =: zipMgmtUserId';
		} else {
            query = 'SELECT Brand__c, User__c, Zip_or_Postal_Code__c FROM Zip_Postal_Code_Management__c';
        }
        return Database.getQueryLocator(query);
	}

    public void execute(Database.BatchableContext BC, List<Zip_Postal_Code_Management__c> batch){

        List<Account> accounts = new List<Account>();
        List<Opportunity> opps = new List<Opportunity>();
        List<Account_Profile__c> accProfs = new List<Account_Profile__c>();
        List<Lead> leads = new List<Lead>();
        List<Id> accountIds = new List<Id>();
        List<Id> accProfIds = new List<Id>();
        List<Id> oppIds = new List<Id>();
        List<Id> leadIds = new List<Id>();        
        List<String> zips = new List<String>();
        List<String> zipsForSoql = new List<String>();

        for(Zip_Postal_Code_Management__c zip : batch){
            zips.add(zip.Zip_or_Postal_Code__c);
        }

        for(String zip : zips){
            String likeZip = zip + '%';
            zipsForSoql.add(likeZip);
        }

        accounts = [SELECT Id, BillingPostalCode, ShippingPostalCode, OwnerId FROM Account WHERE ShippingPostalCode LIKE: zipsForSoql];

        if(!accounts.isEmpty()){
            for(Account acc : accounts){
                accountIds.add(acc.Id);
            }
        }

        if(!accountIds.isEmpty()){
            updateAccountSharing(accountIds); 
        }

        opps = [SELECT Id, Account.ShippingPostalCode, Account.BillingPostalCode, Account.OwnerId FROM Opportunity WHERE AccountId IN: accountIds];
        accProfs = [SELECT Id, Account__r.ShippingPostalCode, Account__r.BillingPostalCode, Account__r.OwnerId FROM Account_Profile__c WHERE Account__c IN: accountIds];
        leads = [SELECT Id, PostalCode, OwnerId FROM Lead WHERE PostalCode LIKE: zipsForSoql];

        if(!opps.isEmpty()){    
            for(Opportunity opp : opps){
                oppIds.add(opp.Id);
            }
        }

        if(!oppIds.isEmpty()){    
            updateOpportunitySharing(oppIds);
        }

        if(!accProfs.isEmpty()){
            for(Account_Profile__c ap : accProfs){
                accProfIds.add(ap.Id);
            }
        }

        if(!accProfIds.isEmpty()){
            updateAccountProfileSharing(accProfIds);
        }

        if(!leads.isEmpty()){
            for(Lead l : leads){
                leadIds.add(l.Id);
            }
        }

        if(!leadIds.isEmpty()){
            LeadTriggerHandler.updateLeadSharingRules(leadIds);
        }
    }

    public void finish(Database.BatchableContext BC){

    }

    public static void updateAccountSharing(List<Id> accountIds){
        
        List<Account> accounts = new List<Account>();
        Set<String> accountZips = new Set<String>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        accounts = [SELECT Id, ShippingPostalCode, BillingPostalCode, OwnerId FROM Account WHERE Id IN: accountIds];

        for(Account acc : accounts){
            if(acc.ShippingPostalCode != null){
                accountZips.add(acc.ShippingPostalCode);
            } else if(acc.BillingPostalCode != null){
                accountZips.add(acc.BillingPostalCode);
            }
            
        }
        
        if(!accountZips.isEmpty()){
            zipMgmtMap = AccountUtils.getZipMgmtMap(accountZips);
        }
        
        AccountUtils.deleteExistingApexSharing(accounts, zipMgmtMap);
        AccountUtils.insertAccountShares(accounts, zipMgmtMap);
    }

    public static void updateAccountProfileSharing(List<Id> accProfIds){
        
        List<Account_Profile__c> accProfs = new List<Account_Profile__c>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        accProfs = [SELECT Id, Account__r.ShippingPostalCode, Account__r.BillingPostalCode, Brand2__c, OwnerId FROM Account_Profile__c WHERE Id IN: accProfIds];
        
        zipMgmtMap = AccountProfileTriggerHandler.getZipMgmtMap(accProfs);
        AccountProfileTriggerHandler.deleteExistingApexSharing(accProfs, zipMgmtMap);
        AccountProfileTriggerHandler.insertAccProfShares(accProfs, zipMgmtMap);
    }

    public static void updateOpportunitySharing(List<Id> oppIds){
        
        List<Opportunity> opps = new List<Opportunity>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        opps = [SELECT Id, Account.ShippingPostalCode, Account.BillingPostalCode, OwnerId FROM Opportunity WHERE Id IN: oppIds];
        zipMgmtMap = OpportunityTriggerHandler.getZipMgmtMap(opps);
        /OpportunityTriggerHandler.deleteExistingApexSharing(opps, zipMgmtMap);
        OpportunityTriggerHandler.insertOppShares(opps, zipMgmtMap);
    }

    public static void updateLeadSharingRules(List<Id> leadIds){
        List<Lead> leads = new List<Lead>();
        Set<String> leadZips = new Set<String>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        Map<Id, Lead> leadMap = new Map<Id, Lead>();

        leads = [SELECT Id, PostalCode, OwnerId FROM Lead WHERE Id IN: leadIds];

        for(Lead l : leads){
            leadZips.add(l.PostalCode);
            leadMap.put(l.Id, l);
        }
        
        zipMgmtMap = LeadTriggerHandler.getZipMgmtMap(leadZips);
        LeadTriggerHandler.deleteExistingApexSharing(zipMgmtMap, leadMap);
        //LeadTriggerHandler.insertLeadShares(leads, zipMgmtMap);
    }
}