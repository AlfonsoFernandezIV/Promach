/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';
import getSytelineCustomSetting from '@salesforce/apex/CPQ_EstimateHelper.getSytelineCustomSetting';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import OPPORTUNITY_ID_FIELD from '@salesforce/schema/Opportunity.Id';
import OPPORTUNITY_SYTELINE_OPP_NUM_FIELD from '@salesforce/schema/Opportunity.Syteline_Division_Opportunity_Number__c';

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

    @wire(getRecord, { recordId: '$recordId', fields: [OPPORTUNITY_ID_FIELD, OPPORTUNITY_SYTELINE_OPP_NUM_FIELD]})
    opportunity;

    get id(){
        return getFieldValue(this.opportunity.data, OPPORTUNITY_ID_FIELD);
    }

    get sytelineOppNum(){
        return getFieldValue(this.opporunity.Syteline_Division_Opportunity_Number__c, OPPORTUNITY_SYTELINE_OPP_NUM_FIELD)
    }
}