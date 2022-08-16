import { LightningElement , track, api, wire} from 'lwc';
import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import TYPEACCOUNT_FIELD from '@salesforce/schema/Account.type';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';

import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

import CLASS_OBJECT from '@salesforce/schema/Class__c';
import CLASS_NAME_FIELD from '@salesforce/schema/Class__c.Class_Name__c';
import COACH_FIELD from '@salesforce/schema/Class__c.Coach__c';
import STARTDATETIME_FIELD from '@salesforce/schema/Class__c.Start_DateTime__c';
import ENDDATETIME_FIELD from '@salesforce/schema/Class__c.End_DateTime__c';
import STATUS_FIELD from '@salesforce/schema/Class__c.Status__c';
import TYPE_FIELD from '@salesforce/schema/Class__c.Type__c';
import ROOM_FIELD from '@salesforce/schema/Class__c.Room__c';
import CLASS_SIZE_FIELD from '@salesforce/schema/Class__c.Class_Size__c';

export default class CreateClass extends NavigationMixin(LightningElement)  {

    @api recordId;
    objectApiName = CLASS_OBJECT

    baseFields = [CLASS_NAME_FIELD, COACH_FIELD, CLASS_SIZE_FIELD, STARTDATETIME_FIELD, ENDDATETIME_FIELD, STATUS_FIELD, TYPE_FIELD, ROOM_FIELD, ];

    //used for Coach custom lookup field
    fieldsToCreate = ['FirstName', 'LastName','Type','PersonEmail','Phone']
    fields        = ['Name'];
    filterKey = 'Type = \'Coach\''

    //used for Room custom lookup field
    roomFields = ['Name'];
    roomFieldsToCreate = ['Name', 'Capacity__c']

    //Object to store class record field values
    @track classRecord = {
        Name: '',
        Coach__c: '',
        Start_DateTime__c: null,
        End_DateTime__c: null,
        Class_Size__c: null,
        Room__c: null,
        Status__c: null,
        Type__c: null
    }

    //when records are created captures error for toast notification 
    @track errors;
    err1;
    err2;  

    //stores class record type
    classRecordType;
    //stores class type picklist values
    typePicklist;
     //stores class status picklist values
    statusPicklist

    //getting class object recordTypeId
    @wire(getObjectInfo, { objectApiName: CLASS_OBJECT })
    getClassInfo({error,data}){
       if(data){  
        this.classRecordType = data.defaultRecordTypeId;
        console.log('class fire', this.classRecordType)
       }else if(error){
        console.log('getClassInfo wire error', error)
        }
     };

    //getting class object picklist values
     @wire(getPicklistValuesByRecordType, {recordTypeId: '$classRecordType', objectApiName: CLASS_OBJECT})
        getTypePicklist({error,data}){
            console.log('picklist fire')
        if(data){
          console.log('data picklist', data.picklistFieldValues)
          this.typePicklist = data.picklistFieldValues.Type__c.values;
          this.statusPicklist = data.picklistFieldValues.Status__c.values;

            //setting default status value to 'Draft'
            this.classRecord.Status__c = 'Draft'
        }else if(error){
         console.log('Type Picklist wire error', error)
         }
      };

    //captures values for non-look up fields
    handleChange(event){
        let value = event.target.value;
        let name = event.target.name;
        console.log( 'name', name)
        console.log( 'value', value)

        this.classRecord[name] = value;
        console.log('class record', this.classRecord[name])
        console.log('class record all', this.classRecord)

    }

    //captures values for look-up fields
    handleLookup = (event) => {
        let data = event.detail.data;
        if(data && data.record){
            this.classRecord[data.parentAPIName] = data.record.Id;
            console.log(this.classRecord[data.parentAPIName])
            console.log(data.parentAPIName)
        }else{
            this.classRecord[data.parentAPIName] = undefined;
        }
    }

    //Handler for save button
    saveButton(){
        this.createClass();
    }

    //Handler for cancel button
    cancelButton(){
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Class__c',
                actionName: 'home'
            }
        })
    }


    //creates class record using uiRecordApi
    createClass(){
        const fields = {};
        fields[CLASS_NAME_FIELD.fieldApiName] = this.classRecord['Class_Name__c'];
        fields[CLASS_SIZE_FIELD.fieldApiName] = this.classRecord['Class_Size__c'];
        fields[COACH_FIELD.fieldApiName] = this.classRecord['Coach__c'];
        fields[STARTDATETIME_FIELD.fieldApiName] = this.classRecord['Start_DateTime__c'];
        fields[ENDDATETIME_FIELD.fieldApiName] = this.classRecord['End_DateTime__c'];
        fields[STATUS_FIELD.fieldApiName] = this.classRecord['Status__c'];
        fields[TYPE_FIELD.fieldApiName] = this.classRecord['Type__c'];
        fields[ROOM_FIELD.fieldApiName] = this.classRecord['Room__c'];

        const recordInput = { apiName: CLASS_OBJECT.objectApiName, fields }
        createRecord(recordInput).then(result =>{
            //Navigates user to Class record that was created
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: result.id,
                    actionName: 'view'
                }
            })
            this.showToast('Success', 'Class created' , 'success' )

        }).catch(error=>{
            window.console.log('error message', error);
        
            if(error.body.output.errors.length >0){
                // this.showToast('Error', "wtf" , 'error' );
                this.err1 = `${error.body.output.errors[0].message}`;

                this.showToast(error.body.output.errors[0].errorCode, this.err1 , 'error' );
            } else if(error.body.output.fieldErrors ){
                this.err1 = `error on field: ${Object.values(error.body.output.fieldErrors)[0][0].fieldLabel}. 
                ${Object.values(error.body.output.fieldErrors)[0][0].message}`;

                this.showToast(Object.values(error.body.output.fieldErrors)[0][0].errorCode, this.err1 , 'error' );
            } else{
                this.showToast('Error', error.body.message , 'error' );
            }
            this.err1 = '';
        })
    }

 
    //function for toast notifcation message
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'sticky',
        });
        this.dispatchEvent(event);
    }
}