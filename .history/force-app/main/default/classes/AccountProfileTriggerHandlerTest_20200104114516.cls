@isTest
public class AccountProfileTriggerHandlerTest {
    
    @isTest
    static void testAccountProfileInsert(){
        
        List<User> users = new List<User>();
            User u1 = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Brenton CRM Lead'].Id,
                LastName = 'User 1',
                Email = 'user1@user.com',
                Username = 'user1@user1.com' + 1,
                CompanyName = 'ProMach',
                Title = 'title',
                Alias = 'user1',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            );

            User u2 = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Brenton CRM Lead'].Id,
                LastName = 'User 2',
                Email = 'user2@user.com',
                Username = 'user2@user2.com' + 2,
                CompanyName = 'ProMach',
                Title = 'title',
                Alias = 'user2',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            );

            User u3 = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Brenton CRM Lead'].Id,
                LastName = 'User 3',
                Email = 'user3@user.com',
                Username = 'user3@user3.com' + 3,
                CompanyName = 'ProMach',
                Title = 'title',
                Alias = 'user3',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            );
        users.add(u1);
        users.add(u2);
        users.add(u3);
        insert users;

        List<Zip_Postal_Code_Management__c> zips = new List<Zip_Postal_Code_Management__c>{
            new Zip_Postal_Code_Management__c(Brand__c = 'IDT', User__c = users[0].Id, Zip_or_Postal_Code__c = '12345'),
            new Zip_Postal_Code_Management__c(Brand__c = 'IDT', User__c = users[1].Id, Zip_or_Postal_Code__c = '56789'),
            new Zip_Postal_Code_Management__c(Brand__c = 'IDT', User__c = users[2].Id, Zip_or_Postal_Code__c = '45678')
        };
        System.debug('zips size ' + zips.size());
        insert zips;
        
        List<Account> accs = new List<Account>{
            new Account(Name='Testy 1', ShippingStreet = '123 Testy St', ShippingCity = 'Austiny', ShippingState = 'Iowa', ShippingPostalCode='12345', ShippingCountry = 'United States'),
            new Account(Name='Testy 2', ShippingStreet = '124 Testy St', ShippingCity = 'Austiny', ShippingState = 'California', ShippingPostalCode='56789', ShippingCountry = 'United States')
        };
        insert accs;

        Datetime dt = Datetime.now();
        Id accProfileBrentonRecTypeId = Schema.SObjectType.Account_Profile__c.getRecordTypeInfosByName().get('Brenton Account Profile').getRecordTypeId();
        Id accProfileRecTypeId = Schema.SObjectType.Account_Profile__c.getRecordTypeInfosByName().get('IDT Account Profile').getRecordTypeId();
        
        List<Account_Profile__c> accProfs = TestDataFactory.createIdtAccProfiles(2, accs[0].Id);
            accProfs[0].RecordTypeId = accProfileRecTypeId;
            accProfs[0].Brand2__c = 'IDT';
            accProfs[1].RecordTypeId = accProfileBrentonRecTypeId;
            accProfs[1].Brand2__c = 'Brenton';

        Test.startTest();
            insert accProfs;
        Test.stopTest();
    }
    
    @isTest
    static void testAccountProfileUpdate(){
        List<User> users = new List<User>();
            User u1 = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Brenton CRM Lead'].Id,
                LastName = 'User 1',
                Email = 'user1@user.com',
                Username = 'user1@user1.com' + 1,
                CompanyName = 'ProMach',
                Title = 'title',
                Alias = 'user1',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            );
            
            User u2 = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Brenton CRM Lead'].Id,
                LastName = 'User 2',
                Email = 'user2@user.com',
                Username = 'user2@user2.com' + 2,
                CompanyName = 'ProMach',
                Title = 'title',
                Alias = 'user2',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            );
    
            User u3 = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Brenton CRM Lead'].Id,
                LastName = 'User 3',
                Email = 'user3@user.com',
                Username = 'user3@user3.com' + 3,
                CompanyName = 'ProMach',
                Title = 'title',
                Alias = 'user3',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
            );
            users.add(u1);
            users.add(u2);
            users.add(u3);
            insert users;
    
            List<Zip_Postal_Code_Management__c> zips = new List<Zip_Postal_Code_Management__c>{
                new Zip_Postal_Code_Management__c(Brand__c = 'IDT', User__c = users[0].Id, Zip_or_Postal_Code__c = '12345'),
                new Zip_Postal_Code_Management__c(Brand__c = 'IDT', User__c = users[1].Id, Zip_or_Postal_Code__c = '56789'),
                new Zip_Postal_Code_Management__c(Brand__c = 'IDT', User__c = users[2].Id, Zip_or_Postal_Code__c = '45678')
            };
            System.debug('zips size ' + zips.size());
            insert zips;
            
            List<Account> accs = new List<Account>{
                new Account(Name='Testy 1', ShippingStreet = '123 Testy St', ShippingCity = 'Austiny', ShippingState = 'Iowa', ShippingPostalCode='12345', ShippingCountry = 'United States'),
                new Account(Name='Testy 2', BillingStreet = '124 Testy St', BillingCity = 'Austiny', BillingState = 'California', BillingPostalCode='56789-1234', BillingCountry = 'United States')
            };
            insert accs;
    
            Datetime dt = Datetime.now();
            Id accProfileBrentonRecTypeId = Schema.SObjectType.Account_Profile__c.getRecordTypeInfosByName().get('Brenton Account Profile').getRecordTypeId();
            Id accProfileRecTypeId = Schema.SObjectType.Account_Profile__c.getRecordTypeInfosByName().get('IDT Account Profile').getRecordTypeId();
            
            List<Account_Profile__c> accProfs = TestDataFactory.createIdtAccProfiles(2, accs[0].Id);
                accProfs[0].RecordTypeId = accProfileRecTypeId;
                accProfs[0].Brand2__c = 'IDT';
                accProfs[1].RecordTypeId = accProfileBrentonRecTypeId;
                accProfs[1].Brand2__c = 'Brenton';
            insert accProfs;
    
        	accProfs[0].OwnerId = users[1].Id;
        	accProfs[0].Account__c = accs[1].Id;
        
            Test.startTest();
                update accProfs[0];
            Test.stopTest();
        }
}