public without sharing class BatchDeleteApexSharing {

    public static void getLeadSharing(){
        List<LeadShare> leadShares = new List<LeadShare>();
        List<LeadShare> leads = new List<LeadShare>();

        leadShares = [SELECT Id, LeadId, Lead.Brand_Interest__c FROM LeadShare WHERE RowCause = 'Manual' AND isDeleted = false];

        for(LeadShare ls : leadShares){
            if(ls.Lead.Brand_Interest__c != 'IDT'){
                leads.add(ls);
            }
        }
        delete leads;
    }

    public static void getOppSharing(){
        List<OpportunityShare> oppShare = new List<OpportunityShare>();
        List<Id> oppShare = new List<Id>();
        List<OpportunityShare> oppShare = new List<OpportunityShare>();
    }
}
