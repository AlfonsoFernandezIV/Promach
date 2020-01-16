/* eslint-disable no-console */
import { LightningElement, track } from 'lwc';
import checkEstimateExists from '@salesforce/apex/CPQ_EstimateHelper.checkEstimateExists';

export default class SytelineEstimateCallout extends LightningElement {
    @track recordId;
    @track retSytelineOppNum;
    @track estimateExists;
    @track estimateNumber;

    /* renderedCallback() {
        this.checkEstimate();
    } */

    accountNameChangeHandler(event){
        this.retSytelineOppNum = event.target.value;
    }

    /* checkEstimate(){
        checkEstimateExists({oppId: this.recordId})
            .then(result => {
                this.estimateExists = result;
                console.log('estimate ' + JSON.stringify(this.estimageExists));
            })
            .catch(error => {
                this.error = error;
            })
    }

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