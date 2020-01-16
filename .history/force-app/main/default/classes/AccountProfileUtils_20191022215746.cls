public with sharing class AccountProfileUtils {
    
    public static void createAccountProfileSharing(List<Account_Profile__c> accountProfiles, Map<Id, Account_Profile__c> accountProfileMap){
        System.debug('In createAccountProfileSharing methods');
        List<Account_Profile__Share> accProfileShares = new List<Account_Profile__Share>();
        List<Account> accs = new List<Account>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        Map<Id, Account> accIdAccMap = new Map<Id, Account>();
        Set<String> zipMgmtPostalCodeSet = new Set<String>();

        zipMgmtMap = getAccIds(accountProfiles);
        accIdAccMap = getAccMap(accountProfiles);

        for(Account_Profile__c ap : accountProfiles){
            if(accIdAccMap.containsKey(ap.Account__c)){
                if(zipMgmtMap.containsKey(accIdAccMap.get(ap.Account__c).ShippingPostalCode)){
                    // Instantiate the sharing objects
                Account_Profile__Share acctProfileShare = new Account_Profile__Share();
                    acctProfileShare.ParentId = ap.Id;  // Set the ID of record being shared
                    acctProfileShare.UserOrGroupId = zipMgmtMap.get(accIdAccMap.get(ap.Account__c).ShippingPostalCode).User__c;    // Set the ID of user or group being granted access
                    acctProfileShare.AccessLevel = 'Edit';   // Set the access level
                    acctProfileShare.RowCause = Manual;    // Set the Apex sharing reason for hiring manager and recruiter
                    accProfileShares.add(acctProfileShare);     // Add objects to list for insert
                }
            }
        }
        initiateSaveAction(accProfileShares, accountProfileMap);
    }

    public static Map<String, Zip_Postal_Code_Management__c> getAccIds(List<Account_Profile__c> accountProfiles){
        List<Account> accs = new List<Account>();
        Set<String> zipMgmtPostalCodeSet = new Set<String>();
        Set<Id> acctProfAccIdSet = new Set<Id>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        for(Account_Profile__c ap : accountProfiles){
            acctProfAccIdSet.add(ap.Account__c);
        }
        zipMgmtMap = getAccList(acctProfAccIdSet);
        return zipMgmtMap;
    }

    public static Map<String, Zip_Postal_Code_Management__c> getAccList(Set<Id> acctProfAccIdSet){
        List<String> accPostalCodes = new List<String>();
        List<Account> accs = [SELECT Id, ShippingPostalCode FROM Account WHERE Id IN: acctProfAccIdSet];
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        for(Account a : accs){
            if(a.ShippingPostalCode != null){
                accPostalCodes.add(a.ShippingPostalCode);
            }
        }
        
        zipMgmtMap = getZipMgmtMap(accPostalCodes);
        return zipMgmtMap;
    }

    public static Map<String, Zip_Postal_Code_Management__c> getZipMgmtMap(List<String> accPostalCodes){
        System.debug('In getZipMgmtMap methods');
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        List<Zip_Postal_Code_Management__c> zipList = [SELECT Zip_or_Postal_Code__c, Brand__c, User__c FROM Zip_Postal_Code_Management__c WHERE Zip_or_Postal_Code__c IN: accPostalCodes];
        
        System.debug('All Zip List size ' + zipList.size());
        for(Zip_Postal_Code_Management__c zip : zipList){
            zipMgmtMap.put(zip.Zip_or_Postal_Code__c, zip);
        }
        System.debug('IDT Zip Map size ' + zipMgmtMap.keySet().size());
        return zipMgmtMap;
    }

    public static Map<Id, Account> getAccMap(List<Account_Profile__c> accountProfiles){
        System.debug('In getAccMap method');
        Set<Id> accIds = new Set<Id>();
        Map<Id, Account> accIdAccMap = new Map<Id, Account>();

        for(Account_Profile__c ap : accountProfiles){
            if(ap.Brand2__c == 'IDT'){
                accIds.add(ap.Account__c);
            }
        }

        List<Account> accs = [SELECT Id, ShippingPostalCode FROM Account WHERE Id IN: accIds];

        for(Account a : accs){
            accIdAccMap.put(a.Id, a);
        }

        return accIdAccMap;
    }

    public static void initiateSaveAction(List<Account_Profile__Share> accProfileShares, Map<Id, Account_Profile__c> accountProfileMap){

        // Insert sharing records and capture save result
        // The false parameter allows for partial processing if multiple records are passed into the operation
        Database.SaveResult[] result = Database.insert(accProfileShares, false);

        // Create couneter
        Integer counter = 0;

        // Process the save result
        for(Database.SaveResult sr : result){
            if(!sr.isSuccess()){
                // Get the first save result error
                Database.Error err = sr.getErrors()[0];

                // Check if the error is related to a trivial access level
                // Access levels equal or more permissive than the object's default access level are not allowed.
                // These sharing records are not required and thus an insert exception is acceptable.
                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION && err.getMessage().contains('AccessLevel'))){
                    // Throw an error when the error is not related to trivial access level
                    accountProfileMap.get(accProfileShares[counter].ParentId).addError('Unable to grant sharing access due to following exception: ' + err.getMessage());
                }
            }
            counter++;
        }
    }
}