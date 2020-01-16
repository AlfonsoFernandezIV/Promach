global class CPQ_MockCheckEstimateExistsResponse implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        Syteline_CPQ__c cpq = CPQ_EstimateHelper.getSytelineCustomSetting();

        if(req.getEndpoint() == cpq.Token_URL__c){
            System.debug('req.getEndpoint() ' + req.getEndpoint());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Message":"Success","Token":"bdI6IQzCviZOGJ0E+"}');
            res.setStatusCode(200);
            return res;
        }else if(req.getEndpoint() == cpq.Get_Estimate_URL__c){
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Authorization', 'abdw');
            res.setBody('{"Message":null,"MessageCode":0,"Parameters":["0061D000007JQKLQA4","null","0"],"ReturnValue":"0"}');
            res.setStatusCode(200);
            return res;
        } else {
            return null;
        }

        
    }
}

