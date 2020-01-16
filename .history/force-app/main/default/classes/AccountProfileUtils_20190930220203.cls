public with sharing class AccountProfileUtils {
    
    public static void createAccountProfileSharing(List<Account_Profile__c> accountProfiles, Map<Id, Account_Profile__c> accountProfileMap){

        List<Account_Profile__Share> accProfileShares = new List<Account_Profile__Share>();

        Account_Profile__Share idtUsers;

        for(Account_Profile__c ap : accountProfiles){

            // Instantiate the sharing objects
            idtUsers = new Account_Profile__Share();

            // Set the ID of record being shared
            idtUsers.ParentId = ap.Id;

             // Set the ID of user or group being granted access
            idtUsers.UserOrGroupId = ap.OwnerId;

            // Set the access level
            idtUsers.AccessLevel = 'All';
            
            // Set the Apex sharing reason for hiring manager and recruiter
            idtUsers.RowCause = 'Manual';

            // Add objects to list for insert
            accProfileShares.add(idtUsers);
        }

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
