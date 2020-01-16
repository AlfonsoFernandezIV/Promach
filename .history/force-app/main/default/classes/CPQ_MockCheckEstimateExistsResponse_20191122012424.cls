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
            req.setEndpoint('https://idtcsi10.promachbuilt.com/IDORequestService/MGRestService.svc/json/method/SP!/_Promach_SFDC_OppCheckExists/?parms=,E000034651,0'');
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setHeader('Token', 'abdw');
            res.setBody('{"Message":"Success","MessageCode":"200", "Parameters":"[0061D000007JQKLQA4,e123,0]","ReturnValue":"0"}');
            res.setStatusCode(200);
            return res;
        } else {
            return null;
        }

        
    }
}

