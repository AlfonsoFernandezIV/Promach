global class CPQ_MockGetTokenResponse implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        Syteline_CPQ__c cpq = CPQ_EstimateHelper.getSytelineCustomSetting();

        System.assertEquals(cpq.Token_URL__c, req.getEndpoint());
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Message":"Success","Token":"bdI6IQzCviZOGJ0E+"}');
        res.setStatusCode(200);
        return res;
    }
}
