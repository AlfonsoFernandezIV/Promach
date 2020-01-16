import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import SYTELINE_OPP_NUM from '@salesforce/schema/Opportunity.Syteline_Division_Opportunity_Number__c';
import getSytelineToken from '@salesforce/apex/CPQ_EstimateHelper.getSytelineToken';

export default class sytelineEstimateCallout extends LightningElement {
    //@api recordId;

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

    /* @wire(getSytelineCustomSetting)
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
    } */

    @wire(getSytelineToken)
    wiredToken(data, error){
        if(data.data){
            console.log('1 ' + JSON.stringify(data.data.Token));
            this.token = JSON.stringify(data.data.Token);
            console.log('token ' + this.token);
            this.tokenError = undefined;
        } else if (error){
            this.tokenError = error;
            this.token = undefined
        }
    }
    
    @wire(getRecord, { recordId: this.recordId, fields: [SYTELINE_OPP_NUM]})
        opportunity;

        get syteLineOppNum() {
            return getFieldValue(this.opportunity.data, SYTELINE_OPP_NUM);
        }
}