import { LightningElement, wire, track } from 'lwc';
import getClasses from '@salesforce/apex/classDetailController.getClasses';


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
    { label: 'Spaces Left', fieldName: 'Spaces_Left__c', type: 'number' },
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

export default class ClassList extends LightningElement {

    columnsList = columns;
    @track dataList;
    @track dataListDisplay;
    errors;

    connectedCallback() {
        this.getClassApex();
    }

    //calls apex method imperatively
    getClassApex(){
        getClasses()
        .then(data=>{
            data.forEach(item =>{
                item.RoomName = item.Room__r.Name;
                item.CoachName = item.Coach__r.Name;
                //property used for filtering
                item.classLowerCase = item.Class_Name__c.toLowerCase();
            })
            this.dataList = data;
            //used for table displaying future classes
            this.dataListDisplay = data;
            this.errors = undefined;
            console.log('data:', data);
        }).catch(error =>{
            this.dataList = undefined;
            this.errors = error;
            console.log('error', error);
        })
    }

    //shows classes based on user search input
    handleSearch(event){
        let searchTerm = event.target.value.toLowerCase(); 

        let filteredClassList = this.dataList.filter( item => {
            return item.classLowerCase.includes(searchTerm);
        })

        this.dataListDisplay = filteredClassList;
    }

    handleStartDateTime(event){
        let searchDateTime = event.target.value;
        console.log(searchDateTime)
        let filteredClassList = this.dataList.filter( item => {
            console.log('item', item.Start_DateTime__c)
            return item.Start_DateTime__c >= searchDateTime;
        })

        this.dataListDisplay = filteredClassList;
    }
}