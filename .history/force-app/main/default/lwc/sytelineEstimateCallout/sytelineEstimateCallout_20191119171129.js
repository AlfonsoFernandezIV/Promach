/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
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
        this.showLoadingSpinner = true;
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
                this.showLoadingSpinner = false;
            }).catch(error => {
                this.error = error;
                this.estimateExists = undefined;
            });
    }    

    createAnEstimate(){
        this.showLoadingSpinner = true;
        createEstimate({oppId : this.recordId})
        .then(result => {
            console.log('result ' + result);
            this.estimateUrl = result;
            window.open(this.estimateUrl, '_blank');
            this.error = undefined;
            this.showLoadingSpinner = false;
        })
        .catch(error => {
            this.error = error;
            this.estimateKey = undefined;
        });
    }
} 