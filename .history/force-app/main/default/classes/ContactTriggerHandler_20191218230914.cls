public without sharing class ContactTriggerHandler {

    public static void getContactAccountInfo(Map<Id, Contact> contactMap, Map<Id, Contact> oldContactMap, Boolean isInsert){
        System.debug('In getContactAccountInfo method');

        List<Contact> createConShareList = new List<Contact>();
        List<Id> accountIdList = new List<Id>();
        List<String> accountZips = new List<String>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        List<Contact> contactWithAcctInfo = new List<Contact>([SELECT Id, AccountId, Account.ShippingPostalCode FROM Contact WHERE Id IN: contactMap.keySet()]);
        
        for(Contact con : contactWithAcctInfo){
            if(isInsert){
                createConShareList.add(con);
            } else {
                Contact oldCon = oldContactMap.get(con.Id);
                if(con.AccountId != oldCon.AccountId){
                    createConShareList.add(con);
                }
            }
        }

        accountIdList = getConAccountIds(createConShareList);
        accountZips = getAccountZips(accountIdList);
        zipMgmtMap = getZipMgmtMap(contactWithAcctInfo);
        insertContactShares(createConShareList, zipMgmtMap);
    }
    
    public static List<Id> getConAccountIds(List<Contact> createConShareList){
        System.debug('In getConAccountIds method');
        Set<Id> accountIds = new Set<Id>();
        List<Id> accountIdList = new List<Id>();

        for(Contact con : createConShareList){
            accountIds.add(con.AccountId);
        }

        accountIdList.addAll(accountIds);
        return accountIdList;
    }

    public static List<String> getAccountZips(List<Id> accountIdList){
        System.debug('In getAccountMap method');
        List<String> accountZips = new List<String>();
        Set<String> accountZipSet = new Set<String>();
        List<Account> accountList = new List<Account>([SELECT Id, ShippingPostalCode FROM Account WHERE Id IN: accountIdList]);

        for(Account acc : accountList){
            accountZipSet.add(acc.ShippingPostalCode);
        }

        accountZips.addAll(accountZipSet);
        return accountZips;
    }

    public static Map<String, Zip_Postal_Code_Management__c> getZipMgmtMap(List<Contact> contactWithAcctInfo){
        System.debug('In getZipMgmtMap methods');
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        List<String> acctZips = new List<String>();
        List<Zip_Postal_Code_Management__c> zipList = new List<Zip_Postal_Code_Management__c>();

        for(Contact con : contactWithAcctInfo){
            String rawZip = con.Account.ShippingPostalCode;
            String formatZip = formatZip(rawZip);
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

    public static void insertContactShares(List<Contact> contacts, Map<String, Zip_Postal_Code_Management__c> zipMgmtMap){
        System.debug('In insertContactShares');
        List<ContactShare> contactShares = new List<ContactShare>();

        for(Contact con : contacts){
            String rawZip = con.Account.ShippingPostalCode;
            String formatZip = formatZip(rawZip);
            if(zipMgmtMap.get(formatZip).User__c != con.OwnerId){
                ContactShare conShare = new ContactShare();
                conShare.ContactId = con.Id;
                conShare.UserOrGroupId = zipMgmtMap.get(formatZip).User__c;
                conShare.ContactAccessLevel = 'Edit';
                conShare.RowCause = Schema.ContactShare.RowCause.Manual;
                contactShares.add(conShare);
            }
        }
        insert contactShares;
    }
}
