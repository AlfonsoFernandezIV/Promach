public without sharing class AccountProfileTriggerHandler {

    public static void createAcctProfileSharingRules(Map<Id, Account_Profile__c> apMap){
        System.debug('In createAcctProfileSharingRules method ');
        List<Account_Profile__c> apList = new List<Account_Profile__c>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        apList = [SELECT Id, Account__c, Account__r.ShippingPostalCode, Brand2__c, OwnerId FROM Account_Profile__c WHERE Id IN: apMap.keySet()];
        System.debug('apList ' + apList);

        zipMgmtMap = getZipMgmtMap(apList);
        insertAccProfShares(apList, zipMgmtMap);
    }

    public static void updateAcctProfileSharingRules(Map<Id, Account_Profile__c> apMap, Map<Id, Account_Profile__c> oldApMap){
        System.debug('In updateAcctProfileSharingRules method ');
        List<Id> accountIdList = new List<Id>();
        List<String> accountZips = new List<String>();
        List<Account_Profile__c> apList = new List<Account_Profile__c>();
        List<Account_Profile__c> apUpdateList = new List<Account_Profile__c>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        apList = [SELECT Id, Account__c, Account__r.ShippingPostalCode, Brand2__c, OwnerId FROM Account_Profile__c WHERE Id IN: apMap.keySet()];

        for(Account_Profile__c ap : apList){
            Account_Profile__c oldAp = oldApMap.get(ap.Id);
            if(ap.Account__c != oldAp.Account__c){
                accountIdList.add(ap.Account__c);
                accountZips.add(ap.Account__r.ShippingPostalCode);
                apUpdateList.add(ap);
            }
        }
        insertAccProfShares(apUpdateList, zipMgmtMap);
    }

    /* public static void createSharingRules(Map<Id, Account_Profile__c> accProfileMap, Map<Id, Account_Profile__c> oldAccProfileMap, Boolean isInsert, Boolean isUpdate){
        System.debug('In createSharingRules method');
        Map<Id, Account> accountMap = new Map<Id, Account>();

        if(isInsert){
            accountMap = getAccProfileAccountIds(accProfileMap);
            AccountUtils.createAccountSharing(accountMap);
        }
        if(isUpdate){
            for(Account_Profile__c ap : accProfileMap.values()){
                Account_Profile__c oldAP = oldAccProfileMap.get(ap.Id);
                if(ap.OwnerId != oldAP.OwnerId || ap.AccountId__c != oldAP.AccountId__c){
                    accountMap = getAccProfileAccountIds(accProfileMap);
                    AccountUtils.createAccountSharing(accountMap);
                }
            }
        }
    } */

    public static Map<String, Zip_Postal_Code_Management__c> getZipMgmtMap(List<Account_Profile__c> apList){
        System.debug('In getZipMgmtMap methods');
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        List<String> acctZips = new List<String>();
        List<Zip_Postal_Code_Management__c> zipList = new List<Zip_Postal_Code_Management__c>();

        for(Account_Profile__c ap : apList){
            String formatZip = formatZip(ap.Account__r.ShippingPostalCode);
            acctZips.add(formatZip);
        }

        zipList = [SELECT Zip_or_Postal_Code__c, Brand__c, User__c, User__r.Id FROM Zip_Postal_Code_Management__c WHERE Zip_or_Postal_Code__c IN: acctZips];

        for(Zip_Postal_Code_Management__c zip : zipList){
            zipMgmtMap.put(zip.Zip_or_Postal_Code__c, zip);
        }
        System.debug('zipMgmtMap ' + zipMgmtMap);
        return zipMgmtMap;
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

    /* public static Map<Id, Account> getAccProfileAccountIds(Map<Id, Account_Profile__c> accProfileMap){
        System.debug('In getAccProfileAccountIds method' + accProfileMap);
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Account> accountMap = new Map<Id, Account>();

        for(Account_Profile__c ap : accProfileMap.values()){
            accountIds.add(ap.Account__c);
        }
        System.debug('accountIds ' + accountIds);
        accountMap = getAccountMap(accountIds);
        return accountMap;
     }

     public static Map<Id, Account> getAccountMap(Set<Id> accountIds){
        System.debug('In getAccountMap method');
        List<Account> accountList = new List<Account>();
        Map<Id, Account> accountMap = new Map<Id, Account>();

        accountList = [SELECT Id, OwnerId, ShippingPostalCode FROM Account WHERE Id IN: accountIds];

        for(Account acc : accountList){
            accountMap.put(acc.Id, acc);
        }
        System.debug('accountMap ' + accountMap);
        return accountMap;
    } */

    public static void insertAccProfShares(List<Account_Profile__c> apUpdateList, Map<String, Zip_Postal_Code_Management__c> zipMgmtMap){
        System.debug('In insertAccProfShares ');
        List<Account_Profile__Share> apShares = new List<Account_Profile__Share>();

        for(Account_Profile__c ap : apUpdateList){
            String rawZip = ap.Account__r.ShippingPostalCode;
            String formatZip = formatZip(rawZip);
            if(ap.Brand2__c == 'IDT'){
                Account_Profile__Share acctProfileShare = new Account_Profile__Share();
                acctProfileShare.ParentId = ap.Id;  // Set the ID of record being shared
                acctProfileShare.UserOrGroupId = zipMgmtMap.get(formatZip).User__c;    // Set the ID of user or group being granted access
                acctProfileShare.AccessLevel = 'Edit';   // Set the access level
                acctProfileShare.RowCause = Schema.Account_Profile__Share.RowCause.Manual;    // Set the Apex sharing reason for hiring manager and recruiter
                apShares.add(acctProfileShare);
            } else {
                Account_Profile__Share acctProfileShare = new Account_Profile__Share();
                acctProfileShare.ParentId = ap.Id;  // Set the ID of record being shared
                acctProfileShare.UserOrGroupId = zipMgmtMap.get(formatZip).User__c;    // Set the ID of user or group being granted access
                acctProfileShare.AccessLevel = 'Read';   // Set the access level
                acctProfileShare.RowCause = Schema.Account_Profile__Share.RowCause.Manual;    // Set the Apex sharing reason for hiring manager and recruiter
                apShares.add(acctProfileShare);
            }
        }
        System.debug('apShares ' + apShares);
        insert apShares;
    }
}
