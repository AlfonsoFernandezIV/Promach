/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';
import getSytelineCustomSetting from '@salesforce/apex/CPQ_EstimateHelper.getSytelineCustomSetting';
import getOpportunityInfo from '@salesforce/apex/CPQ_EstimateHelper.getOpportunityInfo';

export default class sytelineEstimateCallout extends LightningElement {
    @api recordId;

    @track setting;
    @track settingError;
    @track opp;
    @track oppError;
    @track token;
    @track tokenError;
    tokenURL;

    @wire(getSytelineCustomSetting)
    wiredSetting({error, data}){
        if(data){
            this.setting = data;
            this.tokenURL = data.Token_URL__c;
            this.settingError = undefined;
            console.log('Custom Setting data ' + data.Token_URL__c);
            console.log('Custom Setting setting ' + this.setting);
        } else if (error){
            this.settingError = error;
            this.setting = undefined;
        }
    }

    @wire(getOpportunityInfo)
    wiredOpportunity(error, data){
        if(data){
            this.opp = data;
            this.oppError = undefined;
            console.log('Opportunity info ' + this.opp);
            console.log('Opportunity data ' + data);
        } else if (error){
            this.oppError = error;
            this.opp = undefined;
        }
    }
}