public without sharing class AccountUtils {
    // TODO if owner change or if zip

    public static void createAccountShares(Map<Id, Account> accountMap){
        System.debug('In createAccountShares method ');

        Set<String> accountZips = new Set<String>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();

        for(Account acc : accountMap.values()){
            accountZips.add(acc.ShippingPostalCode);
        }

        zipMgmtMap = getZipMgmtMap(accountZips);
        insertAccountShares(accountMap.values(), zipMgmtMap);
    }
    
    /* public static void detectAccountChange(Map<Id, Account> newAccountMap, Map<Id, Account> oldAccountMap, Boolean isInsert){
        Map<Id, Account> changedAccountMap = new Map<Id, Account>();
        Map<Id, Account> insertAccountMap = new Map<Id, Account>();

        for(Account acc : newAccountMap.values()){
            Account oldAccount = oldAccountMap.get(acc.Id);
            String newZip = formatZip(acc.ShippingPostalCode);
            String oldZip = formatZip(oldAccount.ShippingPostalCode);
            if (isInsert){
                insertAccountMap.put(acc.Id, acc);
            } else if (acc.OwnerId != oldAccount.OwnerId || newZip != oldZip || !isInsert){
                changedAccountMap.put(acc.Id, acc);
            }
        }
        
        if(!insertAccountMap.keyset().isEmpty()){
            insertAccountSharting(insertAccountMap);
        }

        if(!changedAccountMap.keySet().isEmpty()){
            createAccountSharing(changedAccountMap);
        }        
    } */
    
    /* public static void createAccountSharing(Map<Id, Account> newAccountMap){
        System.debug('1111 In createAccountSharing method ');
        System.debug('1111 In createAccountSharing method ' + newAccountMap.keySet());
        Map<Id, List<Contact>> contactsMap = new Map<Id, List<Contact>>();
        Map<Id, Contact> contactMap = new Map<Id, Contact>();
        Map<Id, List<Opportunity>> oppsMap = new Map<Id, List<Opportunity>>();
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        Map<Id, List<Account_Profile__c>> accProfileMap = new Map<Id, List<Account_Profile__c>>();
        Map<Id, Account_Profile__c> apMap = new Map<Id, Account_Profile__c>();
        List<AccountShare> accountShares = new List<AccountShare>();
        List<ContactShare> contactShares = new List<ContactShare>();
        List<OpportunityShare> oppShares = new List<OpportunityShare>();
        List<Account_Profile__Share> accProfileShares = new List<Account_Profile__Share>();
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        Set<String> accPostalCodeSet = new Set<String>();
        
        accPostalCodeSet = getAccZipSet(newAccountMap.values());
        zipMgmtMap = getZipMgmtMap(accPostalCodeSet);
        contactsMap = getContacts(newAccountMap);
        oppsMap = getOpps(newAccountMap);
        accProfileMap = getAccProfiles(newAccountMap, zipMgmtMap);

        //deleteExistingApexSharing(zipMgmtMap, newAccountMap, accPostalCodeSet);

        System.debug('1111 Ready to enter for loop apex sharing rule creation' + newAccountMap.values());
        for(Account acc : newAccountMap.values()){
            System.debug('1111 In for loop zipMgmtMap ' + zipMgmtMap);
            String zip = formatZip(acc.ShippingPostalCode);
            System.debug('1111 acc.ShippingPostalCode ' + acc.ShippingPostalCode);
            System.debug('1111 zip ' + zip);

            if(zipMgmtMap.containsKey(zip)){
                if(zipMgmtMap.get(zip).User__c != acc.OwnerId){
                    System.debug('1111 Zip Criteria Passed');
                    AccountShare accShare = new AccountShare();     // Instantiate the sharing objects
                    accShare.AccountId = acc.Id;                // Set the ID of record being shared
                    System.debug('1111 User Id ' + zipMgmtMap.get(zip).User__c);
                    accShare.UserOrGroupId = zipMgmtMap.get(zip).User__c;       // Set the ID of user or group being granted access
                    accShare.AccountAccessLevel = 'Edit';        // Set the access level
                    accShare.OpportunityAccessLevel = 'None';
                    accShare.ContactAccessLevel = 'Edit';
                    accShare.RowCause = Schema.AccountShare.RowCause.Manual; // Set the Apex sharing reason for hiring manager and recruiter
                    accountShares.add(accShare);                // Add objects to list for insert
                }

                /* if(contactsMap.containsKey(acc.Id)){
                    System.debug('1111 In Contact Sharing');
                    for(Contact con : contactsMap.get(acc.Id)){
                        if(zipMgmtMap.get(zip).User__c != con.OwnerId){
                            ContactShare conShare = new ContactShare();     // Instantiate the sharing objects
                            conShare.ContactId = con.Id;                // Set the ID of record being shared
                            conShare.UserOrGroupId = zipMgmtMap.get(zip).User__c;       // Set the ID of user or group being granted access
                            conShare.ContactAccessLevel = 'Edit';        // Set the access level
                            conShare.RowCause = Schema.ContactShare.RowCause.Manual; // Set the Apex sharing reason for hiring manager and recruiter
                            contactMap.put(con.Id, con);
                            contactShares.add(conShare);                // Add objects to list for insert
                        }
                    }
                 } 
                
                 if(oppsMap.containsKey(acc.Id)){
                    for(Opportunity opp : oppsMap.get(acc.Id)){
                        if(zipMgmtMap.get(zip).User__c != opp.OwnerId){
                            if(opp.Brand2__c == 'IDT'){
                                OpportunityShare oppShare = new OpportunityShare();     // Instantiate the sharing objects
                                oppShare.OpportunityId = opp.Id;    // Set the ID of record being shared
                                oppShare.UserOrGroupId = zipMgmtMap.get(zip).User__c;   // Set the ID of user or group being granted access
                                oppShare.OpportunityAccessLevel = 'Read';    // Set the access level
                                oppShare.RowCause = Schema.OpportunityShare.RowCause.Manual;    // Set the Apex sharing reason for hiring manager and recruiter
                                opportunityMap.put(opp.Id, opp);
                                oppShares.add(oppShare);    // Add objects to list for insert
                            } 
                        }
                    }
                } 

                if(accProfileMap.containsKey(acc.Id)){
                    System.debug('1111 In Account Profile Sharing');
                    for(Account_Profile__c ap : accProfileMap.get(acc.Id)){
                        System.debug('1111 In Account Profile Sharing' + ap);
                        System.debug('1111 In Zip User ' + zipMgmtMap.get(zip).User__c);
                        System.debug('1111 In Account Profile Owner Id ' + ap.OwnerId);
                        if(zipMgmtMap.get(zip).User__c != ap.OwnerId){
                            System.debug('1111 Ap Brand Name ' + ap.Brand2__c);
                            if(ap.Brand2__c == 'IDT'){
                                System.debug('1111 Idt Account Profile');
                                Account_Profile__Share acctProfileShare = new Account_Profile__Share();
                                acctProfileShare.ParentId = ap.Id;  // Set the ID of record being shared
                                acctProfileShare.UserOrGroupId = zipMgmtMap.get(zip).User__c;    // Set the ID of user or group being granted access
                                acctProfileShare.AccessLevel = 'Edit';   // Set the access level
                                acctProfileShare.RowCause = Schema.Account_Profile__Share.RowCause.Manual;    // Set the Apex sharing reason for hiring manager and recruiter
                                apMap.put(ap.Id, ap);
                                accProfileShares.add(acctProfileShare);     // Add objects to list for insert
                                System.debug('1111 accProfileShares ' + accProfileShares);
                                System.debug('1111 apMap ' + apMap);
                            } else {
                                System.debug('1111 Non Idt Account Profile');
                                Account_Profile__Share acctProfileShare = new Account_Profile__Share();
                                acctProfileShare.ParentId = ap.Id;  // Set the ID of record being shared
                                acctProfileShare.UserOrGroupId = zipMgmtMap.get(zip).User__c;    // Set the ID of user or group being granted access
                                acctProfileShare.AccessLevel = 'Read';   // Set the access level
                                acctProfileShare.RowCause = Schema.Account_Profile__Share.RowCause.Manual;    // Set the Apex sharing reason for hiring manager and recruiter
                                accProfileShares.add(acctProfileShare);     // Add objects to list for insert
                                apMap.put(ap.Id, ap);
                                System.debug('1111 Non Idt apMap ' + apMap);
                            }
                        }
                    }
                }
            }
        }
        if(!accountShares.isEmpty() && !newAccountMap.isEmpty()){
            initiateAccShareSave(accountShares, newAccountMap);
        }
        if(!contactShares.isEmpty() && !contactMap.isEmpty()){
            System.debug('1111 Contact Shares ' + contactShares);
            initiateConShareSave(contactShares, contactMap);
        }
        if(!oppShares.isEmpty() && !opportunityMap.isEmpty()){
            initiateOppShareSave(oppShares, opportunityMap);
        }

        System.debug('1111 accProfileShares ' + accProfileShares.isEmpty());
        System.debug('1111 apMap ' + apMap.isEmpty());
        if(!accProfileShares.isEmpty() && !apMap.isEmpty()){
            initiateAccProfileSave(accProfileShares, apMap);
        }
    } */

    public static String formatZip(String rawZip){
        String formattedZip;

        if(rawZip != null){         
            if(rawZip.length() == 5 || rawZip.length() == 7){
                System.debug('3333 Regular Zip Code ' + rawZip);
                formattedZip = rawZip;
                System.debug('3333 Formatted Zip Code ' + formattedZip);
            } else if( rawZip.length() > 5){
                formattedZip = rawZip.substring(0, 5);
                System.debug('3333 Formatted Zip Code ' + formattedZip);
            }
        }
        
        return formattedZip;
    }

    public static Map<String, Zip_Postal_Code_Management__c> getZipMgmtMap(Set<String> accPostalCodeSet){
        System.debug('6666 In getZipMgmtMap methods');
        Map<String, Zip_Postal_Code_Management__c> zipMgmtMap = new Map<String, Zip_Postal_Code_Management__c>();
        List<Zip_Postal_Code_Management__c> zipList = [SELECT Zip_or_Postal_Code__c, Brand__c, User__c, User__r.Id FROM Zip_Postal_Code_Management__c WHERE Zip_or_Postal_Code__c IN: accPostalCodeSet];
        
        for(Zip_Postal_Code_Management__c zip : zipList){
            zipMgmtMap.put(zip.Zip_or_Postal_Code__c, zip);
        }
        System.debug('6666 zipMgmtMap ' + zipMgmtMap);
        return zipMgmtMap;
    }
    
    /* public static void initiateAccShareSave(List<AccountShare> accountShares, Map<Id, Account> newAccountMap){
        System.debug('7777 In initiateAccShareSave method');
        System.debug('7777 List Account Shares ' + accountShares);
        System.debug('7777 Map Account ' + newAccountMap);
        // Insert sharing records and capture save result
        Database.UpsertResult[] result = Database.upsert(accountShares, false);

        Integer counter = 0;

        for(Database.UpsertResult sr : result){
            if(!sr.isSuccess()){
                Database.Error err = sr.getErrors()[0];
                
                // Check if the error is related to a trivial access level
                // Access levels equal or more permissive than the object's default access level are not allowed.
                // These sharing records are not required and thus an insert exception is acceptable.
                if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION && err.getMessage().contains('AccessLevel'))){
                    // Throw an error when the error is not related to trivial access level
                    newAccountMap.get(accountShares[counter].AccountId).addError('Unable to grant sharing access due to following exception: ' + err.getMessage());
                }
            }
            counter++;
        }
    } */

    public static void insertAccountShares(List<Account> accounts, Map<String, Zip_Postal_Code_Management__c> zipMgmtMap){
        System.debug('In insertAccountShares method');
        List<AccountShare> accountShares = new List<AccountShare>();

        for(Account acc : accounts){
            String rawZip = acc.ShippingPostalCode;
            String formatZip = formatZip(rawZip);
            AccountShare accShare = new AccountShare();
            accShare.AccountId = acc.Id;
            accShare.UserOrGroupId = zipMgmtMap.get(formatZip).User__c;
            accShare.RowCause = Schema.AccountShare.RowCause.Manual;
            accountShares.add(accShare);
        }
        System.debug('accontShares ' + accountShares);
        insert accountShares;
    }
    /* public static void deleteExistingApexSharing(Map<String, Zip_Postal_Code_Management__c> zipMgmtMap, Map<Id, Account> newAccountMap, Set<String> accPostalCodeSet){
        System.debug('In deleteExistingApexSharing method');

        List<AccountShare> accShares = [SELECT Id, UserOrGroupId FROM AccountShare WHERE AccountId IN: newAccountMap.keySet() AND RowCause = 'Manual' AND IsDeleted = false];
        List<Contact> cons = [SELECT Id FROM Contact WHERE AccountId IN: newAccountMap.keySet()];
        List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE AccountID IN: newAccountMap.keySet()];
        List<Account_Profile__c> accProfs = [SELECT Id FROM Account_Profile__c WHERE Account__c IN: newAccountMap.keySet()];
        List<Account_Profile__Share> apShares = [SELECT Id, UserOrGroupId FROM Account_Profile__Share WHERE ParentId IN: accProfs AND RowCause = 'Manual' AND IsDeleted = false];
        List<ContactShare> conShares = [SELECT Id, UserOrGroupId FROM ContactShare WHERE ContactId IN: cons AND RowCause = 'Manual' AND IsDeleted = false];
        List<OpportunityShare> oppShares = [SELECT Id, UserOrGroupId FROM OpportunityShare WHERE OpportunityId IN: opps AND RowCause = 'Manual' AND IsDeleted = false];
        Set<AccountShare> deleteAccShareSet = new Set<AccountShare>();
        List<AccountShare> deleteAccShares = new List<AccountShare>();
        Set<ContactShare> deleteConShareSet = new Set<ContactShare>();
        List<ContactShare> deleteConShares = new List<ContactShare>();
        Set<OpportunityShare> deleteOppShareSet = new Set<OpportunityShare>();
        List<OpportunityShare> deleteOppShares = new List<OpportunityShare>();
        Set<Account_Profile__Share> deleteAPShareSet = new Set<Account_Profile__Share>();
        List<Account_Profile__Share> deleteAPShares = new List<Account_Profile__Share>();

        


        for(Account acc : newAccountMap.values()){
            String zip = formatZip(acc.ShippingPostalCode);
            if(!accShares.isEmpty()){
                for(AccountShare acs : accShares){
                    if(acs.UserOrGroupId != zipMgmtMap.get(zip).User__c){
                        deleteAccShareSet.add(acs);
                    }
                }
            }
            if(!conShares.isEmpty()){
                for(ContactShare cs : conShares){
                    System.debug('!!!! Deleting Contact Sharing cs.UserOrGroupId ' + cs.UserOrGroupId);
                    System.debug('!!!! Deleting Contact Sharing acc.ShippingPostalCode ' + zip);
                    System.debug('!!!! Deleting Contact Sharing zipMgmtMap.get(acc.ShippingPostalCode ' + zipMgmtMap.get(zip));
                    System.debug('!!!! Deleting Contact Sharing Map ' + zipMgmtMap.get(zip).User__c);
                    if(cs.UserOrGroupId != zipMgmtMap.get(zip).User__c){
                        deleteConShareSet.add(cs);
                    }
                }
            }
            if(!oppShares.isEmpty()){
                for(OpportunityShare os : oppShares){
                    if(os.UserOrGroupId != zipMgmtMap.get(zip).User__c){
                        deleteOppShareSet.add(os);
                    }
                }
            }
            if(!apShares.isEmpty()){
                for(Account_Profile__Share aps : apShares){
                    if(aps.UserOrGroupId != zipMgmtMap.get(zip).User__c){
                        deleteAPShareSet.add(aps);
                    }
                }
            }
        }
        
        deleteAccShares.addAll(deleteAccShareSet);
        deleteConShares.addAll(deleteConShareSet);
        deleteOppShares.addAll(deleteOppShareSet);
        deleteAPShares.addAll(deleteAPShareSet);

        if(!deleteConShares.isEmpty()){
            delete deleteConShares;
        }
        if(!deleteOppShares.isEmpty()){
            delete deleteOppShares;
        }
        if(!deleteAPShares.isEmpty()){
            delete deleteAPShares;
        }
        if(!deleteAccShares.isEmpty()){
            delete deleteAccShares;
        }
    } */
}