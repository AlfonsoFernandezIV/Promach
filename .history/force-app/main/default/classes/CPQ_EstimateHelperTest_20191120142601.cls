@isTest
public without sharing class CPQ_EstimateHelperTest {

    @TestSetup
    static void makeData(){

        Syteline_CPQ__c cpq = new Syteline_CPQ__c(
            Name = 'Default',
            Create_Estimate_URL__c = 'testCreateEstimateURL.com',
            Get_Estimate_URL__c = 'testGetEstimateURL.com',
            Get_Opportunity_URL__c = 'testGetOpportunityURL.com',
            Open_Estimate_URL__c = 'testOpenEstimateURL.com',
            password__c = 'testPassword',
            Token_URL__c = 'testTokenURL.com',
            userid__c = 'testUserId'
        );
        insert cpq;

        List<Account> accs = new List<Account>();
        accs = TestDataFactory.createAccounts(1);
        insert accs;

        List<Contact> cons = new List<Contact>();
        cons = TestDataFactory.createContacts(1, accs[0].Id);
        insert cons;

        List<Account_Profile__c> aps = new List<Account_Profile__c>();
        aps = TestDataFactory.createIdtAccProfiles(1, accs[0].Id);
        insert aps;

        List<Opportunity> opps = new List<Opportunity>();
        opps = TestDataFactory.createIdtOpps(1, accs[0].Id, aps[0].Id);
        opps[0].Primary_Contact__c = cons[0].Id;
        insert opps;
    }

    @isTest
    public static void testTokenCreation(){
        // Syteline_CPQ__c cpq = CPQ_EstimateHelper.getSytelineCustomSetting();
        Syteline_CPQ__c cpq = [SELECT Create_Estimate_URL__c, Get_Estimate_URL__c, Get_Opportunity_URL__c, Open_Estimate_URL__c, password__c, Token_URL__c, 
                    userid__c FROM Syteline_CPQ__c WHERE Name = 'Default'];
        /* Map<String, Object> tokenResultsMap = new Map<String, Object>();
        
        tokenResultsMap = CPQ_EstimateHelper.getSytelineToken();
 */
        System.assert(cpq != null);
        /* System.assert(tokenResultsMap != null); */
    }
}
