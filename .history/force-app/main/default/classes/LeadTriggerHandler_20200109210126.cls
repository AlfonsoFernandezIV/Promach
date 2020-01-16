public without sharing class LeadTriggerHandler {

    public static void assignedLeadOwner(List<Lead> leadList){
        
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
        }

        if(!zipMgmtPostalCodeSet.isEmpty()){
            zipMgmtMap = getZipMgmtMap(zipMgmtPostalCodeSet);

            for(Lead l : leadMap.values()){
                String formatZip = formatZip(l.PostalCode);
                l.OwnerId = zipMgmtMap.get(formatZip).User__c;
            }
        }
        
    }

    public static void createLeadSharing(Map<Id, Lead> leadMap){

        Set<String> leadZips = new Set<String>();
        List<Lead> updatedLeads = new List<Lead>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        for(Lead l : leadMap.values()){
            if(l.PostalCode != null && !String.isBlank(l.PostalCode)){
                String formatZip = formatZip(l.PostalCode);
                leadZips.add(formatZip);
            }
        }

        if(!leadZips.isEmpty()){
            zipMgmtMap = getZipMgmtMap(leadZips);
        }

        for(Lead l : leadMap.values()){
            if(l.PostalCode != null){
                String formatZip = formatZip(l.PostalCode);
                if(l.Brand_Interest__c == 'IDT' && zipMgmtMap.containsKey(formatZip) && zipMgmtMap.get(formatZip).User__c != l.OwnerId){
                    updatedLeads.add(l);
                }
            }
        }
        if(!updatedLeads.isEmpty()){
            insertLeadShares(updatedLeads, zipMgmtMap);
        }
    }

    public static void updateLeadSharing(Map<Id, Lead> leadMap, Map<Id, Lead> oldLeadMap) {

        List<LeadShare> leadSharingList = new List<LeadShare>();
        List<Lead> updateLeads = new List<Lead>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        Set<String> leadZips = new Set<String>();

        //* Added check for owner changed or if the zip is changed
        for(Lead l : leadMap.values()){
            Lead oldLead = oldLeadMap.get(l.id);
            if(l.PostalCode != null && !String.isBlank(l.PostalCode)){
                String newFormatZip = formatZip(l.PostalCode);
                String oldFormatZip = formatZip(oldLead.PostalCode);
                if(l.OwnerId != oldLead.OwnerId || newFormatZip != oldFormatZip){
                    System.debug('newFormatZip ' + newFormatZip);
                        leadZips.add(newFormatZip);     
                } 
            } else if(l.PostalCode == null && oldLeadMap.get(l.Id).PostalCode != null){
                deleteExistingApexSharing(zipMgmtMap, leadMap);
            }
        }

        if(!leadZips.isEmpty()){
            zipMgmtMap = getZipMgmtMap(leadZips);
            for(Lead l : leadMap.values()){
                String formatZip = formatZip(l.PostalCode);
                if(l.Brand_Interest__c == 'IDT' && zipMgmtMap.containsKey(formatZip) && zipMgmtMap.get(formatZip).User__c != l.OwnerId){
                    updateLeads.add(l);
                }
            }
            deleteExistingApexSharing(zipMgmtMap, leadMap);
            insertLeadShares(updateLeads, zipMgmtMap);
        }
    }

    public static Set<String> getZipCodeSet(Map<Id, Lead> leadMap){

        Set<String> zipMgmtPostalCodeSet = new Set<String>();
        System.debug('leadMap ' + leadMap);
        for(Lead l : leadMap.values()){
            System.debug('l.PostalCode ' + l.PostalCode);
            if(l.PostalCode != null ){
                String formatZip = formatZip(l.PostalCode);
                if(formatZip != null){
                    zipMgmtPostalCodeSet.add(formatZip);
                }
            }
        }
        return zipMgmtPostalCodeSet;
    }

    public static Map<String, Zip_Postal_Code_Management__c> getZipMgmtMap(Set<String> zipMgmtPostalCodeSet){
        System.debug('zipMgmtPostalCodeSet ' + zipMgmtPostalCodeSet);
        List<Zip_Postal_Code_Management__c> zipList = [SELECT Zip_or_Postal_Code__c, Brand__c, User__c, User__r.isActive FROM Zip_Postal_Code_Management__c WHERE Zip_or_Postal_Code__c IN: zipMgmtPostalCodeSet];
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        
        if(!zipList.isEmpty()){
            for(Zip_Postal_Code_Management__c zip : zipList){
                zipMgmtMap.put(zip.Zip_or_Postal_Code__c, zip);
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

    public static void insertLeadShares(List<Lead> leads, Map<String, Zip_Postal_Code_Management__c> zipMgmtMap){
        List<LeadShare> leadShares = new List<LeadShare>();

        for(Lead l : leads){
            String formatZip = formatZip(l.PostalCode);
            if(zipMgmtMap.keySet().contains(formatZip)){
                if(zipMgmtMap.get(formatZip).User__c != l.OwnerId && zipMgmtMap.get(formatZip).User__r.isActive){
                    LeadShare share = new LeadShare();
                    share.LeadId = l.Id;
                    share.UserOrGroupId = zipMgmtMap.get(formatZip).User__c;
                    share.LeadAccessLevel = 'Read';
                    share.RowCause = Schema.LeadShare.RowCause.Manual;
                    leadShares.add(share);     
                }
            }
        }
        if(!leadShares.isEmpty()){
            insert leadShares;
        }
    }

    public static void deleteExistingApexSharing(Map<String, Zip_Postal_Code_Management__c> zipMgmtMap, Map<Id, Lead> leadMap){

        List<LeadShare> leadShares = [SELECT Id, UserOrGroupId FROM LeadShare WHERE LeadId IN: leadMap.keySet() AND RowCause = 'Manual' AND IsDeleted = false];
        Set<LeadShare> deletedLeadShares = new Set<LeadShare>();
        List<LeadShare> deletedLeadSharesList = new List<LeadShare>();

        for(Lead l : leadMap.values()){
            String formatZip = formatZip(l.PostalCode);
            if(!leadShares.isEmpty() && formatZip != null){
                for(LeadShare ls : leadShares){
                    if(zipMgmtMap.keySet().contains(formatZip)){
                        if(ls.UserOrGroupId != zipMgmtMap.get(formatZip).User__c){
                            deletedLeadShares.add(ls);
                        }
                    }
                }
            }
        }

        deletedLeadSharesList.addAll(deletedLeadShares);
        
        if(!deletedLeadSharesList.isEmpty()){
            delete deletedLeadSharesList;
        }
    }

    @future
    public static void updateLeadSharingRules(List<Id> leadIds){
        List<Lead> leads = new List<Lead>();
        Set<String> leadZips = new Set<String>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        Map<Id, Lead> leadMap = new Map<Id, Lead>();

        leads = [SELECT Id, PostalCode, OwnerId FROM Lead WHERE Id IN: leadIds];

        for(Lead l : leads){
            leadZips.add(l.PostalCode);
            leadMap.put(l.Id, l);
        }
        
        if(!leadZips.isEmpty()){
            zipMgmtMap = getZipMgmtMap(leadZips);
        }
        
        if(!zipMgmtMap.keySet().isEmpty() && !leadMap.keySet().isEmpty()){
            deleteExistingApexSharing(zipMgmtMap, leadMap);
            insertLeadShares(leads, zipMgmtMap);
        }
    }
}