public with sharing class OpportunityUtils {
    
    public static void createOpportunitySharing(List<Opportunity> opportunities, Map<Id, Opportunity> opportunityMap){

        List<OpportunityShare> oppShares = new List<Opportunity__Share>();

        for(Opportunity opp : opportunities){

            // Instantiate the sharing objects
            OpportunityShare oppShare = new OpportunityShare();

            // Set the ID of record being shared
            oppShare.ParentId = opp.Id;

            // Set the ID of user or group being granted access
            oppShare.UserOrGroupId = opp.OwnerId;

            // Set the access level
            oppShare.AccessLevel = 'All';

            // Set the Apex sharing reason for hiring manager and recruiter
            oppShare.RowCause = Schema.Opportunity.RowCause.Manual;

            // Add objects to list for insert
            oppShares.add(oppShare);
        }

        initiateSaveAction(oppShares, opportunityMap);
    }

    public static void initiateSaveAction(List<OpportunityShare> oppShares, Map<Id, Opportunity> opportunityMap){

        // Insert sharing records and capture save result
        // The false parameter allows for partial processing if multiple records are passed into the operation
        Database.SaveResult[] result = Database.insert(oppShares, false);

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
                    opportunityMap.get(oppShares[counter].ParentId).addError('Unable to grant sharing access due to following exception: ' + err.getMessage());
                }
            }
            counter++;
        }
    }
}
