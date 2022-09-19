import {LightningElement, api, track, wire} from 'lwc';
import { getPicklistValues, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import getMachine from '@salesforce/apex/Machinist_Controller.getMachine';
import getSObjectTypes from '@salesforce/apex/Machinist_Controller.getSObjectTypes';
import getSObjectDetails from '@salesforce/apex/Machinist_Controller.getSObjectDetails';
import createMachine from '@salesforce/apex/Machinist_Controller.createMachine';

export default class MachinistMachineEditor extends LightningElement {
    @api recordId = '';

    machine = {};
    sObjectTypes;
    @track sObjectFields = [];
    @track recordTypes = [];
    @track transitions = [];
    stateOptions = [];

    _targetSObjectType;
    _isRecordTypeSpecific = false;

    connectedCallback() {
        this.getSObjectTypes();
    }

    @wire(getMachine, {machineId: '$recordId'})
    setMachine({data, error}) {
        if(error) {
            console.error(error);
        }

        if(data) {
            this.machine = {...data};
            this.transitions = this.machine.Transitions__r;
        }
    }

    getSObjectTypes() {
        getSObjectTypes()
            .then(result => { this.sObjectTypes = result; })
            .catch(error => console.error(error));
    }

    @wire(getSObjectDetails, {sObjTypeName: '$targetSObjectType'})
    setSObjectDetails({data, error}) {
        if(error) {
            console.error(error);
            return;
        }

        if(data) {
            this.sObjectFields = data.sObjectFields;
            this.recordTypes = data.recordTypes;
            this._resetSettings();
        }


    fetchPicklistValues() {
        let payload = {
            objectApiName: this.targetSObjectType
        }

        if(this.isRecordTypeSpecific) {
            payload.recordTypeId = this.targetRecordType;
        }

        getPicklistValues(payload)
        .then(stateOptions => {
            this.stateOptions = stateOptions;
        })
        .catch(error => console.error(error));
    }

    createMachine() {
        createMachine({machineConfig: JSON.stringify(this.machine)})
            .then(machine => {
                this.machine = machine;
            })
            .catch(error => console.error(error))
    }

    get machineName() {
        return this.machine.Name;
    }

    set machineName(value) {
        this.machine.Name = value;
    }

    get isSObjectTypeSelected() {
        return this.targetSObjectType === null;
    }

    get hasRecordTypes() {
        return this.recordTypes.length !== 0;
    }

    get isRecordTypeSpecific() {
        return this._isRecordTypeSpecific;
    }

    set isRecordTypeSpecific(value) {
        this._isRecordTypeSpecific = value;
        if(value === false) {
            this.targetRecordType = null;
        }
    }

    get targetSObjectType() {
        return this._targetSObjectType;
    }

    set targetSObjectType(value) {
        this._targetSObjectType = value;
        this.machine.TargetSObjectType__c = value;
    }

    get targetSObjectField() {
        return this.machine.TargetSObjectField__c;
    }

    set targetSObjectField(value) {
        this.machine.TargetSObjectField__c = value;
    }

    get targetRecordType() {
        return this.machine.TargetRecordType__c;
    }

    set targetRecordType(value) {
        this.machine.TargetRecordType__c = value;
    }

    get isMachinePending() {
        return (
            this.machineName !== null
            && this.targetSObjectType !== null
            && this.targetSObjectField !== null
            && (
                !this.isRecordTypeSpecific
                || this.targetRecordType !== null
            )
        )
    }


    setTargetSObjectType(event) {
        this.targetSObjectType = event.detail.value;
    }

    setTargetSObjectField(event) {
        this.targetSObjectField = event.detail.value;
    }

    setTargetRecordType(event) {
        this.targetRecordType = event.detail.value;
    }

    setIsRecordTypeSpecific(_event) {
        this.isRecordTypeSpecific = !this.isRecordTypeSpecific;
    }

    setMachineName(event) {
        this.machineName = event.target.value;
    }

    setRecordId(event) {
        this.recordId = event.target.value;
    }

    _resetSettings() {
        this.targetSObjectField = null;
        this.targetRecordType = null;
        this.isRecordTypeSpecific = false;
    }
}