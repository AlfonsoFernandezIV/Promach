/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import SYTELINE_OPP_NUM_FIELD from '@salesforce/schema/Opportunity.Syteline_Division_Opportunity_Number__c';
import getSytelineToken from '@salesforce/apex/CPQ_EstimateHelper.getSytelineToken';
import getOpportunityInfo from '@salesforce/apex/CPQ_EstimateHelper.getOpportunityInfo';

const fields = [SYTELINE_OPP_NUM_FIELD];

export default class SytelineEstimateCallout extends LightningElement {
    @api recordId;
    @api objectApi;
    @track estimateExists;
    @track opportunity;
    @track token;
    @track tokenError;

    sytelineOppNum = SYTELINE_OPP_NUM_FIELD;

    @wire(getRecord, {recordId: '$recordId', fields}) opportunity;

    get oppNum(){
        return getFieldValue(this.opportunity.data, SYTELINE_OPP_NUM_FIELD);
    }

    @wire (checkEstimateExists)
    wiredEstimateExists(data, error){
        console.log('data ' + data);
        console.log('error ' + error);
    }
    
    // Vars returned from API call
    

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
    
}