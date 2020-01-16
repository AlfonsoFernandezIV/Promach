public without sharing class AccountUtils {
    // TODO if owner change or if zip

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
        Map<Id, Account> changedAccountMap = new Map<Id, Account>();
        Map<Id, Account> insertAccountMap = new Map<Id, Account>();

        List<Account> accounts = [SELECT Id, ShippingPostalCode, OwnerId, (SELECT Id FROM Account_Profiles__r),(SELECT Id FROM Opportunities) FROM Account WHERE Id IN: newAccountMap.keySet()];

        for(Account acc : newAccountMap.values()){
            Account oldAccount = oldAccountMap.get(acc.Id);
            String newZip = formatZip(acc.ShippingPostalCode);
            String oldZip = formatZip(oldAccount.ShippingPostalCode);
            if (acc.OwnerId != oldAccount.OwnerId || newZip != oldZip){
                changedAccountMap.put(acc.Id, acc);
            }
        }
        
        if(!insertAccountMap.keyset().isEmpty()){
            insertAccountSharting(insertAccountMap);
        }

        if(!changedAccountMap.keySet().isEmpty()){
            createAccountSharing(changedAccountMap);
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
        List<Zip_Postal_Code_Management__c> zipList = [SELECT Zip_or_Postal_Code__c, Brand__c, User__c, User__r.Id FROM Zip_Postal_Code_Management__c WHERE Zip_or_Postal_Code__c IN: accPostalCodeSet];
        
        for(Zip_Postal_Code_Management__c zip : zipList){
            zipMgmtMap.put(zip.Zip_or_Postal_Code__c, zip);
        }
        System.debug('6666 zipMgmtMap ' + zipMgmtMap);
        return zipMgmtMap;
    }

    public static void insertAccountShares(List<Account> accounts, Map<String, Zip_Postal_Code_Management__c> zipMgmtMap){
        System.debug('In insertAccountShares method');
        List<AccountShare> accountShares = new List<AccountShare>();

        for(Account acc : accounts){
            String rawZip = acc.ShippingPostalCode;
            String formatZip = formatZip(rawZip);

            AccountShare accShare = new AccountShare();     // Instantiate the sharing objects
            accShare.AccountId = acc.Id;                // Set the ID of record being shared
            accShare.UserOrGroupId = zipMgmtMap.get(formatZip).User__c;       // Set the ID of user or group being granted access
            accShare.AccountAccessLevel = 'Edit';        // Set the access level
            accShare.OpportunityAccessLevel = 'None';
            accShare.ContactAccessLevel = 'Edit';
            accShare.RowCause = Schema.AccountShare.RowCause.Manual; // Set the Apex sharing reason for hiring manager and recruiter
            accountShares.add(accShare);                // Add objects to list for insert
        }
        System.debug('accontShares ' + accountShares);
        insert accountShares;
    }


}