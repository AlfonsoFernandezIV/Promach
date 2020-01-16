/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import checkEstimateExists from '@salesforce/apex/CPQ_EstimateHelper.checkEstimateExists';
import createEstimate from '@salesforce/apex/CPQ_EstimateHelper.createEstimate';

export default class SytelineEstimateCallout extends LightningElement {
    @api recordId;
    @track showLoadingSpinner = false;
    @track sytelineOppNum;
    @track estimateDoesNotExist;
    @track estimateExists;
    @track estimateNumber;

    connectedCallback(){
        checkEstimateExists({oppId: this.recordId})
            .then(result => {
                console.log('result ' + result);
                if(result){
                    this.estimateDoesNotExist = false;
                    this.estimateExists = true;
                    console.log('this.estimateDoesNotExist ' + this.estimateDoesNotExist);
                } else {
                    console.log('result is false');
                    this.estimateExists = false;
                    this.estimateDoesNotExist = true;
                    console.log('this.estimateExists ' + this.estimateExists);
                }
                //this.estimateExists = result;
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
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while verify estimate',
                        message: error.message,
                        variant: 'error',
                    }),
                );
                this.estimateExists = undefined;
            });
    }    

    createAnEstimate(){
        createEstimate({oppId : this.recordId})
        .then(result => {
            console.log('result ' + result);
            this.estimateKey = result;
            this.error = undefined;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Created an Estimate in Syteline',
                    message: 'Created Estimate : ' + result,
                    variant: 'success',
                }),
            );
        })
        .catch(error => {
            this.error = error;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while verify estimate',
                    message: error.message,
                    variant: 'error',
                }),
            );
            this.estimateKey = undefined;
        });
    }
} 