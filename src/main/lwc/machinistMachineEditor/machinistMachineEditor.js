import {LightningElement, api, track} from 'lwc';
import newMachine from '@salesforce/apex/Machinist_Controller.newMachine';
import getSObjectTypeDetails from '@salesforce/apex/Machinist_Controller.getSObjectTypeDetails';

export default class MachinistMachineEditor extends LightningElement {
    @api machine = {};
    @track isRecordTypeSpecific = false;
    @track sObjectTypeOptions = [];
    @track sObjectFieldOptions = [];
    @track recordTypeOptions = [];

    connectedCallback() {
        newMachine()
            .then(machineEditor => {
                this.machine = machineEditor.machine;
                this.sObjectTypeOptions = machineEditor.sObjectTypeOptions;
            })
            .catch(error => {

            })
    }

    getSObjectTypeDetails() {
        getSObjectTypeDetails()
            .then(details => {
                this.sObjectFieldOptions = details.sObjectFieldOptions;
                this.recordTypeOptions = details.recordTypeOptions;
            })
            .catch(error => {});
    }

    toggleIsRecordTypeSpecific() {
        this.isRecordTypeSpecific = !this.isRecordTypeSpecific;
    }

}