@isTest
public class LeadTriggerHandlerTest {
    
    @isTest
    static void LeadInsertTest() {

        List<User> users = new List<User>{
            new User(
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
            ),
            new User(
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
            ),
            new User(
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
            )
        };
        insert users;

        List<Zip_Postal_Code_Management__c> zips = new List<Zip_Postal_Code_Management__c>{
            new Zip_Postal_Code_Management__c(Brand__c = 'IDT', User__c = users[0].Id, Zip_or_Postal_Code__c = '12345'),
            new Zip_Postal_Code_Management__c(Brand__c = 'IDT', User__c = users[1].Id, Zip_or_Postal_Code__c = '56789'),
            new Zip_Postal_Code_Management__c(Brand__c = 'IDT', User__c = users[2].Id, Zip_or_Postal_Code__c = '45678')
        };
        System.debug('zips size ' + zips.size());
        insert zips;

        Id idtRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('IDT Lead').getRecordTypeId();

        Set<Lead> leads = new Set<Lead>{
            new Lead(Brand_Interest__c = 'IDT', Company = 'Test Company 1', LastName = 'Test 1', Status = 'Open', RecordTypeId = idtRecordTypeId, Phone = '1111111111', PostalCode = '12345'),
            new Lead(Brand_Interest__c = 'IDT', Company = 'Test Company 2', LastName = 'Test 2', Status = 'Open', RecordTypeId = idtRecordTypeId, Phone = '2222222222', PostalCode = '56789'),
            new Lead(Brand_Interest__c = 'IDT', Company = 'Test Company 3', LastName = 'Test 3', Status = 'Open', RecordTypeId = idtRecordTypeId, Phone = '3333333333', PostalCode = '56789')
        };

        List<Lead> leadList = new List<Lead>();
        leadList.addAll(leads);

        Test.startTest();
            insert leadList;
        Test.stopTest();
    }

    @isTest
    static void LeadUpdateTest() {

        List<User> users = new List<User>{
            new User(
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
            ),
            new User(
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
            ),
            new User(
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
            )
        };
        insert users;

        List<Zip_Postal_Code_Management__c> zips = new List<Zip_Postal_Code_Management__c>{
            new Zip_Postal_Code_Management__c(Brand__c = 'IDT', User__c = users[0].Id, Zip_or_Postal_Code__c = '12345'),
            new Zip_Postal_Code_Management__c(Brand__c = 'IDT', User__c = users[1].Id, Zip_or_Postal_Code__c = '56789'),
            new Zip_Postal_Code_Management__c(Brand__c = 'IDT', User__c = users[2].Id, Zip_or_Postal_Code__c = '45678')
        };
        System.debug('zips size ' + zips.size());
        insert zips;

        Id idtRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('IDT Lead').getRecordTypeId();

        Set<Lead> leads = new Set<Lead>{
            new Lead(Brand_Interest__c = 'IDT', Company = 'Test Company 1', LastName = 'Test 1', Status = 'Open', RecordTypeId = idtRecordTypeId, Phone = '1111111111', PostalCode = '12345-1233'),
            new Lead(Brand_Interest__c = 'IDT', Company = 'Test Company 2', LastName = 'Test 2', Status = 'Open', RecordTypeId = idtRecordTypeId, Phone = '2222222222', PostalCode = '56789'),
            new Lead(Brand_Interest__c = 'IDT', Company = 'Test Company 3', LastName = 'Test 3', Status = 'Open', RecordTypeId = idtRecordTypeId, Phone = '3333333333', PostalCode = '56789')
        };

        List<Lead> leadList = new List<Lead>();
        leadList.addAll(leads);
        insert leadList;

        leadList[0].PostalCode = '34567-1234';

        Test.startTest();
            update leadList;
        Test.stopTest();
    }
}