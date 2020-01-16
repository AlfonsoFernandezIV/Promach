import { LightningElement, api } from 'lwc';
import SytelineTokenURL from '@@salesforce/schema/Syteline_CQP__c';
// Example :- import greeting from '@salesforce/label/c.greeting';'

export default class sytelineEstimateCallout extends LightningElement {
    @api recordId;
}