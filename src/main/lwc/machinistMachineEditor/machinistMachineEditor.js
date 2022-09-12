import {LightningElement, api, track} from 'lwc';

export default class MachinistMachineEditor extends LightningElement {
    @api machineName;
    @api sObjectType;
    @api stateField;
    @track transitions = [];


}