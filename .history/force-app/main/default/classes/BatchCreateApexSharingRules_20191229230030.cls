public with sharing class BatchCreateApexSharingRules implements Database.Batchable<sObject>{

    private final Id zipMgmtUserId;
    
    public BatchCreateApexSharingRules(Id zipUserId) {
        this.zipMgmtUserId = zipUserId;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Brand__c, User__c, Zip_or_Postal_Code__c FROM Zip_Postal_Code_Management__c WHERE User__c =: zipMgmtUserId';
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
            System.debug('zips ' + zips);
            String likeZip = zip + '%';
            System.debug('likeZip ' + likeZip);
            zipsForSoql.add(likeZip);
        }

        accounts = [SELECT Id, ShippingPostalCode, OwnerId FROM Account WHERE ShippingPostalCode LIKE: zipsForSoql];
        opps = [SELECT Id, Account.ShippingPostalCode, Account.OwnerId FROM Opportunity WHERE Account.ShippingPostalCode LIKE: zipsForSoql];
        accProfs = [SELECT Id, Account__r.ShippingPostalCode, Account__r.OwnerId FROM Account_Profile__c WHERE Account__r.ShippingPostalCode LIKE: zipsForSoql];
        leads = [SELECT Id, PostalCode, OwnerId FROM Lead WHERE PostalCode LIKE: zipsForSoql];

        System.debug('accounts ' + accounts);
        if(!accounts.isEmpty()){
            for(Account acc : accounts){
                System.debug('acc shipping postal code ' + acc.ShippingPostalCode);
                accountIds.add(acc.Id);
            }
        }

        System.debug('accountIds ' + accountIds.size());
        if(!accountIds.isEmpty()){
            updateAccountSharing(accountIds); 
        }

        if(!opps.isEmpty()){    
            for(Opportunity opp : opps){
                oppIds.add(opp.Id);
            }
        }

        System.debug('oppIds ' + oppIds.size());
        if(!oppIds.isEmpty()){    
            updateOpportunitySharing(oppIds);
        }

        if(!accProfs.isEmpty()){
            for(Account_Profile__c ap : accProfs){
                accProfIds.add(ap.Id);
            }
        }

        System.debug('accProfIds ' + accProfIds.size());
        if(!accProfIds.isEmpty()){
            updateAccountProfileSharing(accProfIds);
        }

        if(!leads.isEmpty()){
            for(Lead l : leads){
                leadIds.add(l.Id);
            }
        }

        System.debug('leadIds ' + leadIds.size());
        if(!leadIds.isEmpty()){
            updateLeadSharingRules(leadIds);
        }
    }

    public void finish(Database.BatchableContext BC){

    }

    public static Map<String, Zip_Postal_Code_Management__c> getZipMgmtMap(Set<String> zipMgmtPostalCodeSet){
        
        List<Zip_Postal_Code_Management__c> zipList = [SELECT Zip_or_Postal_Code__c, Brand__c, User__c FROM Zip_Postal_Code_Management__c WHERE Zip_or_Postal_Code__c IN: zipMgmtPostalCodeSet];
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        
        for(Zip_Postal_Code_Management__c zip : zipList){
            zipMgmtMap.put(zip.Zip_or_Postal_Code__c, zip);
        }

        return zipMgmtMap;
    }

    public static Map<String, Zip_Postal_Code_Management__c> getZipMgmtMap(List<Account_Profile__c> apList){
        System.debug('In getZipMgmtMap methods');
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        List<String> acctZips = new List<String>();
        List<Zip_Postal_Code_Management__c> zipList = new List<Zip_Postal_Code_Management__c>();

        for(Account_Profile__c ap : apList){
            String formatZip = formatZip(ap.Account__r.ShippingPostalCode);
            acctZips.add(formatZip);
        }

        System.debug('acctZips ' + acctZips);

        zipList = [SELECT Zip_or_Postal_Code__c, Brand__c, User__c, User__r.Id, User__r.IsActive FROM Zip_Postal_Code_Management__c WHERE Zip_or_Postal_Code__c IN: acctZips];

        System.debug('zipList ' + zipList);

        for(Zip_Postal_Code_Management__c zip : zipList){
            zipMgmtMap.put(zip.Zip_or_Postal_Code__c, zip);
        }
        System.debug('zipMgmtMap ' + zipMgmtMap);
        return zipMgmtMap;
    }

    public static void updateAccountSharing(List<Id> accountIds){
        System.debug('In updateAccountSharing method' + accountIds.size());
        List<Account> accounts = new List<Account>();
        Set<String> accountZips = new Set<String>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        accounts = [SELECT Id, ShippingPostalCode, OwnerId FROM Account WHERE Id IN: accountIds];

        for(Account acc : accounts){
            accountZips.add(acc.ShippingPostalCode);
        }
        
        zipMgmtMap = getZipMgmtMap(accountZips);

        AccountUtils.deleteExistingApexSharing(accounts, zipMgmtMap);
        insertAccountShares(accounts, zipMgmtMap);
    }

    public static String formatZip(String rawZip){
        String formattedZip;

        if(rawZip != null){         
            if(rawZip.length() == 5 || rawZip.length() == 7){
                System.debug('Regular Zip Code ' + rawZip);
                formattedZip = rawZip;
                System.debug('Formatted Zip Code ' + formattedZip);
            } else if( rawZip.length() > 5){
                formattedZip = rawZip.substring(0, 5);
                System.debug('Formatted Zip Code ' + formattedZip);
            }
        }   
        return formattedZip;
    }

    public static void updateAccountProfileSharing(List<Id> accProfIds){
        System.debug('In updateAccountProfileSharing method ' + accProfIds.size());
        List<Account_Profile__c> accProfs = new List<Account_Profile__c>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        accProfs = [SELECT Id, Account__r.ShippingPostalCode, Brand2__c, OwnerId FROM Account_Profile__c WHERE Id IN: accProfIds];
        System.debug('accProfs ' + accProfs);
        zipMgmtMap = getZipMgmtMap(accProfs);
        deleteExistingApexSharing(accProfs, zipMgmtMap);
        insertAccProfShares(accProfs, zipMgmtMap);
    }

    public static void updateOpportunitySharing(List<Id> oppIds){
        System.debug('In updateOpportunitySharing method ' + oppIds.size());
        List<Opportunity> opps = new List<Opportunity>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        opps = [SELECT Id, Account.ShippingPostalCode, OwnerId FROM Opportunity WHERE Id IN: oppIds];
        zipMgmtMap = getZipMgmtMap(opps);
        deleteExistingApexSharing(opps, zipMgmtMap);
        insertOppShares(opps, zipMgmtMap);
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
        
        zipMgmtMap = getZipMgmtMap(leadZips);

        
        zipMgmtMap = getZipMgmtMap(leadZips);
        deleteExistingApexSharing(zipMgmtMap, leadMap);
        insertLeadShares(leads, zipMgmtMap);
    }
}
