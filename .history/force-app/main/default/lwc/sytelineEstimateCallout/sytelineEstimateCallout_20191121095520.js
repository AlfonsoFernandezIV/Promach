/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import checkEstimateExists from '@salesforce/apex/CPQ_EstimateHelper.checkEstimateExists';
import goToEstimate from '@salesforce/apex/CPQ_EstimateHelper.goToEstimate';
import goToEstimates from '@salesforce/apex/CPQ_EstimateHelper.goToEstimates';
import validateOppFields from '@salesforce/apex/CPQ_EstimateHelper.validateOppFields';

export default class SytelineEstimateCallout extends LightningElement {
    @api recordId;
    @track showLoadingSpinner = false;
    @track oppNotValid;
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
        
            console.log('Opp Checker');
            validateOppFields({oppId : this.recordId})
            .then(result => {
                console.log('Opp Valid? ' + result);
                this.oppNotValid = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.oppNotValid = undefined;
            });
    }    

    goToSyteline(){
        this.showLoadingSpinner = true;
        goToEstimates({oppId : this.recordId})
        .then(result => {
            console.log('result ' + result);
            this.estimateURL = result;
            window.open(this.estimateURL, '_blank');
            this.error = undefined;
            this.showLoadingSpinner = false;
        })
        .catch(error => {
            this.error = error;
            this.estimateUrl = undefined;
        });
    }

    createAnEstimate(){
        this.showLoadingSpinner = true;
        goToEstimate({oppId : this.recordId})
        .then(result => {
            console.log('result ' + result);
            this.estimateUrl = result;
            window.open(this.estimateUrl, '_blank');
            this.error = undefined;
            this.showLoadingSpinner = false;
        })
        .catch(error => {
            this.error = error;
            this.estimateUrl = undefined;
        });
    }
} 