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
        List<OpportunityShare> opps = new List<OpportunityShare>();

        oppShare = [SELECT Id, Opportunity.Brand2__c, OpportunityId FROM OpportunityShare WHERE Opportunity.Brand2__c != 'IDT' AND RowCause = 'Manual' AND IsDeleted = false LIMIT 10000];

        for(OpportunityShare os : oppShare){
            if(os.Opportunity.Brand2__c != 'IDT'){
                opps.add(os);
            }
        }
        delete opps;
    }
}
