/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
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
        console.log('button clicked');
        checkEstimateExists({oppId: this.recordId})
            .then(result => {
                console.log('recordId ' + this.recordId);
                this.estimateExists = result;
                this.error = undefined;
                if(result === true){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'An Estimate Exists',
                            message: 'An Estimate Exists ' + result,
                            variant: 'success',
                        }),
                    );
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'An Estimate Does Not Exist',
                            message: 'An Estimate Does Not Exist ' + result,
                            variant: 'warning',
                        }),
                    );
                }
            }).catch(error => {
                console.log('recordId ' + this.recordId);
                console.log('error ' + JSON.stringify(error));
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while verify estimate',
                        message: error.message,
                        variant: 'error,'
                    }),
                );
                this.estimateExists = undefined;
            });
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