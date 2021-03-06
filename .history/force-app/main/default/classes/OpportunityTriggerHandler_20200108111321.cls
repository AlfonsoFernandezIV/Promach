public without sharing class OpportunityTriggerHandler {

    public static void insertOppSharingRules(Map<Id, Opportunity> oppMap){
        System.debug('In insertOppSharingRules');
        List<Id> accountIdList = new List<Id>();
        List<String> accountZips = new List<String>();
        List<Opportunity> opps = new List<Opportunity>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        opps = [SELECT Id, AccountId, Account.ShippingPostalCode, Account.BillingPostalCode, OwnerId FROM Opportunity WHERE Id IN: oppMap.keySet() AND Brand2__c = 'IDT'];
        System.debug('opps ' + opps);

        for(Opportunity opp : opps){
            accountIdList.add(opp.AccountId);
            if(opp.Account.ShippingPostalCode != null){
                accountZips.add(opp.Account.ShippingPostalCode);
            } else if(opp.Account.BillingPostalCode != null){
                accountZips.add(opp.Account.BillingPostalCode);
            }
        }

        if(!accountZips.isEmpty()){
            zipMgmtMap  = getZipMgmtMap(opps);
        }
            
        insertOppShares(opps, zipMgmtMap);
        
    }
    
    public static void updateOppSharingRules(Map<Id, Opportunity> oppMap, Map<Id, Opportunity> oldOppMap){
        System.debug('In updateOppSharingRules method' + oppMap.keySet().size());
        List<String> accountIdList = new List<String>();
        List<String> accountZips = new List<String>();
        List<Opportunity> opps = new List<Opportunity>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        for(Opportunity opp : oppMap.values()){
            Opportunity oldOpp = oldOppMap.get(opp.Id);
            System.debug('Opp ' + opp.AccountId);
            System.debug('Opp ' + oldOpp.AccountId);
            System.debug('Opp ' + opp.OwnerId);
            System.debug('Opp ' + oldOpp.OwnerId);
            if(opp.AccountId != oldOpp.AccountId || opp.OwnerId != oldOpp.OwnerId){
                System.debug('Inloop ' + oldOpp.OwnerId);
                accountIdList.add(opp.AccountId);
                accountZips.add(opp.Account.ShippingPostalCode);
            }
        }

        if(!accountIdList.isEmpty()){
            System.debug('accountIdList ' + accountIdList);
        	opps = [SELECT Id, AccountId, Account.ShippingPostalCode,  Account.BillingPostalCode, OwnerId FROM Opportunity WHERE AccountId IN: accountIdList AND Brand2__c = 'IDT'];
        	System.debug('opps ' + opps);
        }
        
        if(!opps.isEmpty()){
            zipMgmtMap  = getZipMgmtMap(opps);
            deleteExistingApexSharing(opps, zipMgmtMap);
            insertOppShares(opps, zipMgmtMap);
        }
    }

    public static void updateSharingFromAccount(List<Opportunity> opps, Map<String, Zip_Postal_Code_Management__c> zipMgmtMap){
        System.debug('In updateSharingFromAccount method');
        deleteExistingApexSharing(opps, zipMgmtMap);
        insertOppShares(opps, zipMgmtMap);
    }

    public static Map<String, Zip_Postal_Code_Management__c> getZipMgmtMap(List<Opportunity> opps){
        System.debug('In getZipMgmtMap methods');
        String formatZip;
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        List<String> acctZips = new List<String>();
        List<Zip_Postal_Code_Management__c> zipList = new List<Zip_Postal_Code_Management__c>();

        for(Opportunity opp : opps){
            if(opp.Account.ShippingPostalCode != null || opp.Account.BillingPostalCode != null){
                if(opp.Account.ShippingPostalCode != null){
                    formatZip = formatZip(opp.Account.ShippingPostalCode);
                }else if(opp.Account.BillingPostalCode != null){
                    formatZip = formatZip(opp.Account.BillingPostalCode);
                }
            }
            if(formatZip != null){
                acctZips.add(formatZip);
            }
        }

        if(!acctZips.isEmpty()){
            zipList = [SELECT Zip_or_Postal_Code__c, Brand__c, User__c, User__r.Id, User__r.IsActive FROM Zip_Postal_Code_Management__c WHERE Zip_or_Postal_Code__c IN: acctZips];
        }
        
        if(!zipList.isEmpty()){
            for(Zip_Postal_Code_Management__c zip : zipList){
                zipMgmtMap.put(zip.Zip_or_Postal_Code__c, zip);
            }
        }
        System.debug('zipMgmtMap ' + zipMgmtMap);
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

    public static void deleteExistingApexSharing(List<Opportunity> opps, Map<String, Zip_Postal_Code_Management__c> zipMgmtMap){
        System.debug('In deleteExistingApexSharing method');

        List<Id> oppIds = new List<Id>();
        List<OpportunityShare> deleteOppShares = new List<OpportunityShare>();

        for(Opportunity opp : opps){
            oppIds.add(opp.Id);
        }
        
        for(Opportunity opp : opps){
            String formatZip = formatZip(opp.Account.ShippingPostalCode);
            for(OpportunityShare os : [SELECT Id, UserOrGroupId FROM OpportunityShare WHERE OpportunityId IN: oppIds AND RowCause = 'Manual' AND IsDeleted = false]){
                if(!deleteOppShares.contains(os)){
                    deleteOppShares.add(os);
                }                    
            }
        }
        
        System.debug('Delect Opp Shares ' + deleteOppShares);
        if(!deleteOppShares.isEmpty()){
            delete deleteOppShares;
        }
    }

    public static void insertOppShares(List<Opportunity> opps, Map<String, Zip_Postal_Code_Management__c> zipMgmtMap){
        System.debug('In insertOppShares ' + opps.size());
        List<OpportunityShare> oppShares = new List<OpportunityShare>();
        String rawZip; 
        String formatZip; 

        for(Opportunity opp : opps){
            if(opp.Account.ShippingPostalCode != null || opp.Account.BillingPostalCode != null){
                if(opp.Account.ShippingPostalCode != null){
                    rawZip = opp.Account.ShippingPostalCode;
                }else if(opp.Account.BillingPostalCode != null){
                    rawZip = opp.Account.BillingPostalCode;
                }
                
                if(rawZip != null){
                    formatZip = formatZip(rawZip);
                }
                
                if(zipMgmtMap.keySet().contains(formatZip)){
                    System.debug('update sharing zipmgmt ' + formatZip);
                    System.debug('update sharing zipmgmt ' + zipMgmtMap);
                    System.debug('update sharing zipmgmt ' + zipMgmtMap.get(formatZip).User__c );
                    System.debug('update sharing zipmgmt ' + zipMgmtMap.get(formatZip).User__r.IsActive );
                    System.debug('opp owner ' + opp.OwnerId);
                    if(zipMgmtMap.get(formatZip).User__c != opp.OwnerId && zipMgmtMap.get(formatZip).User__r.IsActive){
                        OpportunityShare oppShare = new OpportunityShare();     // Instantiate the sharing objects
                        oppShare.OpportunityId = opp.Id;    // Set the ID of record being shared
                        oppShare.UserOrGroupId = zipMgmtMap.get(formatZip).User__c;   // Set the ID of user or group being granted access
                        oppShare.OpportunityAccessLevel = 'Read';    // Set the access level
                        oppShare.RowCause = Schema.OpportunityShare.RowCause.Manual;    // Set the Apex sharing reason for hiring manager and recruiter
                        oppShares.add(oppShare);    // Add objects to list for insert
                    }
                }
            }
        }
        System.debug('oppShares ' + oppShares);
        insert oppShares;
    }

    @future
    public static void updateOpportunitySharing(List<Id> oppIds){
        System.debug('In updateOpportunitySharing method ' + oppIds.size());
        List<Opportunity> opps = new List<Opportunity>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        opps = [SELECT Id, Account.ShippingPostalCode, Account.BillingPostalCode, OwnerId FROM Opportunity WHERE Id IN: oppIds];

        if(!opps.isEmpty()){
            zipMgmtMap = getZipMgmtMap(opps);
            if(!zipMgmtMap.keySet().isEmpty()){
                deleteExistingApexSharing(opps, zipMgmtMap);
                insertOppShares(opps, zipMgmtMap); 
            }
        }
        
    }
}