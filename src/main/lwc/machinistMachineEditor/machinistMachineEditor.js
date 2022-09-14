import {LightningElement, api, track, wire} from 'lwc';
import getMachine from '@salesforce/apex/Machinist_Controller.getMachine';
import getSObjectTypes from '@salesforce/apex/Machinist_Controller.getSObjectTypes';
import getSObjectDetails from '@salesforce/apex/Machinist_Controller.getSObjectDetails';

export default class MachinistMachineEditor extends LightningElement {
    @api recordId;

    machine = {};
    sObjectTypes;
    @track sObjectFields = [];
    @track recordTypes = [];

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
            this.machine = data;
            console.log(data);
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
        this.machine.targetSObjectType = value;
    }

    get targetSObjectField() {
        return this.machine?.targetSObjectField;
    }

    set targetSObjectField(value) {
        this.machine.targetSObjectField = value;
    }

    get targetRecordType() {
        return this.machine?.targetRecordType;
    }

    set targetRecordType(value) {
        this.machine.targetRecordType = value;
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

    _resetSettings() {
        this.targetSObjectField = null;
        this.targetRecordType = null;
        this.isRecordTypeSpecific = false;
    }
}