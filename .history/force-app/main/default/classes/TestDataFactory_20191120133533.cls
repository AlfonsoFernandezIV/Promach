public without sharing class TestDataFactory {
    
    public static List<Account> createAccounts( Integer numberOfAccounts) {
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < numberOfAccounts; i++){
            Account acc = new Account(
                Name = 'Test Account ' + i,
                ShippingStreet = '1234 Test St',
                ShippingCity = 'Testville',
                ShippingState = 'California',
                ShippingPostalCode = '92111',
                ShippingCountry = 'United States'
            );
            accounts.add(acc);
        }
        return accounts;
    }

    public static List<Contact> createContacts( Integer numberOfContacts, Id accountId) {
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < numberOfContacts; i++){
            Contact con = new Contact(
                firstName = 'Test' + i, 
                lastName = 'Contact', 
                AccountId = accountId,
                Email = 'test' + i + '@email.com'
            );
            contacts.add(con);
        }
        return contacts;
    }

    Id accProfileRecTypeId = Schema.SObjectType.Account_Profile__c.getRecordTypeInfosByName().get('IDT Account Profile').getRecordTypeId();

    public static List<Account_Profile__c> createAccProfiles( Integer numberOfAccProfiles, Id accountId){
        List<Account_Profile__c> accProfiles = new List<Account_Profile__c>();
        for(Integer i = 0; i < numberOfAccProfiles; i++){
            Account_Profile__c ap = new Account_Profile__c(
                RecordTypeId = accProfileRecTypeId,
                Name = 'Test Account Profile' + i,
                Account__c = accountId,
                Customer_Type__c = 'Brand',
                Brand2__c = 'IDT',
                Industry__c = 'Beverage',
                Market__c = 'Beer'
            );
            accProfiles.add(ap);
        }
        return accProfiles;
    }

    Id oppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IDT Aftermarket Opportunity').getRecordTypeId();
    public static List<Opportunity> createOpps( Integer numberOfAccounts, Id accountId, Id accProfile) {
        List<Opportunity> opps = new List<Opportunity>();
        for(Integer i = 0; i < numberOfAccounts; i++){
            Opportunity opp = new Opportunity(
                RecordTypeId = oppRecTypeId,
                Name = 'Test Opportunity ' + i, 
                AccountId = accountId, 
                Account_Profile__c = accProfile,
                CloseDate = Date.today() + 30,
                StageName = 'Negotiation',
                CurrencyIsoCode = 'USD',
                Industry__c = 'Beverage',
                Market__c = 'Beer',
                ForecastCategoryName = 'Pipeline'
            );
            opps.add(opp);
        }
        return opps;
    }
}
