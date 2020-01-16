@isTest
public class OpportunityTriggerHandlerTest {
    
    @isTest
    static void testOppInsert(){
        List<Account> accs = TestDataFactory.createAccounts(1);
        insert accs;

        /* Id accProfileRecTypeId = Schema.SObjectType.Account_Profile__c.getRecordTypeInfosByName().get('IDT Account Profile').getRecordTypeId();
        List<Account_Profile__c> accProfs = TestDataFactory.createIdtAccProfiles(1, accs[0].Id);
        accProfs[0].RecordTypeId = accProfileRecTypeId;
        accProfs[0].Brand2__c = 'IDT';
        insert accProfs; */

        /* List<Contact> cons1 = TestDataFactory.createContacts(1, accs[0].Id);
        insert cons1; */

        List<Opportunity> opps = TestDataFactory.createIdtOpps(1, accs[0].Id, accProfs[0].Id, cons1[0].Id);

        Test.startTest();
            insert opps;
        Test.stopTest();
    }
}