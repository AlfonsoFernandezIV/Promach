/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getSytelineCustomSetting from '@salesforce/apex/CPQ_EstimateHelper.getSytelineCustomSetting';
import getSytelineToken from '@salesforce/apex/CPQ_EstimateHelper.getSytelineToken';

const FIELDS = [
    'Opportunity.Id',
    'Opportunity.Syteline_Division_Opportunity_Number__c'
];

export default class sytelineEstimateCallout extends LightningElement {
    @api recordId;

    // Vars from Custom setting
    @track setting;
    @track settingError;

    // Vars from Opportunity
    @track opportunity;
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

    @wire(getSytelineToken)
    wiredToken(error, data){
        if(data){
            console.log('token data ' + JSON.stringify(data));
            console.log('token message ' + JSON.stringify(data.Message));
            console.log('token token ' + JSON.stringify(data.Token));
            /* console.log('token message ' + JSON.stringify(data.get('Message')));
            console.log('token token ' + JSON.stringify(data.get('Token'))); */
            this.token = data.value;
            this.tokenError = undefined;
        } else if (error){
            console.log('token error ' + JSON.stringify(error));
            this.tokenError = error;
            this.token = undefined
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS})
    opportunity;

    get id(){
        return this.opportunity.data.fields.Id.value;
    }

    get sytelineOppNum(){
        return this.opportunity.data.fields.Syteline_Division_Opportunity_Number__c.value;
    }
}