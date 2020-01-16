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
    /* @wire(checkEstimateExists, { oppId: '$recordId' }) estimateExists;
    wiredEstimateExists({error, data}){
        if(error){
            console.log('error ' + this.error);
        } else if (data){
            console.log('data ' + this.data);
        }
    } */


} 