public with sharing class AccountProfileUtils {
    
    public static void createAccountProfileSharing(List<Account_Profile__c> accountProfiles, Map<Id, Account_Profile__c> accountProfileMap){

        List<Account_Profile__Share> accProfileShares = new List<Account_Profile__Share>();

        for(Account_Profile__c ap : accountProfiles){
            
            // Instantiate the sharing objects
            Account_Profile__Share acctProfileShare = new Account_Profile__Share();

            // Set the ID of record being shared
            acctProfileShare.ParentId = ap.Id;

            // Set the ID of user or group being granted access
            acctProfileShare.UserOrGroupId = ap.OwnerId;

            // Set the access level
            acctProfileShare.AccessLevel = 'All';
            
            // Set the Apex sharing reason for hiring manager and recruiter
            acctProfileShare.RowCause = Schema.Account_Profile__Share.RowCause.ID_Technology__c;

            // Add objects to list for insert
            accProfileShares.add(acctProfileShare);
        }

        initiateSaveAction(accProfileShares, accountProfileMap);
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
                    accountProfileMap.get(accountProfileMap[counter].ParentId).addError('Unable to grant sharing access due to following exception: ' + err.getMessage());
                }
            }
            counter++;
        }
    }
}