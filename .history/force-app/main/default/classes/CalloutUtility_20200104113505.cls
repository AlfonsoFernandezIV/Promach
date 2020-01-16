global without sharing class CalloutUtility {
    public HttpRequest request;
    public Http httpInstance;
    public HttpResponse response;

    private String method;
    private String endpoint;
    private String body;
    private Integer timeout;
    private Map<String, String> headers;
    private Map<String, List<String>> parameters;

    public CalloutUtility(){
        response = new HttpResponse();
        httpInstance = new Http();
        headers = new Map<String, String>();
        parameters = new Map<String, List<String>>();
    }

    // Specifies the endpoint for this request - Required
    public virtual CalloutUtility endpoint(String endpoint){
        this.endpoint = endpoint;
        return this;
    }

    // Adds in the request body. (Example: String Json, String xml)
    public virtual CalloutUtility body(String body){
        this.body = body;
        return this;
    }

    public virtual CalloutUtility bodyToJson(Object o){
        this.body = JSON.serialize(o, true);
        return this;
    }

    public virtual CalloutUtility timeout(Integer timeout){
        this.timeout = timeout;
        return this;
    }

    // Adds a header in the request. 
    public virtual CalloutUtility addHeader(String key, String body){
        this.headers.put(key,body);
        return this;
    }

    // Sets the type of method (GET, POST, ect) to be used for the HTTP request - Required 
    public virtual CalloutUtility method(String method){
        this.method = method;
        return this;
    }

    // Adds one or more headers through the request.
    public virtual CalloutUtility addHeader(Map<String, String> collectionHeaders){
        for(String header : collectionHeaders.keySet()){
            this.headers.put(header, collectionHeaders.get(header));
        }
        return this;
    }

    //Adds a parameter to the URL - Example:http://requesturl.com/myendpoint?key=value
    public virtual CalloutUtility addParameter(String key, String value){
        if(parameters.get(key) == null){
            parameters.put(key, new List<String>());
        }

        parameters.get(key).add(value);

        return this;
    }

    // Dynamically adds the parameters in the URL, respecting the other values ​​added.
    // Example:http://requesturl.com/myendpoint?key1=Apex,SFDC,Rest
    public virtual CalloutUtility addParameter(Map<String, List<String>> collectionParameters){
        System.debug('collectionParameters ' + collectionParameters);
        for(String parameter : collectionParameters.keySet()){
            this.parameters.put(parameter, collectionParameters.get(parameter));
        }
        return this;
    }

    public virtual String buildParameter(String key, List<String> values){
        String parameter = '';
        Integer count = 0;
        for(String value : values){
            count++;
            parameter += value;
            parameter += (count == values.size() ? '' : ',');
        }
        return parameter;
    }

    public virtual String buildQueryStringParameter(){
        String queryString = this.endpoint;

        if(!parameters.isEmpty()){
            queryString += '?';
            Integer count = 0;

            for(String key : parameters.keySet()){
                if(count == 0){
                    queryString += key + '=' + buildParameter(key, parameters.get(key));
                } else {
                    queryString += '&' + key + '=' + buildParameter(key, parameters.get(key));
                }
                count++;
            }
        }
        return queryString;
    }

    public virtual CalloutUtility builder(){
        if(!String.isNotBlank(this.method) || String.isEmpty(this.method)){
            throw new CalloutBaseException('Method not found!');
        }

        if(!String.isNotBlank(this.endpoint) || String.isEmpty(this.endpoint)){
            throw new CalloutBaseException('Endpoint not found');
        }

        if(this.timeout != null && this.timeout > 120000){
            throw new CalloutBaseException('Timeout maximum is exceeded');
        }

        this.request = new HttpRequest();
        this.request.setEndpoint(this.endpoint);
        this.request.setMethod(this.method);

        if(this.body != null){
            this.request.setBody(this.body);
        }

        if(this.timeout != null){
            this.request.setTimeout(this.timeout);
        }

        if(!headers.isEmpty()){
            for(String header : headers.keySet()){
                request.setHeader(header, headers.get(header));
            }
        }

        if(!parameters.isEmpty()){
            this.request.setEndpoint(buildQueryStringParameter());
        }
        System.debug('Callout Request ' + request);
        return this;
    }

    public virtual HttpResponse send(){
        try{
            this.builder();
            response = httpInstance.send(this.request);
            System.debug('Callout Utility Response : ' + response);
        } catch(CalloutBaseException ex){
            throw new CalloutBaseException(ex.getMessage());
        }
        return response;
    }
}