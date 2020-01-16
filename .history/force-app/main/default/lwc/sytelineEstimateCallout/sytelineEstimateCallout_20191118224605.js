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
        checkEstimateExists({oppId: '$recordId'})
            .then(result => {
                this.estimateExists = result;
                this.error = undefined;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'An Estimate Exists',
                        message: 'An Estimate Exists' + result,
                        variant: 'success',
                    }),
                );
            }).catch(error => {
                console.log('error ' + error);
                this.error = JSON.Stringify(error);
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