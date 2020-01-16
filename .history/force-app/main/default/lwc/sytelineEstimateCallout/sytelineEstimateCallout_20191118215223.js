/* eslint-disable no-console */
import { LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
// import checkEstimateExists from '@salesforce/apex/CPQ_EstimateHelper.checkEstimateExists';

const fieldArray = ['Opportunity.Syteline_Division_Opportunity_Number__c']
export default class SytelineEstimateCallout extends LightningElement {
    @track recordId;
    @track retSytelineOppNum;
    @track estimateExists;
    @track estimateNumber;

    /* renderedCallback() {
        this.checkEstimate();
    } */

    @wire(getRecord, {recordId : '$recordId', fields : fieldArray}) opportunity;

    get sytelineOppNum(){
        if(this.opportunity.data){
            return this.opportunity.data.fields.Syteline_Division_Opportunity_Number__c.value;
        }
        return undefined;
    }

    validateEstimate(event){
        console.log('event ' + event);
        this.retSytelineOppNum = event.target.value;
        console.log('retSytelineOppNum ' + event.target.value);
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