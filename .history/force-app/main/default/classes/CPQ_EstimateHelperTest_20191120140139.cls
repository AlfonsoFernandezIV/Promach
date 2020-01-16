@isTest
public without sharing class CPQ_EstimateHelperTest {

    @TestSetup
    static void makeData(){
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
        Syteline_CPQ__c cpq = CPQ_EstimateHelper.getSytelineCustomSetting();
        Map<String, Object> tokenResultsMap = new Map<String, Object>();
        
        tokenResultsMap = CPQ_EstimateHelper.getSytelineToken();

        System.assert(cpq != null);
        System.assert(tokenResultsMap != null);
    }
}
