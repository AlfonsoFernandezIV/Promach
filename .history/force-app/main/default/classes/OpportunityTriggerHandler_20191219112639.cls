public without sharing class OpportunityTriggerHandler {

    public static void insertOppSharingRules(Map<Id, Opportunity> oppMap){
        System.debug('In insertOppSharingRules');
        List<Id> accountIdList = new List<Id>();
        List<String> accountZips = new List<String>();
        List<Opportunity> opps = new List<Opportunity>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        opps = [SELECT Id, AccountId, Account.ShippingPostalCode, OwnerId FROM Opportunity WHERE Id IN: oppMap.keySet() AND Brand2__c = 'IDT'];
        System.debug('opps ' + opps);

        for(Opportunity opp : opps){
            accountIdList.add(opp.AccountId);
            accountZips.add(opp.Account.ShippingPostalCode);
        }

        zipMgmtMap  = getZipMgmtMap(opps);
        insertOppShares(opps, zipMgmtMap);
    }
    
   /*  public static void createSharingRules(Map<Id, Opportunity> oppMap, Map<Id, Opportunity> oldOppMap, Boolean isInsert, Boolean isUpdate){
        System.debug('In Opportunity createSharingRules method');
        Map<Id, Account> accountMap = new Map<Id, Account>();

        if(isInsert){
            accountMap = getOppAccountIds(oppMap);
            AccountUtils.createAccountSharing(accountMap);
        }
        if(isUpdate){
            for(Opportunity opp : oppMap.values()){
                Opportunity oldOpp = oldOppMap.get(opp.Id);
                if( opp.OwnerId != oldOpp.OwnerId || opp.AccountId != oldOpp.AccountId){
                    accountMap = getOppAccountIds(oppMap);
                    AccountUtils.createAccountSharing(accountMap);
                }
            }
        }
    } */

    public static Map<String, Zip_Postal_Code_Management__c> getZipMgmtMap(List<Opportunity> opps){
        System.debug('In getZipMgmtMap methods');
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        List<String> acctZips = new List<String>();
        List<Zip_Postal_Code_Management__c> zipList = new List<Zip_Postal_Code_Management__c>();

        for(Opportunity opp : opps){
            String formatZip = formatZip(opp.Account.ShippingPostalCode);
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

    /* public static Map<Id, Account> getOppAccountIds(Map<Id, Opportunity> oppMap){
        System.debug('In getConAccountIds method');
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Account> accountMap = new Map<Id, Account>();

        for(Opportunity opp : oppMap.values()){
            accountIds.add(opp.AccountId);
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
    } */

    public static void insertOppShares(List<Opportunity> opps, Map<String, Zip_Postal_Code_Management__c> zipMgmtMap){
        System.debug('In insertOppShares ' + opps.size());
        List<ContactShare> contactShares = new List<ContactShare>();

        for(Opportunity opp : opps){
            String rawZip = con.Account.ShippingPostalCode;
            String formatZip = formatZip(rawZip);
            //if(zipMgmtMap.get(formatZip).User__c != con.OwnerId){
                OpportunityShare oppShare = new OpportunityShare();     // Instantiate the sharing objects
                oppShare.OpportunityId = opp.Id;    // Set the ID of record being shared
                oppShare.UserOrGroupId = zipMgmtMap.get(zip).User__c;   // Set the ID of user or group being granted access
                oppShare.OpportunityAccessLevel = 'Read';    // Set the access level
                oppShare.RowCause = Schema.OpportunityShare.RowCause.Manual;    // Set the Apex sharing reason for hiring manager and recruiter
                opportunityMap.put(opp.Id, opp);
                oppShares.add(oppShare);    // Add objects to list for insert
            //}
        }
        System.debug('contactShares ' + contactShares);
        insert contactShares;
    }
}
