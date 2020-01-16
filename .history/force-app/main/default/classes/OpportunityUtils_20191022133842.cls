public with sharing class OpportunityUtils {
    
    public static void createOpportunitySharing(List<Opportunity> opportunities, Map<Id, Opportunity> opportunityMap){

        List<Account> accounts = new List<Account>();
        List<OpportunityShare> oppShares = new List<OpportunityShare>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        Map<Id, Account> accIdAccMap = new Map<Id, Account>();
        Set<String> accZipSet = new Set<String>();

        accounts = getAccList(opportunities);
        accZipSet = getAccZipSet(accounts);
        zipMgmtMap = getZipMgmtMap(accZipSet);
        accIdAccMap = getAccMap(opportunities);

        System.debug('Opp Count ' + opportunities.size());
        for(Opportunity opp : opportunities){
            System.debug('Opp Name ' + opp.Name);
            System.debug('Opp containsKey ' + zipMgmtMap.containsKey(accIdAccMap.get(opp.AccountId).ShippingPostalCode));
            System.debug('Zip USer ' + zipMgmtMap.get(accIdAccMap.get(opp.AccountId).ShippingPostalCode).User__c);
            if(accIdAccMap.containsKey(opp.AccountId)){
                if(zipMgmtMap.containsKey(accIdAccMap.get(opp.AccountId).ShippingPostalCode)){
                    OpportunityShare oppShare = new OpportunityShare();     // Instantiate the sharing objects
                    oppShare.OpportunityId = opp.Id;    // Set the ID of record being shared
                    oppShare.UserOrGroupId = zipMgmtMap.get(accIdAccMap.get(opp.AccountId).ShippingPostalCode).User__c;   // Set the ID of user or group being granted access
                    oppShare.OpportunityAccessLevel = 'Edit';    // Set the access level
                    oppShare.RowCause = Schema.OpportunityShare.RowCause.Manual;    // Set the Apex sharing reason for hiring manager and recruiter
                    oppShares.add(oppShare);    // Add objects to list for insert
                }
            }
        }
        initiateSaveAction(oppShares, opportunityMap);
    }

    public static List<Account> getAccList(List<Opportunity> opportunities){
        List<Account> accList = new List<Account>();
        Set<Id> accIdSet = new Set<Id>();

        for(Opportunity opp : opportunities){
            if(opp.AccountId != null){
                accIdSet.add(opp.AccountId);
            }
        }

        accList = [SELECT Id, ShippingPostalCode FROM Account WHERE Id IN: accIdSet];
        return accList;
    }

    public static Set<String> getAccZipSet(List<Account> accounts){
        Set<String> accZipSet = new Set<String>();
        
        for(Account a : accounts){
            if(a.ShippingPostalCode != null){
                accZipSet.add(a.ShippingPostalCode);
            }
        }
        return accZipSet;
    }

    public static Map<String, Zip_Postal_Code_Management__c> getZipMgmtMap(Set<String> accZipSet){
        System.debug('In getZipMgmtMap methods');
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        List<Zip_Postal_Code_Management__c> zipList = [SELECT Zip_or_Postal_Code__c, Brand__c, User__c FROM Zip_Postal_Code_Management__c WHERE Zip_or_Postal_Code__c IN: accZipSet];
        
        System.debug('All Zip List size ' + zipList.size());
        for(Zip_Postal_Code_Management__c zip : zipList){
            zipMgmtMap.put(zip.Zip_or_Postal_Code__c, zip);
        }
        System.debug('IDT Zip Map size ' + zipMgmtMap.keySet().size());
        return zipMgmtMap;
    }

    public static Map<Id, Account> getAccMap(List<Opportunity> opportunities){
        System.debug('In getAccMap method');
        Set<Id> accIds = new Set<Id>();
        Map<Id, Account> accIdAccMap = new Map<Id, Account>();

        for(Opportunity opp : opportunities){
            accIds.add(opp.AccountId);
        }

        List<Account> accs = [SELECT Id, ShippingPostalCode FROM Account WHERE Id IN: accIds];

        for(Account a : accs){
            accIdAccMap.put(a.Id, a);
        }

        return accIdAccMap;
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
                    opportunityMap.get(oppShares[counter].OpportunityId).addError('Unable to grant sharing access due to following exception: ' + err.getMessage()+ err.getFields() + err.getStatusCode());
                }
            }
            counter++;
        }
    }
}