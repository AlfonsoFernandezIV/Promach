public with sharing class BatchCreateApexSharingRules implements Database.Batchable<sObject>{

    private final Id zipMgmtUserId;
    
    public BatchCreateApexSharingRules(Id zipUserId) {
        this.zipMgmtUserId = zipUserId;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){

    }

    public void execute(Database.BatchableContext BC, List<sObject> batch){

    }

    public void finish(Database.BatchableContext BC){
        
    }
}
