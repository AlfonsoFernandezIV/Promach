/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import checkEstimateExists from '@salesforce/apex/CPQ_EstimateHelper.checkEstimateExists';
import goToEstimate from '@salesforce/apex/CPQ_EstimateHelper.goToEstimate';
import goToEstimates from '@salesforce/apex/CPQ_EstimateHelper.goToEstimates';
import validateOppAccount from '@salesforce/apex/CPQ_EstimateHelper.validateOppAccount';
import validateOppContact from '@salesforce/apex/CPQ_EstimateHelper.validateOppContact';

export default class SytelineEstimateCallout extends LightningElement {
    @api recordId;
    @track showLoadingSpinner = false;
    @track oppAccountNotValid;
    @track oppAContactNotValid;
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
            validateOppAccount({oppId : this.recordId})
            .then(result => {
                console.log('Is Opp Account Valid? ' + result);
                this.oppAccountNotValid = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.oppAccountNotValid = undefined;
            });
            validateOppContact({oppId : this.recordId})
            .then(result => {
                console.log('Is Opp Contact Valid? ' + result);
                this.oppAContactNotValid = result;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.oppAContactNotValid = undefined;
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