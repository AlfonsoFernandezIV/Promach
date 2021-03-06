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
            System.debug('1 zipMgmtPostalCodeSet ' + zipMgmtPostalCodeSet);
            zipMgmtMap = getZipMgmtMap(zipMgmtPostalCodeSet);
            System.debug('1 zipMgmtMap ' + zipMgmtMap);

            for(Lead l : leadMap.values()){
                String formatZip = formatZip(l.PostalCode);
                l.OwnerId = zipMgmtMap.get(formatZip).User__c;
            }
        }
    }

    public static void createLeadSharing(Map<Id, Lead> leadMap){
        System.debug('In createLeadSharing methods');
        Set<String> leadZips = new Set<String>();
        List<Lead> updatedLeads = new List<Lead>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        for(Lead l : leadMap.values()){
            String formatZip = formatZip(l.PostalCode);
            leadZips.add(formatZip);
        }

        System.debug('2 leadZips ' + leadZips);
        zipMgmtMap = getZipMgmtMap(leadZips);

        for(Lead l : leadMap.values()){
            String formatZip = formatZip(l.PostalCode);
            if(l.Brand_Interest__c == 'IDT' && zipMgmtMap.containsKey(formatZip) && zipMgmtMap.get(formatZip).User__c != l.OwnerId){
                updatedLeads.add(l);
            }
        }

        
        insertLeadShares(updatedLeads, zipMgmtMap);
    }

    public static void updateLeadSharing(Map<Id, Lead> leadMap, Map<Id, Lead> oldLeadMap) {
        System.debug('In assignIDTLeads methods');
        List<LeadShare> leadSharingList = new List<LeadShare>();
        List<Lead> updateLeads = new List<Lead>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        Set<String> leadZips = new Set<String>();

        //* Added check for owner changed or if the zip is changed
        for(Lead l : leadMap.values()){
            Lead oldLead = oldLeadMap.get(l.id);
            String newFormatZip = formatZip(l.PostalCode);
            String oldFormatZip = formatZip(oldLead.PostalCode);
            if(l.OwnerId != oldLead.OwnerId || newFormatZip != oldFormatZip){
                    leadZips.add(newFormatZip);     
            } 
        }
        System.debug('3 leadZips ' + leadZips);
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
        System.debug('In getZipCodeSet method ' + leadMap.size());
        Set<String> zipMgmtPostalCodeSet = new Set<String>();
        for(Lead l : leadMap.values()){
            String formatZip = formatZip(l.PostalCode);
            if(formatZip != null){
                zipMgmtPostalCodeSet.add(formatZip);
            }
        }
        System.debug('zipMgmtPostalCodeSet ' + zipMgmtPostalCodeSet);
        return zipMgmtPostalCodeSet;
    }

    public static Map<String, Zip_Postal_Code_Management__c> getZipMgmtMap(Set<String> zipMgmtPostalCodeSet){
        System.debug('In getZipMgmtMap methods ' + zipMgmtPostalCodeSet);
        List<Zip_Postal_Code_Management__c> zipList = [SELECT Zip_or_Postal_Code__c, Brand__c, User__c FROM Zip_Postal_Code_Management__c WHERE Zip_or_Postal_Code__c IN: zipMgmtPostalCodeSet];
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        
        for(Zip_Postal_Code_Management__c zip : zipList){
            zipMgmtMap.put(zip.Zip_or_Postal_Code__c, zip);
        }
        System.debug('In getZipMgmtMap methods ' + zipMgmtMap);
        return zipMgmtMap;
    }

    public static String formatZip(String rawZip){
        String formattedZip;

        if(rawZip != null){         
            if(rawZip.length() == 5 || rawZip.length() == 7){
                System.debug('Regular Zip Code ' + rawZip);
                formattedZip = rawZip;
                System.debug('Formatted Zip Code ' + formattedZip);
            } else if( rawZip.length() > 5){
                formattedZip = rawZip.substring(0, 5);
                System.debug('Formatted Zip Code ' + formattedZip);
            }
        }   
        return formattedZip;
    }

    public static void insertLeadShares(List<Lead> leads, Map<String, Zip_Postal_Code_Management__c> zipMgmtMap){
        System.debug('In insertLeadShares method ' + leads.size());
        List<LeadShare> leadShares = new List<LeadShare>();

        for(Lead l : leads){
            String formatZip = formatZip(l.PostalCode);
            System.debug('Lead Owner ' + l.OwnerId);
            System.debug('Zip User ' + zipMgmtMap.values());
            System.debug('Zip User ' + zipMgmtMap.get(formatZip).User__c);
            if(zipMgmtMap.get(formatZip).User__c != l.OwnerId){
                LeadShare share = new LeadShare();
                share.LeadId = l.Id;
                share.UserOrGroupId = zipMgmtMap.get(formatZip).User__c;
                share.LeadAccessLevel = 'Read';
                share.RowCause = Schema.LeadShare.RowCause.Manual;
                leadShares.add(share);     
            }
        }
        System.debug('leadShares ' + leadShares);
        insert leadShares;
    }

    public static void deleteExistingApexSharing(Map<String, Zip_Postal_Code_Management__c> zipMgmtMap, Map<Id, Lead> leadMap){
        System.debug('In deleteExistingApexSharing method');
        List<LeadShare> leadShares = [SELECT Id, UserOrGroupId FROM LeadShare WHERE LeadId IN: leadMap.keySet() AND RowCause = 'Manual' AND IsDeleted = false];
        Set<LeadShare> deletedLeadShares = new Set<LeadShare>();
        List<LeadShare> deletedLeadSharesList = new List<LeadShare>();

        System.debug('zipMgmtMap ' + zipMgmtMap);

        for(Lead l : leadMap.values()){
            String formatZip = formatZip(l.PostalCode);
            if(!leadShares.isEmpty() && formatZip != null){
                for(LeadShare ls : leadShares){
                    System.debug('ls.UserOrGroupId ' + ls.UserOrGroupId + ' formatted Zip: ' + formatZip);
                    System.debug('zipMgmtMap.get(formatZip)' + zipMgmtMap.get(formatZip));
                    System.debug('zipMgmtMap.get(formatZip).User__c ' + zipMgmtMap.get(formatZip).User__c);
                    if(ls.UserOrGroupId != zipMgmtMap.get(formatZip).User__c){
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

    @future
    public static void updateLeadSharingRules(List<Id> leadIds){
        System.debug('In updateLeadSharingRules method ' + leadIds.size());
        List<Lead> leads = new List<Lead>();
        Set<String> leadZips = new Set<String>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        Map<Id, Lead> leadMap = new Map<Id, Lead>();

        leads = [SELECT Id, PostalCode, OwnerId FROM Lead WHERE Id IN: leadIds];

        for(Lead l : leads){
            leadZips.add(l.PostalCode);
            leadMap.put(l.Id, l);
        }
        
        zipMgmtMap = getZipMgmtMap(leadZips);

        
        zipMgmtMap = getZipMgmtMap(leadZips);
        deleteExistingApexSharing(zipMgmtMap, leadMap);
        insertLeadShares(leads, zipMgmtMap);
    }
}