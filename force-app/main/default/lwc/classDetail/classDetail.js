import { LightningElement, api, track } from 'lwc';
import getCoach from '@salesforce/apex/classDetailController.getCoach';
import getMembers from '@salesforce/apex/classDetailController.getMembers';

const columns = [
    { label: 'Name', fieldName: 'Name'},
    { label: 'Email', fieldName: 'Email', type: 'email' },
    { label: 'Phone', fieldName: 'Phone', type: 'phone' },
];

export default class ClassDetail extends LightningElement {

    // Flexipage provides recordId and objectApiName
    @api recordId;
    @api objectApiName;
    @track coachList;
    @track memberList;
    errorsCoach;
    errorsMember

    columnsList = columns;

    coachTabHandler(){
        getCoach({classId : this.recordId})
        .then(result =>{
            result.forEach((item) =>{
                item.Name = item.Coach__r.Name ? item.Coach__r.Name : "NA";
                item.Email = item.Coach__r.PersonEmail ? item.Coach__r.PersonEmail : "NA"; 
                item.Phone = item.Coach__r.Phone ? item.Coach__r.Phone : "NA"; 
            })

            this.coachList = result;
            this.errorsCoach = undefined;
            console.log('coach', result)
        }).catch(error=>{
            this.errorsCoach = error;
            this.coachList = undefined;
        })
    }

    memberTabHandler(){
        getMembers({classId : this.recordId})
        .then(result =>{
            result.forEach((item) =>{
                item.Name = item.Members__r.Name ? item.Members__r.Name : "NA";
                item.Email = item.Members__r.PersonEmail ? item.Members__r.PersonEmail : "NA"; 
                item.Phone = item.Members__r.Phone ? item.Members__r.Phone : "NA"; 
            })
            if(result.length >0){
                this.memberList = result;
            }else{
                this.memberList = undefined;
            }
            this.errorsMember = undefined;
            
        }).catch(error=>{
            this.errorsMember = error;
            this.memberList = undefined;
        })
    }
}