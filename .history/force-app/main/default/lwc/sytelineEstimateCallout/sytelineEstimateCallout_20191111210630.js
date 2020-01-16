import { LightningElement, track, api, wire } from 'lwc';
import getSytelineCustomSetting from '@salesforce/apex/CPQ_EstimateHelper.getSytelineCustomSetting';
import getOpportunityInfo from '@salesforce/apex/CP';

export default class sytelineEstimateCallout extends LightningElement {
    @api recordId;

    @track setting;
    @track settingError;
    @track opp;
    @track oppError;
    @track token;
    @track tokenError;

    @wire(getSytelineCustomSetting)
    wiredSetting({error, data}){
        if(data){
            this.setting = data;
            this.settingError = undefined;
            // eslint-disable-next-line no-console
            console.log('Custom Setting data ' + data);
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
            console.log(opp);
        } else if (settingError){
            this.oppError = error;
            this.opp = undefined;
        }
    }
}