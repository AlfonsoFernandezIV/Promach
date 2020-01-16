@isTest
public class AccountUtilsTest {

    @isTest
    static void testInsertAccount(){

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

        List<Zip_Postal_Code_Management__c> zips = new List<Zip_Postal_Code_Management__c>{
            new Zip_Postal_Code_Management__c(Brand__c = 'IDT', User__c = users[0].Id, Zip_or_Postal_Code__c = '12345'),
            new Zip_Postal_Code_Management__c(Brand__c = 'IDT', User__c = users[1].Id, Zip_or_Postal_Code__c = '56789')
        };
        insert zips;

        List<Account> accs = new List<Account>{
            new Account(
                Name='Testy 1', 
                ShippingStreet = '123 Testy St', 
                ShippingCity = 'Austiny', 
                ShippingState = 'Iowa', 
                ShippingStateCode = 'IA',
                ShippingPostalCode='12345', 
                ShippingCountryCode = 'US', 
                ShippingCountry = 'United States'),
            new Account(
                Name='Testy 2', 
                ShippingStreet = '124 Testy St',
                ShippingCity = 'Austiny', 
                ShippingState = 'California',
                ShippingStateCode = 'CA',
                ShippingPostalCode='56789', 
                ShippingCountryCode = 'US', 
                ShippingCountry = 'United States')
        };

        Contact con = new Contact(
            firstName = 'Test', 
            lastName = 'Contact', 
            AccountId = accs[0].Id,
            Email = 'test@email.com',
            MailingStreet = '123 Test St',
            MailingCity = 'Testville',
            MailingCountry='United States',
            MailingCountryCode = 'US',
            MailingState = 'California',
            MailingStateCode = 'CA',
            MailingPostalCode = '13232'
        );
        insert con;

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

        test.startTest();
            insert accs;
        test.stopTest();
    }

    @isTest
    static void testUpdateAccount(){

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

        List<Zip_Postal_Code_Management__c> zips = new List<Zip_Postal_Code_Management__c>{
            new Zip_Postal_Code_Management__c(Brand__c = 'IDT', User__c = users[0].Id, Zip_or_Postal_Code__c = '12345'),
            new Zip_Postal_Code_Management__c(Brand__c = 'IDT', User__c = users[1].Id, Zip_or_Postal_Code__c = '56789')
        };
        insert zips;

        List<Account> accs = new List<Account>{
            new Account(Name='Test 1', ShippingStreet = '123 Test St', ShippingCity = 'Austin', ShippingState = 'Iowa', ShippingPostalCode='12345', ShippingCountry = 'United States'),
            new Account(Name='Test 2', ShippingStreet = '124 Test St', ShippingCity = 'Austin', ShippingState = 'California', ShippingPostalCode='56789', ShippingCountry = 'United States')
        };
        insert accs;

        Contact con = new Contact(
            firstName = 'Test', 
            lastName = 'Contact', 
            AccountId = accs[0].Id,
            Email = 'test@email.com',
            MailingStreet = '123 Test St',
            MailingCity = 'Testville',
            MailingCountry='United States',
            MailingCountryCode = 'US',
            MailingState = 'California',
            MailingStateCode = 'CA',
            MailingPostalCode = '13232'
        );
        insert con;

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

        accs[0].ShippingPostalCode = '56789';
        accs[1].ShippingPostalCode = '12345';

        test.startTest();
            update accs;
        test.stopTest();
    }
}