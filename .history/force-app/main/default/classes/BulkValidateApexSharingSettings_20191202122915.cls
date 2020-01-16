global class BulkValidateApexSharingSettings implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, ShippingPostalCode FROM Account';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Account> accounts = scope;
        List<ContactShare> contactShares = new List<ContactShare>();
        List<OpportunityShare> oppShares = new List<OpportunityShare>();
        List<Account_Profile__Share> accProfileShares = new List<Account_Profile__Share>();
        List<AccountShare> accountShares = new List<AccountShare>();        // Create a list of Job__Share objects to be inserted.
        List<AccountShare> oldAcctShares = new List<AccountShare>();
        Map<Id, AccountShare> accShareMap = new Map<Id, AccountShare>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        Set<String> accZipSet = new Set<String>();
        Set<Id> accZipUpdatedSet = new Set<Id>();

        oldAcctShares = getOldAcctShares();
        accZipSet = getAccZipSet(accounts);
        zipMgmtMap = getZipMgmtMap(accZipSet);
        accShareMap = getAccShareMap(accounts);

        for(Account acc : accounts){
            if(zipMgmtMap.containsKey(acc.ShippingPostalCode) && (accShareMap.get(acc.Id).UserOrGroupId != zipMgmtMap.get(acc.ShippingPostalCode).User__c)){
                AccountShare accShare = new AccountShare();     // Instantiate the sharing objects
                accShare.AccountId = acc.Id;                // Set the ID of record being shared
                accShare.UserOrGroupId = zipMgmtMap.get(acc.ShippingPostalCode).User__c;       // Set the ID of user or group being granted access
                accShare.AccountAccessLevel = 'Edit';        // Set the access level
                accShare.OpportunityAccessLevel = 'Edit';
                accShare.ContactAccessLevel = 'Edit';
                accShare.RowCause = Schema.AccountShare.RowCause.Manual; // Set the Apex sharing reason for hiring manager and recruiter
                accountShares.add(accShare);                // Add objects to list for insert
                accZipUpdatedSet.add(acc.Id);               // Get new set of ids to query Contacts, Opps, and Account Profiles
            }
        }

        accProfileShares = getAccountProfileList(accZipUpdatedSet, zipMgmtMap);
        contactShares = getContactList(accZipUpdatedSet, zipMgmtMap);
        oppShares = getOpportunityList(accZipUpdatedSet, zipMgmtMap);

        if(!accProfileShares.isEmpty()){
            upsert accProfileShares;
        }
        if(!contactShares.isEmpty()){
            upsert contactShares;
        }
        if(!oppShares.isEmpty()){
            upsert oppShares;
        }
    }
    
    global void finish(Database.BatchableContext BC){

    }

    /* global static void getOldAcctShares(){
        List<AccountShare> oldAcctShare = new List<AccountShare>();
        oldAcctShare = [SELECT Id FROM AccountShare WHERE ParentId IN: ];
    } */

    global static Set<String> getAccZipSet(List<Account> accounts){

        Set<String> accZipSet = new Set<String>();

        for(Account a : accounts){
            if(a.ShippingPostalCode != null){
                accZipSet.add(a.ShippingPostalCode);
            }
        }
        return accZipSet;
    }

    global static Map<String, Zip_Postal_Code_Management__c> getZipMgmtMap(Set<String> accZipSet){
        System.debug('In getZipMgmtMap methods');
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        List<Zip_Postal_Code_Management__c> zipList = [SELECT Zip_or_Postal_Code__c, Brand__c, User__c FROM Zip_Postal_Code_Management__c WHERE Zip_or_Postal_Code__c IN: accZipSet];
        
        System.debug('All Zip List size ' + zipList.size());
        for(Zip_Postal_Code_Management__c zip : zipList){
            zipMgmtMap.put(zip.Zip_or_Postal_Code__c, zip);
        }
        System.debug('IDT Zip Map size ' + zipMgmtMap.keySet().size());
        return zipMgmtMap;
    }

    global static Map<Id, AccountShare> getAccShareMap(List<Account> accounts){
        
        List<AccountShare> accShareList = new List<AccountShare>();
        Map<Id, AccountShare> accShareMap = new Map<Id, AccountShare>();
        Set<Id> accIdSet = new Set<Id>();

        accIdSet = getAccIdSet(accounts);
        accShareList = getAccShareList(accIdSet);
        accShareMap = getAccShareMap(accIdSet, accShareList);
        
        return accShareMap;
    }

    global static Set<Id> getAccIdSet(List<Account> accounts){
        Set<Id> accIdSet = new Set<Id>();

        for(Account a : accounts){
            accIdSet.add(a.Id);
        }

        return accIdSet;
    }

    global static List<AccountShare> getAccShareList(Set<Id> accIdSet){
        
        List<AccountShare> accShareList = [SELECT AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN: accIdSet];
        return accShareList;
    }

    global static Map<Id, AccountShare> getAccShareMap(Set<Id> accIdSet, List<AccountShare> accShareList){

        Map<Id, AccountShare> accShareMap = new Map<Id, AccountShare>();
        
        for(Id i : accIdSet){
            for(AccountShare share : accShareList){
                if(share.AccountId == i){
                    accShareMap.put(share.AccountId, share);
                }
            }
        }
        return accShareMap;
    }

    global static List<Account_Profile__Share> getAccountProfileList(Set<Id> accZipUpdatedSet, Map<String, Zip_Postal_Code_Management__c> zipMgmtMap){

        List<Account_Profile__c> accProfiles = [SELECT Id, Account__r.ShippingPostalCode FROM Account_Profile__c WHERE Account__c IN: accZipUpdatedSet];
        List<Account_Profile__Share> accProfileShares = new List<Account_Profile__Share>();

        for(Account_Profile__c ap : accProfiles){
            if(zipMgmtMap.containsKey(ap.Account__r.ShippingPostalCode)){
                Account_Profile__Share acctProfileShare = new Account_Profile__Share();     // Instantiate the sharing objects
                acctProfileShare.ParentId = ap.Id;  // Set the ID of record being shared
                acctProfileShare.UserOrGroupId = zipMgmtMap.get(ap.Account__r.ShippingPostalCode).User__c;    // Set the ID of user or group being granted access
                acctProfileShare.AccessLevel = 'Edit';   // Set the access level
                acctProfileShare.RowCause = Schema.Account_Profile__Share.RowCause.ID_Technology__c;    // Set the Apex sharing reason for hiring manager and recruiter
                accProfileShares.add(acctProfileShare);     // Add objects to list for insert
            }
        }

        return accProfileShares;
    }

    global static List<ContactShare> getContactList(Set<Id> accZipUpdatedSet, Map<String, Zip_Postal_Code_Management__c> zipMgmtMap){

        List<Contact> contacts = [SELECT Id, Account.ShippingPostalCode FROM Contact WHERE AccountId IN: accZipUpdatedSet];
        List<ContactShare> contactShares = new List<ContactShare>();

        for(Contact con : contacts){
            if(zipMgmtMap.containsKey(con.Account.ShippingPostalCode)){
                ContactShare conShare = new ContactShare();     // Instantiate the sharing objects
                conShare.ContactId = con.Id;                // Set the ID of record being shared
                conShare.UserOrGroupId = zipMgmtMap.get(con.Account.ShippingPostalCode).User__c;       // Set the ID of user or group being granted access
                conShare.ContactAccessLevel = 'Edit';        // Set the access level
                conShare.RowCause = Schema.ContactShare.RowCause.Manual; // Set the Apex sharing reason for hiring manager and recruiter
                contactShares.add(conShare);                // Add objects to list for insert
            }
        }
        return contactShares;
    }

    global static List<OpportunityShare> getOpportunityList(Set<Id> accZipUpdatedSet, Map<String, Zip_Postal_Code_Management__c> zipMgmtMap){

        List<Opportunity> opportunities = [SELECT Id, Account.ShippingPostalCode FROM Opportunity WHERE AccountId IN: accZipUpdatedSet];
        List<OpportunityShare> oppShares = new List<OpportunityShare>();

        for(Opportunity opp : opportunities){
            if(zipMgmtMap.containsKey(opp.Account.ShippingPostalCode)){
                OpportunityShare oppShare = new OpportunityShare();     // Instantiate the sharing objects
                oppShare.OpportunityId = opp.Id;    // Set the ID of record being shared
                oppShare.UserOrGroupId = zipMgmtMap.get(opp.Account.ShippingPostalCode).User__c;   // Set the ID of user or group being granted access
                oppShare.OpportunityAccessLevel = 'Edit';    // Set the access level
                oppShare.RowCause = Schema.OpportunityShare.RowCause.Manual;    // Set the Apex sharing reason for hiring manager and recruiter
                oppShares.add(oppShare);    // Add objects to list for insert
            }
        }
        return oppShares;
    }
}
