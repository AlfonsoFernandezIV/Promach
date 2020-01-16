@isTest
public class ContactTriggerHandlerTest {
    
    @isTest
    static void insertContact(){
        List<Account> accs = TestDataFactory.createAccounts(1);
        insert accs;

        List<Contact> cons = TestDataFactory.createContacts(2, accs[0].Id);

        Test.startTest();
            insert cons;
        Test.stopTest();
    }
}
