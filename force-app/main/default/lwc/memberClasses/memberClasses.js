import { LightningElement, track, api } from 'lwc';
import getUpcomingClassesByMember from '@salesforce/apex/classDetailController.getUpcomingClassesByMember';
import getPastClassesByMember from '@salesforce/apex/classDetailController.getPastClassesByMember';
// gets current User Id using LWC Scoped Module
import userID from '@salesforce/user/Id';

const columns = [
    { label: 'Class Name', fieldName: 'Class_Name__c',
        cellAttributes: {
            iconeName: "standard:event",
            iconPosition: "left"
        }    
    },
    { label: 'Coach', fieldName: 'CoachName',
        cellAttributes: {
            iconeName: "standard:user",
            iconPosition: "left"
        }    
    },
    { label: 'Room', fieldName: 'RoomName' },
    { label: 'Start Time (CDT)', fieldName: 'Start_DateTime__c', type: 'date',
        typeAttributes:{
            year: "numeric",
            month: "2-digit",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit"
        } 
    },
    { label: 'End Time (CDT)', fieldName: 'End_DateTime__c', type: 'date',
        typeAttributes:{
            year: "numeric",
            month: "2-digit",
            day: "2-digit",
            hour: "2-digit",
            minute: "2-digit"
        } 
    },
];

export default class MemberClasses extends LightningElement {
    //data table columns for class data
    columnsList = columns;
    //stores upcoming classes data
    @track dataUpcomingList;
    //displays upcoming classes data
    @track dataUpcomingListDisplay;
    //stores past classes data
    @track dataPastList;
    //displays past classes data
    @track dataPastListDisplay;
    //stores upcoming classes wire error
    errors;
    //stores past classes wire error
    errors2;

    @api recordId

    connectedCallback() {
        this.getClassApex();
        console.log('user', userID)
    }

    //calls apex method imperatively
    getClassApex(){
        getUpcomingClassesByMember({memberId: userID})
        .then(data=>{
            data.forEach(item =>{
                item.RoomName = item.Class__r.Room__r.Name;
                item.CoachName = item.Class__r.Coach__r.Name;
                item.Start_DateTime__c = item.Class__r.Start_DateTime__c;
                item.End_DateTime__c = item.Class__r.End_DateTime__c;
                item.Class_Name__c = item.Class__r.Class_Name__c;
            })
            console.log('upcoming',data);
            this.dataUpcomingList = data;
            //used for table displaying future classes
            this.dataUpcomingListDisplay = data;
            this.errors = undefined;
        }).catch(error =>{
            this.dataUpcomingList = undefined;
            this.errors = error;
            console.log('upcoming error',error);
        })

        getPastClassesByMember({memberId: userID})
        .then(data=>{
            data.forEach(item =>{
                item.RoomName = item.Class__r.Room__r.Name;
                item.CoachName = item.Class__r.Coach__r.Name;
                item.Start_DateTime__c = item.Class__r.Start_DateTime__c;
                item.End_DateTime__c = item.Class__r.End_DateTime__c;
                item.Class_Name__c = item.Class__r.Class_Name__c;
            })
            this.dataPastList = data;
            //used for table displaying future classes
            this.dataPastListDisplay = data;
            this.errors2 = undefined;
        }).catch(error =>{
            this.dataPastList = undefined;
            this.errors2 = error;
        })
    }

}