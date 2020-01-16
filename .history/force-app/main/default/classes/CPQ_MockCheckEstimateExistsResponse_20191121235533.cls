global class CPQ_MockCheckEstimateExistsResponse implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        Syteline_CPQ__c cpq = CPQ_EstimateHelper.getSytelineCustomSetting();

        System.assertEquals(cpq.Get_Estimate_URL__c, req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Message":"null","MessageCode":"0", "Parameters":"["0061D000007JQKLQA4","null","0"]","ReturnValue":"0"}');
        res.setStatusCode(200);
        return res;
    }
}

