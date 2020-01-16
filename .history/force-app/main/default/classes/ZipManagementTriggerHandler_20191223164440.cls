public without sharing class ZipManagementTriggerHandler {

    public static void handleZipUserChange(Map<Id,Zip_Postal_Code_Management__c> newZipMap, Map<Id,Zip_Postal_Code_Management__c> oldZipMap){
        System.debug('In handleZipUserChange method');
        Set<String> zipPostalCodes = new Set<String>();

        for(Zip_Postal_Code_Management__c zip : newZipMap.values()){
            Zip_Postal_Code_Management__c oldZip = newZipMap.get(zip.Id);
            if(zip.User__c != oldZip.User__c){
                zipPostalCodes.add(zip.Zip_or_Postal_Code__c);
            }
        }

        getObjectIds(zipPostalCodes);
    }

    public static void getObjectIds(Set<String> zipPostalCodes){
        List<Account> accounts = new List<Account>();
        List<Opportunity> opps = new List<Opportunity>();
        List<Account_Profile__c> accProfs = new List<Account_Profile__c>();
        List<Lead> leads = new List<Lead>();
        List<Id> accountIds = new List<Id>();
        List<Id> accProfIds = new List<Id>();
        List<Id> oppIds = new List<Id>();
        List<Id> leadIds = new List<Id>();

        accounts = [SELECT Id FROM Account WHERE ShippingPostalCode IN: zipPostalCodes];
        opps = [SELECT Id FROM Opportunity WHERE Account.ShippingPostalCode IN: zipPostalCodes];
        accProfs = [SELECT Id FROM Account_Profile__c WHERE Account__r.ShippingPostalCode IN: zipPostalCodes];
        leads = [SELECT Id FROM Lead WHERE PostalCode IN: zipPostalCodes];

        for(Account acc : accounts){
            accountIds.add(acc.ShippingPostalCode);
        }

        for(Opportunity opp : opps){
            oppIds.add(opp.Account.ShippingPostalCode);
        }

        for(Account_Profile__c ap : accProfs){
            accProfIds.add(ap.Account__r.ShippingPostalCode);
        }

        for(Lead l : leads){
            leadIds.add(l.PostalCode);
        }
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
        Map<Id, Account> accountMap = new Map<Id, Account>();
        
        if(!zipPostalCodes.isEmpty()){
            zip = zipPostalCodes[0];
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

        List<Lead> searchLeads = [SELECT Id, Brand_Interest__c, PostalCode, OwnerId FROM LEAD WHERE Product_Category__c != null AND Brand_Interest__c = 'IDT' AND isConverted = false];

        System.debug('5555 searchList ' + searchAccounts);
        System.debug('5555 Account list size ' + searchAccounts.size());

        
        try{
            update searchLeads;
        } catch(NullPointerException npe){
            System.debug('No Leads returned ');
        }
        return accountMap;
    }
}