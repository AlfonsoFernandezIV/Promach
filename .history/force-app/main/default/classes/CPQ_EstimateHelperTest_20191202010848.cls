@isTest
public without sharing class CPQ_EstimateHelperTest {

    @TestSetup
    static void makeData(){

        Syteline_CPQ__c cpq = new Syteline_CPQ__c(
            Name = 'Default',
            Create_Estimate_URL__c = 'testCreateEstimateURL.com',
            Get_Estimate_URL__c = 'testGetEstimateURL.com/?parms=',
            Get_Opportunity_URL__c = 'testGetOpportunityURL.com',
            Open_Estimate_URL__c = 'testOpenEstimateURL.com',
            password__c = 'testPassword',
            Token_URL__c = 'testTokenURL.com',
            userid__c = 'testUserId'
        );
        insert cpq;

        List<Account> accs = TestDataFactory.createAccounts(1);
        insert accs;

        List<Contact> cons = new List<Contact>();
        cons = TestDataFactory.createContacts(1, accs[0].Id);
        insert cons;

        Id accProfileRecTypeId = Schema.SObjectType.Account_Profile__c.getRecordTypeInfosByName().get('IDT Account Profile').getRecordTypeId();
        List<Account_Profile__c> accProfs = TestDataFactory.createIdtAccProfiles(1, accs[0].Id);
        accProfs[0].RecordTypeId = accProfileRecTypeId;
        accProfs[0].Brand2__c = 'IDT';
        insert accProfs;

        List<Opportunity> opps = TestDataFactory.createIdtOpps(1, accs[0].Id, accProfs[0].Id, cons[0].Id);
        opps[0].Syteline_Division_Opportunity_Number__c = '12039';
        insert opps;
    }

    @isTest
    public static void testTokenCreation(){
        Syteline_CPQ__c cpq = CPQ_EstimateHelper.getSytelineCustomSetting();
        
        System.assert(cpq != null);
    }

    @isTest
    public static void testGetOppInfo(){
        Opportunity opp = [SELECT Account.DUNS_Number__c, Account.Name, Account.Phone, 
                            Account.ShippingCity, Account.ShippingCountry, Account.ShippingPostalCode, 
                            Account.ShippingStateCode, Account.ShippingStreet, Id, Name, Owner.Email, 
                            Primary_Contact__c, Primary_Contact__r.Phone, Primary_Contact__r.Email, 
                            Primary_Contact__r.Name, Primary_Contact__r.Title, Product_Category__c, 
                            Syteline_Division_Opportunity_Number__c FROM Opportunity];
        List<String> oppString = CPQ_EstimateHelper.getURLParams(opp);
        // String estimateUrl = CPQ_EstimateHelper.goToEstimate(opp.Id);
        String estimatesUrl = CPQ_EstimateHelper.goToEstimates(opp.Id);
        opp = CPQ_EstimateHelper.getOpportunityInfo(opp.Id);
    }

    @isTest
    public static void testValidateOppFields(){
        Opportunity opp = [SELECT Account.DUNS_Number__c, Account.Name, Account.Phone, 
                            Account.ShippingCity, Account.ShippingCountry, Account.ShippingPostalCode, 
                            Account.ShippingStateCode, Account.ShippingStreet, Id, Name, Owner.Email, 
                            Primary_Contact__c, Primary_Contact__r.Phone, Primary_Contact__r.Email, 
                            Primary_Contact__r.Name, Primary_Contact__r.Title, Product_Category__c, 
                            Syteline_Division_Opportunity_Number__c FROM Opportunity];
        Boolean oppAccIsValid = false;
        Boolean oppConIsValid = false;

        oppAccIsValid = CPQ_EstimateHelper.validateOppAccount(opp.Id);
        oppConIsValid = CPQ_EstimateHelper.validateOppContact(opp.Id);
    }

    @isTest
    public static void testGetSytelineToken(){
        Opportunity opp = [SELECT Account.DUNS_Number__c, Account.Name, Account.Phone, 
                            Account.ShippingCity, Account.ShippingCountry, Account.ShippingPostalCode, 
                            Account.ShippingStateCode, Account.ShippingStreet, Id, Name, Owner.Email, 
                            Primary_Contact__c, Primary_Contact__r.Phone, Primary_Contact__r.Email, 
                            Primary_Contact__r.Name, Primary_Contact__r.Title, Product_Category__c, 
                            Syteline_Division_Opportunity_Number__c FROM Opportunity];
        Syteline_CPQ__c cpq = CPQ_EstimateHelper.getSytelineCustomSetting();
        Map<String, Object> testResponse = new Map<String, Object>();

        Test.setMock(HttpCalloutMock.class, new CPQ_MockCheckEstimateExistsResponse());

        Test.startTest();
        try{
            testResponse = CPQ_EstimateHelper.getSytelineToken();
        } catch(Exception ex){
        System.debug('Error Token ' + ex.getMessage());
        }
        Test.stopTest();

        System.assert(testResponse.get('Message') != null);
        System.assert(testResponse.get('Token') != null);
    }

    @isTest
    public static void testCheckEstimateExists(){
        Boolean estimateExists;
        Opportunity opp = [SELECT Account.DUNS_Number__c, Account.Name, Account.Phone, 
                            Account.ShippingCity, Account.ShippingCountry, Account.ShippingPostalCode, 
                            Account.ShippingStateCode, Account.ShippingStreet, Id, Name, Owner.Email, 
                            Primary_Contact__c, Primary_Contact__r.Phone, Primary_Contact__r.Email, 
                            Primary_Contact__r.Name, Primary_Contact__r.Title, Product_Category__c, 
                            Syteline_Division_Opportunity_Number__c FROM Opportunity];
        Syteline_CPQ__c cpq = CPQ_EstimateHelper.getSytelineCustomSetting();

        Test.setMock(HttpCalloutMock.class, new CPQ_MockCheckEstimateExistsResponse());

        Test.startTest();
        try{
            estimateExists = CPQ_EstimateHelper.checkEstimateExists(opp.Id);
        } catch(Exception ex){
            System.debug('Error Check Estimate ' + ex.getMessage());
        }
        Test.stopTest();
    }

     @isTest
    public static void testGoToEstimate(){
        
    }
/*
    @isTest
    public static void testGoToEstimates(){
        
    }

    @isTest
    public static void testCreateEstimate(){
        
    }

    @isTest
    public static void testGetEstimateURL(){

    } */
}