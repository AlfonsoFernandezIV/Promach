/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import checkEstimateExists from '@salesforce/apex/CPQ_EstimateHelper.checkEstimateExists';

export default class SytelineEstimateCallout extends LightningElement {
    @api recordId;
    @track estimateExists;

    // ----#1 - called when component is created.
    constructor(){
        super();
        console.log('constructor()');
    }

    connectedCallback() {
        this.checkEstimate();
    }

    checkEstimate(){
        checkEstimateExists({oppId: this.recordId})
            .then(result => {
                this.estimateExists = result;
            })
            .catch(error => {
                this.error = error;
            })
    }

    // Check Estimate Exists
    /* @wire(checkEstimateExists, { oppId: '$recordId' }) estimateExists;
     wiredEstimateExists({error, data}){
        if(error){
            console.log('error ' + this.error);
            this.estimateExists = undefined;
            this.error = error;
        } else if (data){
            console.log('data ' + this.data);
            this.estimateExists = data;
            this.error = undefined;
        }
    } */
} 