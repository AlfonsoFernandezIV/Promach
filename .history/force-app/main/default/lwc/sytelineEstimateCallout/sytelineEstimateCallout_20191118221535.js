/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import checkEstimateExists from '@salesforce/apex/CPQ_EstimateHelper.checkEstimateExists';

export default class SytelineEstimateCallout extends LightningElement {
    @api recordId;
    @track sytelineOppNum;
    @track estimateExists;
    @track estimateNumber;

    successHandler(event){
        this.recordId = event.detail.id;
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

    /* renderedCallback() {
        this.checkEstimate();
    } */
    
    /* 

    createEstimate(event){
        console.log('create');

        this.createEstimate({oppId: this.recordId})
            .then(result => {
                this.contacts = result;
                this.error = undefined;
            })
            .catch(error=> {
                this.error = error;
                this.contacts = undefined;
            })
    } */

    
} 