public without sharing class ContactTriggerHandler {

    public static void getContactAccountInfo(Map<Id, Contact> contactMap, Map<Id, Contact> oldContactMap, Boolean isInsert){
        System.debug('In getContactAccountInfo method');

        List<Account> accs = new List<Account>();
        List<Contact> createConShareList = new List<Contact>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Set<Id> accIds = new Set<Id>();
        
        for(Contact con : contactMap.values){
            if(isInsert){
                createConShareList.add(con);
            } else {
                if(con.AccountId != oldCon.AccountId){
                    createConShareList.add(con);
                }
            }
        }


        if(isInsert){
            accountMap = getConAccountIds(contactMap);
            AccountUtils.createAccountSharing(accountMap);
        } else {
            for(Contact con : contactMap.values()){
                Contact oldCon = oldContactMap.get(con.Id);
                if(con.OwnerId != oldCon.OwnerId || con.AccountId != oldCon.AccountId){
                    accountMap = getConAccountIds(contactMap);
                }
            }
            /* AccountUtils.createAccountSharing(accountMap); */
        }
    }
    
    public static Map<Id, Account> getConAccountIds(Map<Id, Contact> contactMap){
        System.debug('In getConAccountIds method');
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Account> accountMap = new Map<Id, Account>();

        for(Contact con : contactMap.values()){
            accountIds.add(con.AccountId);
        }

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

        return accountMap;
    }

    public static void insertContactShares(){
        if(contactsMap.containsKey(acc.Id)){
            System.debug('1111 In Contact Sharing');
            for(Contact con : contactsMap.get(acc.Id)){
                if(zipMgmtMap.get(zip).User__c != con.OwnerId){
                    ContactShare conShare = new ContactShare();     // Instantiate the sharing objects
                    conShare.ContactId = con.Id;                // Set the ID of record being shared
                    conShare.UserOrGroupId = zipMgmtMap.get(zip).User__c;       // Set the ID of user or group being granted access
                    conShare.ContactAccessLevel = 'Edit';        // Set the access level
                    conShare.RowCause = Schema.ContactShare.RowCause.Manual; // Set the Apex sharing reason for hiring manager and recruiter
                    contactMap.put(con.Id, con);
                    contactShares.add(conShare);                // Add objects to list for insert
                }
            }
        } 
    }
}
