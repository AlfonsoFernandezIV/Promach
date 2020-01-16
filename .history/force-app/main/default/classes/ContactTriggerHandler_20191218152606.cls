public without sharing class ContactTriggerHandler {

    public static void getContactAccountInfo(Map<Id, Contact> contactMap, Map<Id, Contact> oldContactMap, Boolean isInsert){
        System.debug('In getContactAccountInfo method');

        List<Account> accs = new List<Account>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Set<Id> accIds = new Set<Id>();
        
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
            // AccountUtils.createAccountSharing(accountMap);
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
}
