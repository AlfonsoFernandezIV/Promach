/* eslint-disable no-console */
import { LightningElement, track, wire } from 'lwc';
import checkEstimateExists from '@salesforce/apex/CPQ_EstimateHelper.checkEstimateExists';

export default class SytelineEstimateCallout extends LightningElement {
    recordId;
    @track sytelineOppNum;
    @track estimateExists;
    @track estimateNumber;

    /* renderedCallback() {
        this.checkEstimate();
    } */
    @wire(checkEstimateExists, {oppId : '$recordId'}) opportunity;

    get sytelineOppNum(){
        if(this.opportunity.data){
            console.log('Opp ' + this.opportunity);
            return this.opportunity.data.fields.Syteline_Division_Opportunity_Number__c.value;
        }
        return undefined;
    }

    validateEstimate(){

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