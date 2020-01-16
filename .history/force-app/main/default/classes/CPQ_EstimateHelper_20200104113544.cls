public without sharing class CPQ_EstimateHelper {
    
    @AuraEnabled
    public static Syteline_CPQ__c getSytelineCustomSetting(){
        return [SELECT Create_Estimate_URL__c, Get_Estimate_URL__c, Get_Opportunity_URL__c, Open_Estimate_URL__c, password__c, Token_URL__c, 
                    userid__c FROM Syteline_CPQ__c WHERE Name = 'Default'];
    }

    @AuraEnabled(cacheable=true)
    public static Opportunity getOpportunityInfo(Id oppId){
        System.debug('oppId ' + oppId);
        return [SELECT Account.DUNS_Number__c, Account.Name, Account.Phone, Account.ShippingCity, Account.ShippingCountry, Account.ShippingPostalCode, Account.ShippingStateCode, Account.ShippingStreet, Id, Name, Owner.Email, Primary_Contact__c, Primary_Contact__r.Phone, Primary_Contact__r.Email, Primary_Contact__r.Name, Primary_Contact__r.Title, Product_Category__c, Syteline_Division_Opportunity_Number__c FROM Opportunity WHERE Id =: oppId];
    }

    @AuraEnabled(cacheable=true)
    public static Boolean validateOppContact(Id oppId){
        Boolean conIsValid = true;
        Opportunity opp = getOpportunityInfo(oppId);

        System.debug('Primary Contact Info ' + opp.Primary_Contact__c + ' ' + opp.Primary_Contact__r.Email);
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
			System.debug('Callout ' + callout);
		HttpResponse response = callout.send();
        System.debug('Token response ' + response.getBody());

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
			System.debug('Callout Endpoint ' + callout);
		HttpResponse response = callout.send();
        System.debug('Estimate exists response ' + response.getBody());

        CheckEstimateExistsReturn cr = CheckEstimateExistsReturn.parse(response.getBody());
        System.debug('CheckEstimateExistsReturn ' + cr.Parameters[2]);
        returnParam = Integer.valueOf(cr.Parameters[2]);

        if(returnParam == 1){
            estimateExists = true;
        }
        System.debug('estimateExists ' + estimateExists);
        return estimateExists;
    }

    @AuraEnabled(cacheable=true)
    public static String goToEstimate(Id oppId){
        System.debug('In goToEstimate method. OppId = ' + oppId);
        Syteline_CPQ__c cpq = getSytelineCustomSetting();
        String estimateId = createEstimate(oppId);
        String cpqURL = cpq.Open_Estimate_URL__c;
        String target = '<ESTIMATEID>';
        String estimateURL = cpqURL.replace(target, estimateId);
        return estimateURL;
    }

    @AuraEnabled(cacheable=true)
    public static String goToEstimates(Id oppId){
        System.debug('IN goToEstimates method. OppId = ' + oppId);
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
        System.debug('params ' + params);
        for(String p:params){
            callout.addParameter('parms',EncodingUtil.urlEncode(p, 'UTF-8'));
        }
		System.debug('Token:' + token);
    
        callout
			.endpoint(cpq.Create_Estimate_URL__c)
			.method('GET')
			.addHeader('Accept', 'application/json')
			.addHeader('Authorization', token)
			.timeout(10000);
			System.debug('Callout ' + callout);
		HttpResponse response = callout.send();
            System.debug('Response ' + response.getStatus() + ' ' + response.getStatusCode() + response.getBody());
        
        CreateSytelineEstimate cse = CreateSytelineEstimate.parse(response.getBody());
        System.debug('Return' + cse);
        System.debug('Estimate Number ' + cse.Parameters[18]);
        estimateNumber = cse.Parameters[18];
        
        return estimateNumber;
    }

    public static List<String> getURLParams(Opportunity opp){
        System.debug('In getURLParams method');
        List<String> param = new List<String>();
        String id = nullCheck(opp.Id);
        id = commaCheck(id);
        System.debug('id ' + id);
        String duns = nullCheck(opp.Account.DUNS_Number__c);
        duns = commaCheck(duns);
        System.debug('duns ' + duns);
        String ownerEmail = nullCheck(opp.Owner.Email);
        ownerEmail = commaCheck(ownerEmail);
        System.debug('ownerEmail ' + ownerEmail);
        String productCategory = nullCheck(opp.Product_Category__c);
        productCategory = commaCheck(productCategory);
        System.debug('productCategory ' + productCategory);
        String accountName = nullCheck(opp.Account.Name);
        accountName = commaCheck(accountName);
        System.debug('accountName ' + accountName);
        String accountStreet1 = nullCheck(opp.Account.ShippingStreet);
        accountStreet1 = commaCheck(accountStreet1);
        System.debug('accountStreet1 ' + accountStreet1);
        String accountStreet2 = '';
        String accountStreet3 = '';
        String accountStreet4 = '';
        String accountCity = nullCheck(opp.Account.ShippingCity);
        accountCity = commaCheck(accountCity);
        System.debug('accountCity ' + accountCity);
        String accountState = nullCheck(opp.Account.ShippingStateCode);
        accountState = commaCheck(accountState);
        System.debug('accountState ' + accountState);
        String accountZip = nullCheck(opp.Account.ShippingPostalCode);
        accountZip = commaCheck(accountZip);
        System.debug('accountZip ' + accountZip);
        String accountCountry = nullCheck(opp.Account.ShippingCountry);
        accountCountry = commaCheck(accountCountry);
        System.debug('accountCountry ' + accountCountry);
        String accountPhone = nullCheck(opp.Account.Phone);
        accountPhone = commaCheck(accountPhone);
        System.debug('accountPhone ' + accountPhone);
        String contactName = nullCheck(opp.Primary_Contact__r.Name);
        contactName = commaCheck(contactName);
        System.debug('contactName ' + contactName);
        String contactPhone = nullCheck(opp.Primary_Contact__r.Phone);
        contactPhone = commaCheck(contactPhone);
        System.debug('contactPhone ' + contactPhone);
        String contactEmail = nullCheck(opp.Primary_Contact__r.Email);
        contactEmail = commaCheck(contactEmail);
        System.debug('contactEmail ' + contactEmail);
        String contactTitle = nullCheck(opp.Primary_Contact__r.Title);
        contactTitle = commaCheck(contactTitle);
        System.debug('contactTitle ' + contactTitle);
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

        System.debug('Param method ' + param);
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

    public static String commaCheck(String s){
        System.debug('commCheck method String unfiltered ' + s);
        String check;

        if(s.contains(',')){
            check = s.remove(',');
        } else {
            check = s;
        }

        System.debug('String no comma ' + check);
        return check;
    }
}