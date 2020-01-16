public without sharing class CPQ_EstimateHelper {
    
    @AuraEnabled
    public static Syteline_CPQ__c getSytelineCustomSetting(){
        return [SELECT Create_Estimate_URL__c, Get_Estimate_URL__c, Get_Opportunity_URL__c, Open_Estimate_URL__c, password__c, Token_URL__c, 
                    userid__c FROM Syteline_CPQ__c WHERE Name = 'Default'];
    }

    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunityInfo(Id oppId){
        return [SELECT Account.DUNS_Number__c, Account.Name, Account.Phone, Account.ShippingCity, Account.ShippingCountry, Account.ShippingPostalCode, Account.ShippingStateCode, Account.ShippingStreet, Id, Name, Owner.Email, Primary_Contact__c, Primary_Contact__r.Phone, Primary_Contact__r.Email, Primary_Contact__r.Name, Primary_Contact__r.Title, Product_Category__c, Syteline_Division_Opportunity_Number__c FROM Opportunity WHERE Id =: oppId];
    }

    @AuraEnabled(cacheable=true)
    public static Boolean validateOppContact(Id oppId){
        Boolean conIsValid = true;
        Opportunity opp = getOpportunityInfo(oppId);

        if(opp.Primary_Contact__c == null || opp.Primary_Contact__r.Email == null){
            conIsValid = false;
        }
        return conIsValid;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean validateOppAccount(Id oppId){
        Boolean accIsValid = true;
        Opportunity opp = getOpportunityInfo(oppId);

        if(opp.Account.ShippingStreet == null || opp.Account.ShippingCity == null || opp.Account.ShippingStateCode == null || opp.Account.ShippingPostalCode == null || opp.Account.ShippingCountry == null){
            accIsValid = false;
        }
        return accIsValid;
    }

    // Pass in the endpoint to be used using the string url
	@AuraEnabled(cacheable=true)
	public static Map <String, Object> getSytelineToken() {

        Syteline_CPQ__c cpq = getSytelineCustomSetting();

		CalloutUtility callout = new CalloutUtility();
		Map<String,List<String>> parameters = new Map<String,List<String>>();
		Map<String,String> headers = new Map<String,String>();

		callout
			.endpoint(cpq.Token_URL__c)
			.method('GET')
			.addHeader('Content-Type','application/json')
			.addHeader('Accept', 'application/json')
			.addHeader('userid', cpq.userid__c)
			.addHeader('password', cpq.password__c)
			.timeout(10000);
		HttpResponse response = callout.send();

		Map <String, Object> resultsMap = (Map <String, Object>)JSON.deserializeUntyped(response.getBody());
		return resultsMap;
	}

    @AuraEnabled(cacheable=true)
    public static Boolean checkEstimateExists(Id oppId){
        Boolean estimateExists = false;
        Integer returnParam;
        String token;
        Map<String, Object> tokenMap = new Map<String, Object>();

        Opportunity opp = getOpportunityInfo(oppId);
        String syteLineOppNumber = opp.Syteline_Division_Opportunity_Number__c;

        Syteline_CPQ__c cpq = getSytelineCustomSetting();
        tokenMap = getSytelineToken();
        token = String.valueOf(tokenMap.get('Token'));

        CalloutUtility callout = new CalloutUtility();
		Map<String,List<String>> parameters = new Map<String,List<String>>();
		Map<String,String> headers = new Map<String,String>();
        
        callout
			.endpoint(cpq.Get_Estimate_URL__c + opp.Id + ',' + syteLineOppNumber + ',0')
			.method('GET')
			.addHeader('Content-Type','application/json')
			.addHeader('Accept', 'application/json')
			.addHeader('Authorization', token)
			.timeout(10000);
		HttpResponse response = callout.send();

        CheckEstimateExistsReturn cr = CheckEstimateExistsReturn.parse(response.getBody());
        returnParam = Integer.valueOf(cr.Parameters[2]);

        if(returnParam == 1){
            estimateExists = true;
        }
        return estimateExists;
    }

    @AuraEnabled(cacheable=true)
    public static String goToEstimate(Id oppId){

        Syteline_CPQ__c cpq = getSytelineCustomSetting();
        String estimateId = createEstimate(oppId);
        String cpqURL = cpq.Open_Estimate_URL__c;
        String target = '<ESTIMATEID>';
        String estimateURL = cpqURL.replace(target, estimateId);
        return estimateURL;
    }

    @AuraEnabled(cacheable=true)
    public static String goToEstimates(Id oppId){
        
        Syteline_CPQ__c cpq = getSytelineCustomSetting();
        String cpqURL = cpq.Get_Opportunity_URL__c;
        String target = '<OPPID>';
        String estimateURL = cpqURL.replace(target, oppId);
        return estimateURL;
    }

    @AuraEnabled(cacheable=true)
    public static String createEstimate(Id oppId){

        Map<String, Object> tokenMap = new Map<String, Object>();
        String token;
        String estimateNumber;
        tokenMap = getSytelineToken();
        token = String.valueOf(tokenMap.get('Token'));
        Opportunity opp = getOpportunityInfo(oppId);

        Syteline_CPQ__c cpq = getSytelineCustomSetting();

        CalloutUtility callout = new CalloutUtility();
		Map<String,String> headers = new Map<String,String>();

        List<String> params = CPQ_EstimateHelper.getURLParams(opp);
        
        for(String p:params){
            callout.addParameter('parms',EncodingUtil.urlEncode(p, 'UTF-8'));
        }
    
        callout
			.endpoint(cpq.Create_Estimate_URL__c)
			.method('GET')
			.addHeader('Accept', 'application/json')
			.addHeader('Authorization', token)
			.timeout(10000);

		HttpResponse response = callout.send();
        
        CreateSytelineEstimate cse = CreateSytelineEstimate.parse(response.getBody());
        estimateNumber = cse.Parameters[18];
        
        return estimateNumber;
    }

    public static List<String> getURLParams(Opportunity opp){
        List<String> param = new List<String>();
        String id = nullCheck(opp.Id);
        String duns = nullCheck(opp.Account.DUNS_Number__c);
        String ownerEmail = nullCheck(opp.Owner.Email);
        String productCategory = nullCheck(opp.Product_Category__c);
        String accountName = nullCheck(opp.Account.Name);
        String accountStreet1 = nullCheck(opp.Account.ShippingStreet);
        String accountStreet2 = '';
        String accountStreet3 = '';
        String accountStreet4 = '';
        String accountCity = nullCheck(opp.Account.ShippingCity);
        String accountState = nullCheck(opp.Account.ShippingStateCode);
        String accountZip = nullCheck(opp.Account.ShippingPostalCode);
        String accountCountry = nullCheck(opp.Account.ShippingCountry);
        String accountPhone = nullCheck(opp.Account.Phone);
        String contactName = nullCheck(opp.Primary_Contact__r.Name);
        String contactPhone = nullCheck(opp.Primary_Contact__r.Phone);
        String contactEmail = nullCheck(opp.Primary_Contact__r.Email);
        String contactTitle = nullCheck(opp.Primary_Contact__r.Title);
        String estimateNumber = '';
        String infoBar = '';

        param.add(id);
        param.add(duns);
        param.add(ownerEmail);
        param.add(productCategory);
        param.add(accountName);
        param.add(accountStreet1);
        param.add(accountStreet2);
        param.add(accountStreet3);
        param.add(accountStreet4);
        param.add(accountCity);
        param.add(accountState);
        param.add(accountZip);
        param.add(accountCountry);
        param.add(accountPhone);
        param.add(contactName);
        param.add(contactPhone);
        param.add(contactEmail);
        param.add(contactTitle);
        param.add(estimateNumber);
        param.add(infoBar);

        return param;
    }

    public static String nullCheck(String s){
        String check;

        if(s == null){
            check = '';
        } else {
            check = s;
        }

        return check;
    }
}
