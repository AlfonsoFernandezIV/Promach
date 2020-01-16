@isTest
public class OpportunityTriggerHandlerTest {
    
    @isTest
    static void testOppInsert(){
        List<User> users = new List<User>{
        	new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Brenton CRM Lead'].Id,
                LastName = 'User 1',
                Email = 'user1@user.com',
                Username = 'user1@user1.com' + System.currentTimeMillis(),
                CompanyName = 'ProMach',
                Title = 'title',
                Alias = 'user1',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            ),
            new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Brenton CRM Lead'].Id,
                LastName = 'User 2',
                Email = 'user2@user.com',
                Username = 'user2@user2.com' + System.currentTimeMillis(),
                CompanyName = 'ProMach',
                Title = 'title',
                Alias = 'user2',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            ),
            new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Brenton CRM Lead'].Id,
                LastName = 'User 3',
                Email = 'user3@user.com',
                Username = 'user3@user3.com' + System.currentTimeMillis(),
                CompanyName = 'ProMach',
                Title = 'title',
                Alias = 'user3',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            )
		};
        insert users;
        
        List<Account> accs = new List<Account>{
			new Account(Name='Testy 1', ShippingStreet = '123 Testy St', ShippingCity = 'Austiny', ShippingState = 'Iowa', ShippingPostalCode='12345', ShippingCountry = 'United States'),
            new Account(Name='Testy 2', ShippingStreet = '124 Testy St', ShippingCity = 'Austiny', ShippingState = 'California', ShippingPostalCode='56789', ShippingCountry = 'United States'),
            new Account(Name='Testy 3', BillingStreet = '125 Testy St', BillingCity = 'Austiny', BillingState = 'California', BillingPostalCode='56789', BillingCountry = 'United States')
        };
        insert accs;
        
        Datetime dt = Datetime.now();
        Id accProfileBrentonRecTypeId = Schema.SObjectType.Account_Profile__c.getRecordTypeInfosByName().get('Brenton Account Profile').getRecordTypeId();
        Id accProfileRecTypeId = Schema.SObjectType.Account_Profile__c.getRecordTypeInfosByName().get('IDT Account Profile').getRecordTypeId();

        Account_Profile__c accProf = new Account_Profile__c(
            Name = 'Test Accounts Profile' + dt.millisecondGmt(),
            Account__c = accs[0].Id,
            Customer_Type__c = 'Brand',
            Industry__c = 'Beverage',
            Market__c = 'Beer',
            RecordTypeId = accProfileRecTypeId,
            Brand2__c = 'IDT'
        );
        insert accProf;

        Id oppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IDT Aftermarket Opportunity').getRecordTypeId();

        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(
                Name='Test Opp 1', 
                RecordTypeId=oppRecTypeId,
                AccountId=accs[0].Id, 
                Account_Profile__c=accProf.Id, 
                CurrencyIsoCode='USD', 
                CloseDate=System.today(), 
                StageName='Open', 
                ForecastCategoryName='Pipeline', 
                Industry__c='Beverage',
                Market__c='Beer',
                Brand2__c='IDT')
        };
        insert opps;

        Test.startTest();
        insert opps;
        Test.stopTest();
    }
}