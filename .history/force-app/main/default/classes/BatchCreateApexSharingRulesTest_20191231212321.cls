@isTest
public class BatchCreateApexSharingRulesTest {
    
    @isTest
    static void testBatch(){

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

        List<Account> accounts = new List<Account>();
        for(Integer i=0; i<100 ; i++){
            Account acc = new Account(
                Name='Testy' + i, 
                ShippingStreet = '12' + i + ' Testy St', 
                ShippingCity = 'Austiny', 
                ShippingState = 'Iowa', 
                ShippingStateCode = 'IA',
                ShippingPostalCode='12345', 
                ShippingCountryCode = 'US', 
                ShippingCountry = 'United States'
            );
            accounts.add(acc);
        }
        insert accounts;

        List<Contact> contacts = new List<Contact>();
        for(Account acc : accounts){
            for(Integer i = 0; i<20; i++){
                Contact con = new Contact(
                    firstName = 'Test', 
                    lastName = 'Contact' + acc.Id + ' ' + i, 
                    AccountId = acc.Id,
                    Email = 'test' + acc.Id + i+'@email.com',
                    MailingStreet = '123 Test St',
                    MailingCity = 'Testville',
                    MailingCountry='United States',
                    MailingCountryCode = 'US',
                    MailingState = 'California',
                    MailingStateCode = 'CA',
                    MailingPostalCode = '13232'
                );
                contacts.add(con);
            }
        }

        Datetime dt = Datetime.now();
        Id accProfileBrentonRecTypeId = Schema.SObjectType.Account_Profile__c.getRecordTypeInfosByName().get('Brenton Account Profile').getRecordTypeId();
        Id accProfileRecTypeId = Schema.SObjectType.Account_Profile__c.getRecordTypeInfosByName().get('IDT Account Profile').getRecordTypeId();

        Account_Profile__c accProf = new Account_Profile__c(
            Name = 'Test Accounts Profile' + dt.millisecondGmt(),
            Account__c = accounts[0].Id,
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
                AccountId=accounts[0].Id, 
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
        
        Id idtRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('IDT Lead').getRecordTypeId();
        
        List<Lead> leads = new List<Lead>{
            new Lead(Brand_Interest__c = 'IDT', Company = 'Test Company 1', LastName = 'Test 1', Status = 'Open', RecordTypeId = idtRecordTypeId, Phone = '1111111111', PostalCode = '12345'),
            new Lead(Brand_Interest__c = 'IDT', Company = 'Test Company 2', LastName = 'Test 2', Status = 'Open', RecordTypeId = idtRecordTypeId, Phone = '2222222222', PostalCode = '12345'),
            new Lead(Brand_Interest__c = 'IDT', Company = 'Test Company 3', LastName = 'Test 3', Status = 'Open', RecordTypeId = idtRecordTypeId, Phone = '3333333333', PostalCode = '56789')
        };

        insert leads;
        
        Test.startTest();
        	Id batchJobId = Database.executeBatch(new BatchCreateApexSharingRules(), 50);
        Test.stopTest();
    }
}