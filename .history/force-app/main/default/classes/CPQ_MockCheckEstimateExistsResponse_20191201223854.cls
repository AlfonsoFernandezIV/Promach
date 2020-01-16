global class CPQ_MockCheckEstimateExistsResponse implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        Syteline_CPQ__c cpq = CPQ_EstimateHelper.getSytelineCustomSetting();
        HttpResponse res = new HttpResponse();
        if(req.getEndpoint() == cpq.Token_URL__c){
            System.debug('In Check Token');
            System.debug('req.getEndpoint() ' + req.getEndpoint());        
            // Create a fake response
            
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"Message":"Success","Token":"b/XdI6IQzCviZOGJ0E+002DoKUFOPmVDkwpQDbQjm3w/qkdxDUzmqvSYEZDCmJGWpA23OTlhFpxRHFz3WOsvay8V58XdIp/UIsr5TpCdMwtW3QXF2ahwQYp2O6GzKlJcoJJyjHy8uYmlvCSKXPnR/F6Aa6JsFnZxVMd8iUbrTetF4JJKYBCmHr7wbgzleGS6qrzqb8vfJNf0rGj3/FnD0h2K44LI8MWE5dxE/ojxI9sCKLbyq+vxVH0ffkgF9YRN32VuvhodmVxfkO4YHMgvs7rkzTTbqrDpdlpgFirTU9sgsVrSQW2MBT1Hgx740zKbYACfhZsSh7Yb7ZKNvbFNnA=="}');
            res.setStatusCode(200);
            return res;
        }else if(req.getEndpoint() == cpq.Get_Estimate_URL__c){
            System.debug('In Check Estimate');
            System.debug('req.getEndpoint() ' + req.getEndpoint());
            
            // Create a fake response
            res.setHeader('Authorization', 'abdw');
            res.setBody('{"Message":null,"MessageCode":0,"Parameters":["0061D000007JQKLQA4","null","0"],"ReturnValue":"0"}');
            res.setStatusCode(200);
            return res;
        } else {
            return res;
        }

        
    }
}

