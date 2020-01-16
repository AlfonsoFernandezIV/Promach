/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';
import checkEstimateExists from '@salesforce/apex/CPQ_EstimateHelper.checkEstimateExists';

export default class SytelineEstimateCallout extends LightningElement {
    @api recordId;
    @api objectApi;
    @track estimateExists;
    @track opportunity;
    @track token;
    @track tokenError;

    // Check Estimate Exists
    @wire(checkEstimateExists, { oppId: '$recordId' }) estimateExists;

    /* estimateExists({error, data.data}){
        console.log(data);
        this.estimateExists = data;
        this.error = error;
    }*/
} 