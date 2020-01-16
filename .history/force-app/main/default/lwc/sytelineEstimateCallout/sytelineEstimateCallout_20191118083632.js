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

    renderedCallback() {
        this.checkEstimate();
    }

    checkEstimate(){
        checkEstimateExists({oppId: this.recordId})
            .then(result => {
                this.estimateExists = result;
                console.log('estimate ' + JSON.stringify(this.estimageExists));
            })
            .catch(error => {
                this.error = error;
            })
    }

   
} 