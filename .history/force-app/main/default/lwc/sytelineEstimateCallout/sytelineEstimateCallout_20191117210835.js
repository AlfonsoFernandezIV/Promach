/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import SYTELINE_OPP_NUM_FIELD from '@salesforce/schema/Opportunity.Syteline_Division_Opportunity_Number__c';
import getSytelineToken from '@salesforce/apex/CPQ_EstimateHelper.getSytelineToken';
import checkEstimateExists from '@salesforce/apex/CPQ_EstimateHelper.checkEstimateExists';
// import getOpportunityInfo from '@salesforce/apex/CPQ_EstimateHelper.getOpportunityInfo';

const fields = [SYTELINE_OPP_NUM_FIELD];

export default class SytelineEstimateCallout extends LightningElement {
    @api recordId;
    @api objectApi;
    @track estimateExists;
    @track opportunity;
    @track token;
    @track tokenError;

    sytelineOppNum = SYTELINE_OPP_NUM_FIELD;

    // Check Estimate Exists
    @wire (checkEstimateExists)
    wiredEstimateExists(data, error){
        console.log('data ' + data);
        console.log('error ' + error);
    } 
}