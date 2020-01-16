public with sharing class ContactUtils {
    
    public static void createContactSharing(List<Contact> contacts, Map<Id, Contact> contactMap){

        List<Account> accounts = new List<Account>();
        List<ContactShare> contactShares = new List<ContactShare>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        Map<Id, Account> accIdAccMap = new Map<Id, Account>();

        accounts = getAccList(contacts);
        zipMgmtMap = getZipMgmtMap();
        accIdAccMap = getAccMap(contacts);

        for(Contact con : contacts){
            if(accIdAccMap.containsKey(con.AccountId)){
                if(zipMgmtMap.containsKey(accIdAccMap.get(con.AccountId).ShippingPostalCode)){
                    ContactShare conShare = new ContactShare();     // Instantiate the sharing objects
                    conShare.ContactId = con.Id;                // Set the ID of record being shared
                    conShare.UserOrGroupId = zipMgmtMap.get(accIdAccMap.get(con.AccountId).ShippingPostalCode).User__c;       // Set the ID of user or group being granted access
                    conShare.ContactAccessLevel = 'Edit';        // Set the access level
                    conShare.RowCause = Schema.ContactShare.RowCause.Manual; // Set the Apex sharing reason for hiring manager and recruiter
                    contactShares.add(conShare);                // Add objects to list for insert
                }
            }
        }
        initiateSaveAction(contactShares, contactMap);
    }

    public static List<Account> getAccList(List<Contact> contacts){
        List<Account> accList = new List<Account>();
        Set<Id> accIdSet = new Set<Id>();

        for(Contact con : contacts){
            if(con.AccountId != null){
                accIdSet.add(con.AccountId);
            }
        }

        accList = [SELECT Id, ShippingPostalCode FROM Account WHERE Id IN: accIdSet];
        return accList;
    }

    public static Map<String, Zip_Postal_Code_Management__c> getZipMgmtMap(){
        System.debug('In getZipMgmtMap methods');
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        List<Zip_Postal_Code_Management__c> zipList = [SELECT Zip_or_Postal_Code__c, Brand__c, User__c FROM Zip_Postal_Code_Management__c];
        
        System.debug('All Zip List size ' + zipList.size());
        for(Zip_Postal_Code_Management__c zip : zipList){
            zipMgmtMap.put(zip.Zip_or_Postal_Code__c, zip);
        }
        System.debug('IDT Zip Map size ' + zipMgmtMap.keySet().size());
        return zipMgmtMap;
    }

    public static Map<Id, Account> getAccMap(List<Contact> contacts){
        System.debug('In getAccMap method');
        Set<Id> accIds = new Set<Id>();
        Map<Id, Account> accIdAccMap = new Map<Id, Account>();

        for(Contact con : contacts){
            if(con.Brand_Interest__c == 'IDT'){
                accIds.add(con.AccountId);
            }
        }

        List<Account> accs = [SELECT Id, ShippingPostalCode FROM Account WHERE Id IN: accIds];

        for(Account a : accs){
            accIdAccMap.put(a.Id, a);
        }

        return accIdAccMap;
    }

    public static void initiateSaveAction(List<ContactShare> contactShares, Map<Id, Contact> contactMap){

        // Insert sharing records and capture save result
        // The false parameter allows for partial processing if multiple records are passed into the operation
        Database.SaveResult[] result = Database.insert(contactShares, false);

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
                    contactMap.get(contactShares[counter].ContactId).addError('Unable to grant sharing access due to following exception: ' + err.getMessage());
                }
            }
            counter++;
        }
    }
}