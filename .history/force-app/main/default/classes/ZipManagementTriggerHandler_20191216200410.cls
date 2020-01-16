public without sharing class ZipManagementTriggerHandler {

    public static void handleZipUserChange(Map<Id,Zip_Postal_Code_Management__c> newZipMap, Map<Id,Zip_Postal_Code_Management__c> oldZipMap){
        System.debug('In handleZipUserChange method');
        List<String> zipPostalCodes = new List<String>();
        Map<Id, Zip_Postal_Code_Management__c> userChangedZipMap = new Map<Id, Zip_Postal_Code_Management__c>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        Map<Id, Lead> leadMap = new Map<Id, Lead>();

        userChangedZipMap = getUserChangedZipMap(newZipMap, oldZipMap);
        zipPostalCodes = getZipPostalCodes(userChangedZipMap);
        accountMap = getAccountMap(zipPostalCodes);
        // leadMap = getLeadList(zipPostalCodes);

        if(!accountMap.isEmpty()){
            AccountUtils.createAccountSharing(accountMap);
        } 
       /*  if(!leadMap.values().isEmpty()){
            System.debug('Lead Map Values ' + leadMap.values());
            update leadMap.values();
        } */
        
    }

    public static Map<Id, Zip_Postal_Code_Management__c> getUserChangedZipMap(Map<Id,Zip_Postal_Code_Management__c> newZipMap, Map<Id,Zip_Postal_Code_Management__c> oldZipMap){
        System.debug('In getUserChangedZipMap method');
        Map<Id, Zip_Postal_Code_Management__c> userChangedZipMap = new Map<Id, Zip_Postal_Code_Management__c>();

        for(Zip_Postal_Code_Management__c zip : newZipMap.values()){
            System.debug('New Zip User ' + zip.User__c);
            System.debug('Old Zip User ' + oldZipMap.get(zip.id).User__c);
            if(zip.User__c != oldZipMap.get(zip.id).User__c){
                userChangedZipMap.put(zip.Id, zip);
            }
        }
        System.debug('UserChangedZipMap Size ' + userChangedZipMap.values().size());
        return userChangedZipMap;
    }

    public static List<String> getZipPostalCodes(Map<Id, Zip_Postal_Code_Management__c> userChangedZipMap){
        System.debug('In getZipPostalCodes method');
        List<String> zipPostalCodes = new List<String>();
        Set<String> zipPostalCodeSet = new Set<String>();
        String rawZip;
        
        for(Zip_Postal_Code_Management__c zip : userChangedZipMap.values()){
            String formattedZip;
            rawZip = zip.Zip_or_Postal_Code__c;

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
            zipPostalCodeSet.add(formattedZip);
        }

        for(String zip : zipPostalCodeSet){
            zipPostalCodes.add(zip);
        }

        System.debug('zipPostalCodeSet ' + zipPostalCodeSet);
        System.debug('zipPostalCodes ' + zipPostalCodes);
        return zipPostalCodes;
    }

    public static Map<Id, Account> getAccountMap(List<String> zipPostalCodes){
        System.debug('5555 In getAccountMap method ' + zipPostalCodes);
        String zip;
        
        if(!zipPostalCodes.isEmpty()){
            zip = zipPostalCodes[0] + '*';
        }
        
        System.debug('5555 zip ' + zip);

        List<Account> searchAccounts = [SELECT Id, ShippingPostalCode, OwnerId FROM Account WHERE ShippingPostalCode =: zip];
        if(!searchAccounts.isEmpty()){
            for(Account acc : searchAccounts){
                accountMap.put(acc.Id, acc);
            }
        }
        System.debug('5555 Account map size ' + accountMap.size());
        System.debug('5555 Account Map ' + accountMap);

        List<Lead> searchLeads = [SELECT Id, Brand_Interest__c, PostalCode, OwnerId FROM LEAD WHERE Brand_Interest__c = 'IDT' AND isConverted = false];
        // List<List<sObject>> searchList = [FIND: zip IN ALL FIELDS RETURNING Account(Id, ShippingPostalCode, OwnerId), Lead(Id, Brand_Interest__c, PostalCode, OwnerId WHERE Brand_Interest__c = 'IDT' AND isConverted = false)];
        System.debug('5555 searchList ' + searchAccounts);
        /* List<Account> accs = (List<Account>)searchList[0];
        List<Lead> leads = (List<Lead>)searchList[1] ;*/
        Map<Id, Account> accountMap = new Map<Id, Account>();
        System.debug('5555 Account list size ' + searchAccounts.size());

        
        try{
            update searchLeads;
        } catch(NullPointerException npe){
            System.debug('No Leads returned ');
        }
        return accountMap;
    }

    /* public static Map<Id, Lead> getLeadList(List<String> zipPostalCodes){
        System.debug('6666 In getLeadList method ' + zipPostalCodes);
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        String zip;

        if(!zipPostalCodes.isEmpty()){
            zip = zipPostalCodes[0];
        }

        System.debug('6666 zip ' + zip);

        List<Lead> allLeads = [SELECT Id, PostalCode FROM Lead];
        System.debug('allLeads count ' + allLeads.size());
        System.debug('allLeads ' + allLeads);

        List<List<sObject>> searchList = [FIND: zip IN ALL FIELDS RETURNING Lead(Id, Brand_Interest__c, PostalCode, OwnerId WHERE Brand_Interest__c = 'IDT' AND isConverted = false)];
        System.debug('6666 searchList ' + searchList);
        List<Lead> leads = (List<Lead>) searchList[0];
        
        if(!leads.isEmpty()){
            for(Lead l : leads){
                leadMap.put(l.Id, l);
            }
        }
        System.debug('6666 leads ' + leadMap);
        return leadMap;
    } */
}