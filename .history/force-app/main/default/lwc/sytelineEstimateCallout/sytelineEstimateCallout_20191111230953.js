/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';
import getSytelineCustomSetting from '@salesforce/apex/CPQ_EstimateHelper.getSytelineCustomSetting';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import getOpportunityInfo from '@salesforce/apex/CPQ_EstimateHelper.getOpportunityInfo';

export default class sytelineEstimateCallout extends LightningElement {
    @api recordId;

    // Vars from Custom setting
    @track setting;
    @track settingError;

    // Vars from Opportunity
    @track opp;
    @track oppError;

    // Vars returned from API call
    @track estimateExists
    @track token;
    @track tokenError;

    tokenURL;
    getEstimateURL;
    createEstimateURL;
    openEstimateURL;

    @wire(getSytelineCustomSetting)
    wiredSetting({error, data}){
        if(data){
            this.setting = data;
            this.tokenURL = data.Token_URL__c;
            this.getEstimateURL = data.Get_Estimate_URL__c;
            this.createEstimateURL = data.Create_Estimate_URL__c;
            this.openEstimateURL = data.Open_Estimate_URL__c;
            this.settingError = undefined;
            console.log('Custom Setting data ' + data.Token_URL__c);
            console.log('Custom Setting setting ' + this.setting);
        } else if (error){
            this.settingError = error;
            this.setting = undefined;
        }
    }

    @wire(getOpportunityInfo)
    wiredOpportunity(error, data){
        if(data){
            this.opp = data;
            this.oppError = undefined;
            console.log('Opportunity info ' + this.opp);
            console.log('Opportunity data ' + data);
        } else if (error){
            this.oppError = error;
            this.opp = undefined;
        }
    }
}