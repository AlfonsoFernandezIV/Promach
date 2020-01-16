public without sharing class AccountProfileTriggerHandler {

    public static void createAcctProfileSharingRules(Map<Id, Account_Profile__c> apMap){
        
        List<Account_Profile__c> apList = new List<Account_Profile__c>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        apList = [SELECT Id, Account__c, Account__r.OwnerId, Account__r.BillingPostalCode, Account__r.ShippingPostalCode, Brand2__c, OwnerId FROM Account_Profile__c WHERE Id IN: apMap.keySet()];
        

        zipMgmtMap = getZipMgmtMap(apList);
        insertAccProfShares(apList, zipMgmtMap);
    }

    public static void updateAcctProfileSharingRules(Map<Id, Account_Profile__c> apMap, Map<Id, Account_Profile__c> oldApMap){
        
        List<Account_Profile__c> apList = new List<Account_Profile__c>();
        List<Account_Profile__c> apUpdateList = new List<Account_Profile__c>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        apList = [SELECT Id, Account__c, Account__r.OwnerId, Account__r.ShippingPostalCode, Brand2__c, OwnerId FROM Account_Profile__c WHERE Id IN: apMap.keySet()];

        for(Account_Profile__c ap : apList){
            Account_Profile__c oldAp = oldApMap.get(ap.Id);
            
            if(ap.OwnerId != oldAp.OwnerId || ap.Account__c != oldAp.Account__c){
                apUpdateList.add(ap);
            }
        }

        zipMgmtMap = getZipMgmtMap(apList);
        deleteExistingApexSharing(apUpdateList, zipMgmtMap);
        insertAccProfShares(apUpdateList, zipMgmtMap);
    }

    public static void updateSharingFromAccount(List<Account_Profile__c> apList, Map<String, Zip_Postal_Code_Management__c> zipMgmtMap){
        
        deleteExistingApexSharing(apList, zipMgmtMap);
        insertAccProfShares(apList, zipMgmtMap);
    }

    public static Map<String, Zip_Postal_Code_Management__c> getZipMgmtMap(List<Account_Profile__c> apList){
        
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        List<String> acctZips = new List<String>();
        List<Zip_Postal_Code_Management__c> zipList = new List<Zip_Postal_Code_Management__c>();

        for(Account_Profile__c ap : apList){
            if(ap.Account__r.ShippingPostalCode != null){
                String formatZip = formatZip(ap.Account__r.ShippingPostalCode);
                acctZips.add(formatZip);
            }
            
        }

        if(!acctZips.isEmpty()){
            zipList = [SELECT Zip_or_Postal_Code__c, Brand__c, User__c, User__r.Id, User__r.IsActive FROM Zip_Postal_Code_Management__c WHERE Zip_or_Postal_Code__c IN: acctZips];
        }

        if(!zipList.isEmpty()){
            for(Zip_Postal_Code_Management__c zip : zipList){
                if(zip.User__r.IsActive){
                    zipMgmtMap.put(zip.Zip_or_Postal_Code__c, zip);
                }
            }
        }
        
        return zipMgmtMap;
    }

    public static String formatZip(String rawZip){
        String formattedZip;

        if(rawZip != null){         
            if(rawZip.length() == 5 || rawZip.length() == 7){
                formattedZip = rawZip;
            } else if( rawZip.length() > 5){
                formattedZip = rawZip.substring(0, 5);
            }
        }   
        return formattedZip;
    }

    public static void deleteExistingApexSharing(List<Account_Profile__c> apUpdateList, Map<String, Zip_Postal_Code_Management__c> zipMgmtMap){

        List<Id> apIds = new List<Id>();
        List<Account_Profile__Share> apShares = new List<Account_Profile__Share>();
        Set<Account_Profile__Share> deleteAPShareSet = new Set<Account_Profile__Share>();
        List<Account_Profile__Share> deleteAPShares = new List<Account_Profile__Share>();

        for(Account_Profile__c ap : apUpdateList){
            apIds.add(ap.Id);
        }

        apShares = [SELECT ParentId, UserOrGroupId FROM Account_Profile__Share WHERE ParentId IN: apIds AND RowCause = 'Manual' AND IsDeleted = false];
        
        for(Account_Profile__c ap : apUpdateList){
            String formatZip = formatZip(ap.Account__r.ShippingPostalCode);
            if(!apShares.isEmpty()){
                for(Account_Profile__Share aps : apShares){
                    if(zipMgmtMap.keySet().contains(formatZip)){
                        if(aps.UserOrGroupId != zipMgmtMap.get(formatZip).User__c){
                            deleteAPShareSet.add(aps);
                        }
                    }
                }
            }
        }
        
        deleteAPShares.addAll(deleteAPShareSet);
        
        if(!deleteAPShares.isEmpty()){
            delete deleteAPShares;
        }
    }

    public static void insertAccProfShares(List<Account_Profile__c> apUpdateList, Map<String, Zip_Postal_Code_Management__c> zipMgmtMap){
        
        List<Account_Profile__Share> apShares = new List<Account_Profile__Share>();
        String formatZip;

        for(Account_Profile__c ap : apUpdateList){
            if((ap.Account__r.ShippingPostalCode != null || (ap.Account__r.ShippingPostalCode == null && ap.Account__r.BillingPostalCode != null))){
                if(ap.Account__r.ShippingPostalCode == null){
                    formatZip = formatZip(ap.Account__r.BillingPostalCode);
                } else {
                    formatZip = formatZip(ap.Account__r.ShippingPostalCode);
                }
                 
                if(zipMgmtMap.keySet().contains(formatZip)){
                    if(ap.OwnerId != zipMgmtMap.get(formatZip).User__c){
                        if(ap.Brand2__c == 'IDT'){
                            Account_Profile__Share acctProfileShare = new Account_Profile__Share();
                            acctProfileShare.ParentId = ap.Id;  // Set the ID of record being shared
                            acctProfileShare.UserOrGroupId = zipMgmtMap.get(formatZip).User__c;    // Set the ID of user or group being granted access
                            acctProfileShare.AccessLevel = 'Edit';   // Set the access level
                            acctProfileShare.RowCause = Schema.Account_Profile__Share.RowCause.Manual;    // Set the Apex sharing reason for hiring manager and recruiter
                            apShares.add(acctProfileShare);
                        } else {
                            Account_Profile__Share acctProfileShare2 = new Account_Profile__Share();
                            acctProfileShare2.ParentId = ap.Id;  // Set the ID of record being shared
                            acctProfileShare2.UserOrGroupId = zipMgmtMap.get(formatZip).User__c;    // Set the ID of user or group being granted access
                            acctProfileShare2.AccessLevel = 'Read';   // Set the access level
                            acctProfileShare2.RowCause = Schema.Account_Profile__Share.RowCause.Manual;    // Set the Apex sharing reason for hiring manager and recruiter
                            apShares.add(acctProfileShare2);
                        }
                    }
                }
            }
        }
        insert apShares;
    }

    @future
    public static void updateAccountProfileSharing(List<Id> accProfIds){
        List<Account_Profile__c> accProfs = new List<Account_Profile__c>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        accProfs = [SELECT Id, Account__r.ShippingPostalCode, Brand2__c, OwnerId FROM Account_Profile__c WHERE Id IN: accProfIds];
        
        zipMgmtMap = getZipMgmtMap(accProfs);
        deleteExistingApexSharing(accProfs, zipMgmtMap);
        insertAccProfShares(accProfs, zipMgmtMap);
    }
}