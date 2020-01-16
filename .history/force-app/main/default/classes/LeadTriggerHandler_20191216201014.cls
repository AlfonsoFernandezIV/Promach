public without sharing class LeadTriggerHandler {

    public static void assignedLeadOwner(List<Lead> leadList){
        System.debug('In assignedLeadOwner ' + leadList);
        Map<Id, Lead> leadMap = new Map<Id, Lead>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        Set<String> zipMgmtPostalCodeSet = new Set<String>();

        for (Lead l : leadList){
            if(l.Brand_Interest__c == 'IDT' && l.PostalCode != null){
                leadMap.put(l.Id, l);
            }
        }

        if(!leadMap.isEmpty()){
            zipMgmtPostalCodeSet = getZipCodeSet(leadMap);
            zipMgmtMap = getZipMgmtMap(zipMgmtPostalCodeSet);

            for(Lead l : leadMap.values()){
                if(l.PostalCode != null){
                    l.OwnerId = zipMgmtMap.get(l.PostalCode).User__c;
                }
                System.debug('Lead Owner changed ' + l.Id + ' ' + l.OwnerId); 
            }
        }
    }

    public static void assignIDTLeads(Map<Id, Lead> leadList, Map<Id, Lead> oldLeadMap, Boolean created, Boolean modified) {
        System.debug('In assignIDTLeads methods');
        List<LeadShare> leadSharingList = new List<LeadShare>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        Set<String> zipMgmtPostalCodeSet = new Set<String>();

        zipMgmtPostalCodeSet = getZipCodeSet(leadList);
        zipMgmtMap = getZipMgmtMap(zipMgmtPostalCodeSet);

        deleteExistingApexSharing(zipMgmtMap, leadList);

        for(Lead l : leadList.values()){
            if(l.Brand_Interest__c == 'IDT'){
                if(zipMgmtMap.containsKey(l.PostalCode) && zipMgmtMap.get(l.PostalCode).User__c != l.OwnerId){
                    LeadShare share = new LeadShare();
                    share.LeadId = l.Id;
                    share.UserOrGroupId = zipMgmtMap.get(l.PostalCode).User__c;
                    share.LeadAccessLevel = 'Read';
                    share.RowCause = Schema.LeadShare.RowCause.Manual;
                    leadSharingList.add(share);
                }
            }
        } 
        initiateSaveAction(leadSharingList, leadList);
    }

    public static Set<String> getZipCodeSet(Map<Id, Lead> leadList){
        System.debug('In getZipCodeSet method');
        Set<String> zipMgmtPostalCodeSet = new Set<String>();
        for(Lead l : leadList.values()){
            if(l.PostalCode != null){
                zipMgmtPostalCodeSet.add(l.PostalCode);
            }
        }
        return zipMgmtPostalCodeSet;
    }

    public static Map<String, Zip_Postal_Code_Management__c> getZipMgmtMap(Set<String> zipMgmtPostalCodeSet){
        System.debug('In getZipMgmtMap methods');
        List<Zip_Postal_Code_Management__c> zipList = [SELECT Zip_or_Postal_Code__c, Brand__c, User__c FROM Zip_Postal_Code_Management__c WHERE Zip_or_Postal_Code__c IN: zipMgmtPostalCodeSet];
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        
        for(Zip_Postal_Code_Management__c zip : zipList){
            zipMgmtMap.put(zip.Zip_or_Postal_Code__c, zip);
        }
        
        return zipMgmtMap;
    }

    public static void initiateSaveAction(List<LeadShare> leadSharingList, Map<Id, Lead> leadList){

        // Insert sharing records and capture save result
        Database.SaveResult[] result = Database.insert(leadSharingList, false);

        Integer counter = 0;

        for(Database.SaveResult sr : result){
            if(sr.isSuccess()){
                System.debug('Lead save success');
            }
            if(!sr.isSuccess()){
                Database.Error err = sr.getErrors()[0];

                // Check if the error is related to a trivial access level
                // Access levels equal or more permissive than the object's default access level are not allowed.
                // These sharing records are not required and thus an insert exception is acceptable.
                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION && err.getMessage().contains('AccessLevel'))){
                    // Throw an error when the error is not related to trivial access level
                    leadList.get(leadSharingList[counter].LeadId).addError('Unable to grant sharing access due to following exception: ' + err.getMessage());
                }
            }
            counter++;
        }
    }

    public static void deleteExistingApexSharing(Map<String, Zip_Postal_Code_Management__c> zipMgmtMap, Map<Id, Lead> leadList){
        System.debug('In deleteExistingApexSharing method');
        List<LeadShare> leadShares = [SELECT Id, UserOrGroupId FROM LeadShare WHERE LeadId IN: leadList.keySet() AND RowCause = 'Manual' AND IsDeleted = false];
        Set<LeadShare> deletedLeadShares = new Set<LeadShare>();
        List<LeadShare> deletedLeadSharesList = new List<LeadShare>();

        for(Lead l : leadList.values()){
            if(!leadShares.isEmpty() && l.PostalCode != null){
                for(LeadShare ls : leadShares){
                    System.debug('ls.UserOrGroupId ' + ls.UserOrGroupId);
                    System.debug('PostalCode ' + l.PostalCode);
                    System.debug('zipMgmtMap.get(l.PostalCode).User__c ' + zipMgmtMap.get(l.PostalCode));
                    System.debug('zipMgmtMap.get(l.PostalCode).User__c ' + zipMgmtMap.get(l.PostalCode).User__c);
                    if(ls.UserOrGroupId != zipMgmtMap.get(l.PostalCode).User__c){
                        deletedLeadShares.add(ls);
                    }
                }
            }
        }

        deletedLeadSharesList.addAll(deletedLeadShares);
        
        if(!deletedLeadSharesList.isEmpty()){
            delete deletedLeadSharesList;
        }
    }
}