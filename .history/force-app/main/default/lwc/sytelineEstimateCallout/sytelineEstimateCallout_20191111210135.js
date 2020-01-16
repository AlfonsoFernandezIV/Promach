import { LightningElement, track, api, wire } from 'lwc';
import getSytelineCustomSetting from '@salesforce/apex/CPQ_EstimateHelper.getSytelineCustomSetting';
import getOpportunityInfo from '@salesforce/apex/CP';

export default class sytelineEstimateCallout extends LightningElement {
    @api recordId;

    @track setting;
    @track settingError;
    @track token;
    @track tokenError;

    @wire(getSytelineCustomSetting)
    wiredSetting({error, data}){
        if(data){
            this.setting = data;
            console.log(data);
            this.error = undefined;
        } else if (settingError){
            this.settingError = settingError;
            this.setting = undefined;
        }
    }

    @wire(getOpportunityInfo)
    wiredOpportunity(error, data)
}