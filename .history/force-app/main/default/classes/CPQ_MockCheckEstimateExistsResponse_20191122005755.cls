global class CPQ_MockCheckEstimateExistsResponse implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        Syteline_CPQ__c cpq = CPQ_EstimateHelper.getSytelineCustomSetting();

        System.debug('req.getEndpoint() ' + req.getEndpoint());
        req.setEndpoint(cpq.Get_Estimate_URL__c + ', a,b,0');
        // System.assertEquals(cpq.Get_Estimate_URL__c, req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Token', 'abdw');
        res.setBody('{"Message":"Success","MessageCode":"200", "Parameters":"[0061D000007JQKLQA4,e123,0]","ReturnValue":"0"}');
        res.setStatusCode(200);
        return res;
    }
}

