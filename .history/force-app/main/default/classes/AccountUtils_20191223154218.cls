public without sharing class AccountUtils {
    
    public static void createAccountShares(Map<Id, Account> accountMap){
        System.debug('In createAccountShares method ');

        Set<String> accountZips = new Set<String>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        for(Account acc : accountMap.values()){
            accountZips.add(acc.ShippingPostalCode);
        }

        zipMgmtMap = getZipMgmtMap(accountZips);
        insertAccountShares(accountMap.values(), zipMgmtMap);
    }
    
    public static void updateAccountShares(Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap){
        List<Account> changedAccounts = new List<Account>();
        List<Opportunity> accountOpps = new List<Opportunity>();
        List<Account_Profile__c> accountAcctProfs = new List<Account_Profile__c>(); 
        Map<Id, Account> insertAccountMap = new Map<Id, Account>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        Map<Id, Opportunity> accountOppMap = new Map<Id, Opportunity>();
        Map<Id, Account_Profile__c> accountAcctProfMap = new Map<Id, Account_Profile__c>();
        Set<String> accPostalCodeSet = new Set<String>();

        accountAcctProfs = [SELECT Id, Account__c, Account__r.ShippingPostalCode, Brand2__c, OwnerId FROM Account_Profile__c WHERE Account__c IN: newAccountMap.values()];
        accountOpps = [SELECT Id, AccountId FROM Opportunity WHERE AccountId IN: newAccountMap.values()];

        System.debug('accounts ' + newAccountMap.values());
        System.debug('accountAcctProfs ' + accountAcctProfs);
        System.debug('accountOpps ' + accountOpps);

        for(Account_Profile__c ap : accountAcctProfs){
            Account newAccount = newAccountMap.get(ap.Account__c);
            Account oldAccount = oldAccountMap.get(ap.Account__c);
            if(newAccount.ShippingPostalCode != oldAccount.ShippingPostalCode){
                accountAcctProfMap.put(ap.Id, ap);
            }
        }

        for(Opportunity opp : accountOpps){
            Account newAccount = newAccountMap.get(opp.AccountId);
            Account oldAccount = oldAccountMap.get(opp.AccountId);
            if(newAccount.ShippingPostalCode != oldAccount.ShippingPostalCode){
                accountOppMap.put(opp.Id, opp);
            }
        }

        for(Account acc : newAccountMap.values()){
            Account oldAccount = oldAccountMap.get(acc.Id);
            String newZip = formatZip(acc.ShippingPostalCode);
            String oldZip = formatZip(oldAccount.ShippingPostalCode);
            if (acc.OwnerId != oldAccount.OwnerId || newZip != oldZip){
                if(acc.ShippingPostalCode!= null){
                    accPostalCodeSet.add(acc.ShippingPostalCode);
                    changedAccounts.add(acc);
                } else {
                    accPostalCodeSet.add(acc.BillingPostalCode);
                }
            }
        }
        
        zipMgmtMap = getZipMgmtMap(accPostalCodeSet);

        if(!changedAccounts.isEmpty()){
            if(!accountAcctProfs.isEmpty()){
                AccountProfileTriggerHandler.updateSharingFromAccount(accountAcctProfMap.values(), zipMgmtMap);
            }

            if(!accountOppMap.isEmpty()){
                update accountOppMap.values();
            }

            deleteExistingApexSharing(changedAccounts, zipMgmtMap);
            insertAccountShares(changedAccounts, zipMgmtMap);
        }
    }

    public static String formatZip(String rawZip){
        String formattedZip;

        if(rawZip != null){         
            if(rawZip.length() == 5 || rawZip.length() == 7){
                System.debug('3333 Regular Zip Code ' + rawZip);
                formattedZip = rawZip;
                System.debug('3333 Formatted Zip Code ' + formattedZip);
            } else if( rawZip.length() > 5){
                formattedZip = rawZip.substring(0, 5);
                System.debug('3333 Formatted Zip Code ' + formattedZip);
            }
        }
        
        return formattedZip;
    }

    public static Map<String, Zip_Postal_Code_Management__c> getZipMgmtMap(Set<String> accPostalCodeSet){
        System.debug('6666 In getZipMgmtMap methods');
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        List<Zip_Postal_Code_Management__c> zipList = new List<Zip_Postal_Code_Management__c>();

        System.debug('accPostalCodeSet ' + accPostalCodeSet);
        zipList = [SELECT Zip_or_Postal_Code__c, Brand__c, User__c, User__r.Id FROM Zip_Postal_Code_Management__c WHERE Zip_or_Postal_Code__c IN: accPostalCodeSet];
        
        for(Zip_Postal_Code_Management__c zip : zipList){
            zipMgmtMap.put(zip.Zip_or_Postal_Code__c, zip);
        }
        System.debug('6666 zipMgmtMap ' + zipMgmtMap);
        return zipMgmtMap;
    }

    public static void deleteExistingApexSharing(List<Account> accounts, Map<String, Zip_Postal_Code_Management__c> zipMgmtMap){
        System.debug('In deleteExistingApexSharing method');

        List<Id> accIds = new List<Id>();
        List<AccountShare> accShares = new List<AccountShare>();
        Set<AccountShare> deleteAccShareSet = new Set<AccountShare>();
        List<AccountShare> deleteAccShares = new List<AccountShare>();

        for(Account acc : accounts){
            accIds.add(acc.Id);
        }

        accShares = [SELECT Id, UserOrGroupId FROM AccountShare WHERE AccountId IN: accIds AND RowCause = 'Manual' AND IsDeleted = false];
        
        for(Account acc : accounts){
            String formatZip = formatZip(acc.ShippingPostalCode);
            if(!accShares.isEmpty()){
                for(AccountShare accShare : accShares){
                    if(accShare.UserOrGroupId != zipMgmtMap.get(formatZip).User__c){
                        deleteAccShareSet.add(accShare);
                    }
                }
            }
        }
        
        deleteAccShares.addAll(deleteAccShareSet);
        
        System.debug('Delect Acc Shares ' + deleteAccShares);
        if(!deleteAccShares.isEmpty()){
            delete deleteAccShares;
        }
    }

    public static void insertAccountShares(List<Account> accounts, Map<String, Zip_Postal_Code_Management__c> zipMgmtMap){
        System.debug('In insertAccountShares method');
        List<AccountShare> accountShares = new List<AccountShare>();

        for(Account acc : accounts){
            String formatZip = formatZip(acc.ShippingPostalCode);
            if(zipMgmtMap.get(formatZip).User__c != acc.OwnerId){
                AccountShare accShare = new AccountShare();     // Instantiate the sharing objects
                accShare.AccountId = acc.Id;                // Set the ID of record being shared
                accShare.UserOrGroupId = zipMgmtMap.get(formatZip).User__c;       // Set the ID of user or group being granted access
                accShare.AccountAccessLevel = 'Edit';        // Set the access level
                accShare.OpportunityAccessLevel = 'None';
                accShare.ContactAccessLevel = 'Edit';
                accShare.RowCause = Schema.AccountShare.RowCause.Manual; // Set the Apex sharing reason for hiring manager and recruiter
                accountShares.add(accShare);                // Add objects to list for insert
            }
        }

        System.debug('accountShares ' + accountShares);
        insert accountShares;
    }
}