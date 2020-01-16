public with sharing class ContactUtils {
    
    public static void createContactSharing(List<Contact> contacts, Map<Id, Contact> contactMap){

        List<ContactShare> contactShares = new List<ContactShare>();

        for(Contact con : contacts){

            // Instantiate the sharing objects
            ContactShare conShare = new ContactShare();

            // Set the ID of record being shared
            conShare.ContactId = con.Id;

            // Set the ID of user or group being granted access
            conShare.UserOrGroupId = con.OwnerId;

            // Set the access level
            conShare.ContactAccessLevel = 'All';

            // Set the Apex sharing reason for hiring manager and recruiter
            conShare.RowCause = Schema.Contact.RowCause.Manual;

            // Add objects to list for insert
            contactShares.add(con);
        }

        initiateSaveAction(contactShares, contactMap);
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