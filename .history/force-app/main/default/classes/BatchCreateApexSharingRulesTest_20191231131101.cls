@isTest
public class BatchCreateApexSharingRulesTest {
    
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
            }
        }
    }
} 
