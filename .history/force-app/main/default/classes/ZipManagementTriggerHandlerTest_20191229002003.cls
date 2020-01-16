@isTest
public class ZipManagementTriggerHandlerTest {

    @isTest
    static void testZipUpdate(){

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
            new Zip_Postal_Code_Management__c(Brand__c = 'IDT', CurrencyIsoCode = 'USD', User__c = users[0].Id, Zip_or_Postal_Code__c = '12345'),
            new Zip_Postal_Code_Management__c(Brand__c = 'IDT', CurrencyIsoCode = 'USD', User__c = users[1].Id, Zip_or_Postal_Code__c = '56789'),
            new Zip_Postal_Code_Management__c(Brand__c = 'IDT', CurrencyIsoCode = 'USD', User__c = users[2].Id, Zip_or_Postal_Code__c = '45678')
        };
        insert zips;

        RecordType rt = [SELECT Id FROM RecordType WHERE Sobjecttype = 'Lead' AND DeveloperName = 'IDT_Lead'];

        List<Lead> leads = new List<Lead>{
            new Lead(Brand_Interest__c = 'IDT', Company = 'Test Company 1', LastName = 'Test 1', Status = 'Open', Phone = '1111111111', PostalCode = '12345', OwnerId = u3.Id, RecordTypeId = rt.Id, isConverted = false),
            new Lead(Brand_Interest__c = 'IDT', Company = 'Test Company 2', LastName = 'Test 2', Status = 'Open', Phone = '2222222222', PostalCode = '56789', OwnerId = u3.Id, RecordTypeId = rt.Id, isConverted = false),
            new Lead(Brand_Interest__c = 'IDT', Company = 'Test Company 2', LastName = 'Test 3', Status = 'Open', Phone = '3333333333', PostalCode = '12345', OwnerId = u3.Id, RecordTypeId = rt.Id, isConverted = false)
        };
        insert leads;

        Map<String, Zip_Postal_Code_Management__c> zipMap = new Map<String, Zip_Postal_Code_Management__c>();
        
        User newUser = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Brenton CRM Lead'].Id,
                LastName = 'User 4',
                Email = 'user4@user.com',
                Username = 'user4@user4.com' + System.currentTimeMillis(),
                CompanyName = 'ProMach',
                Title = 'title',
                Alias = 'user4',
                TimeZoneSidKey = 'America/Los_Angeles',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
        );
        insert newUser;

        System.debug('TEST Leads : ' + leads);
        for(Zip_Postal_Code_Management__c z : zips){
            zipMap.put(z.Zip_or_Postal_Code__c, z);
        }

        for(Zip_Postal_Code_Management__c z : zips){
            if(z.Zip_or_Postal_Code__c == '12345'){
                z.User__c = newUser.Id;
            } 
        }

        test.startTest();
            update zips;
        test.stopTest();
    }
}