public without sharing class TestDataFactory {
    

    public static List<Account> createAccounts( Integer numberOfAccounts) {
        Datetime dt = Datetime.now();
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < numberOfAccounts; i++){
            Account acc = new Account(
                Name = 'Test Account ' + i + dt.millisecondGmt(),
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
        Datetime dt = Datetime.now();
        List<Contact> contacts = new List<Contact>();
        for(Integer i = 0; i < numberOfContacts; i++){
            Contact con = new Contact(
                firstName = 'Test' + i, 
                lastName = 'Contact', 
                AccountId = accountId,
                Email = 'test' + i + dt.millisecondGmt() + '@email.com'
            );
            contacts.add(con);
        }
        return contacts;
    }

    public static List<Account_Profile__c> createIdtAccProfiles( Integer numberOfAccProfiles, Id accountId){
        Datetime dt = Datetime.now();
        Id accProfileRecTypeId = Schema.SObjectType.Account_Profile__c.getRecordTypeInfosByName().get('IDT Account Profile').getRecordTypeId();
        List<Account_Profile__c> accProfiles = new List<Account_Profile__c>();
        for(Integer i = 0; i < numberOfAccProfiles; i++){
            Account_Profile__c ap = new Account_Profile__c(
                RecordTypeId = accProfileRecTypeId,
                Name = 'Test Accounts Profile' + i + dt.millisecondGmt(),
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

    public static List<Opportunity> createIdtOpps( Integer numberOfAccounts, Id accountId, Id accProfile) {
        Datetime dt = Datetime.now();
        Id oppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('IDT Machine Opportunity').getRecordTypeId();
        List<Opportunity> opps = new List<Opportunity>();
        for(Integer i = 0; i < numberOfAccounts; i++){
            Opportunity opp = new Opportunity(
                RecordTypeId = oppRecTypeId,
                Name = 'Test Opportunity ' + i + dt.millisecondGmt(), 
                AccountId = accountId, 
                Account_Profile__c = accProfile,
                CloseDate = Date.today() + 30,
                Brand2__c = 'IDT',
                StageName = 'Negotiation',
                CurrencyIsoCode = 'USD',
                Industry__c = 'Beverage',
                Market__c = 'Beer',
                ForecastCategoryName = 'Omitted',
                Product_Category__c = 'Digital Printers',
                Bill_To__c = accountId,
                Bill_To_City__c = 'San Diego',
                Bill_To_Country__c = 'US',
                Bill_To_State_Province__c = 'California',
                Bill_To_Street__c = '1234 Test St',
                Bill_To_Zip_Postal_Code__c = '92111',
                Ship_To__c = accountId,
                Ship_To_City__c = 'San Diego',
                Ship_To_Country__c = 'US',
                Ship_To_State_Province__c = 'California',
                Ship_To_Street__c = '1234 Test St',
                Ship_To_Zip_Postal_Code__c = '92111'
            );
            opps.add(opp);
        }
        return opps;
    }
}
