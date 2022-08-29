import { LightningElement, wire, track } from 'lwc';
import getClassesFilter from '@salesforce/apex/classDetailController.getClassesFilter';
import getUpcomingClassesByMember from '@salesforce/apex/classDetailController.getUpcomingClassesByMember';
import userID from '@salesforce/user/Id';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CLASS_ATTENDING_OBJECT from '@salesforce/schema/Class_Attending__c';
import CLASS_FIELD from '@salesforce/schema/Class_Attending__c.Class__c';
import MEMBERS_FIELD from '@salesforce/schema/Class_Attending__c.Members__c';

//Columns for data table
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
    {
        type:  'button', label: 'Button',
        typeAttributes: 
        {
          iconName: 'utility:check',
          label: 'Sign Up', 
          name: 'Sign Up',  
          title: 'Sign Up',
          disabled: {fieldName: 'Button'}, 
          variant: 'success',
        }
      }
];

export default class ClassList extends LightningElement {

    columnsList = columns;
    @track dataList;
    @track dataListDisplay;
    errors;
    //stores class ID's for clases members already signed up to
    registeredClasses = [];
    //used to delay component refresh after user clicks sign up button
    timeoutId;
    //Stores Class Name input by User
    searchClass = null;
    //Stores Class Start Date Time input by User
    searchStartDateTime = null;
    //Stores Date Time Now
    today = new Date().toISOString();


    connectedCallback() {
        this.searchStartDateTime = this.today;
        this.getClassApex();
    }

    //call apex classes async
    async getClassApex() { 
        try {
            await this.upcoming()

            await this.filterClass()
        }//catch for getClassApex
        catch (e) {
            console.log('error getClassApex', e);
        }
        this.refresh = true;
    }

    //imperative apex call. Get upcoming classes user signed up to
    upcoming(){
        getUpcomingClassesByMember({memberId: userID})
            .then(data=>{
                data.forEach(item =>{
                    this.registeredClasses.push(item.Class__c)
                })
                console.log('upcoming2:', data);
                console.log('registered:', this.registeredClasses);
            }).catch(error =>{
                console.log('error getUpcomingClassesByMember', error);
            })
    }


    //imperative apex call. Get classes filtered by user input
    filterClass(){
        getClassesFilter({className: this.searchClass, startDate: this.searchStartDateTime})    
        .then(data=>{
            data.forEach(item =>{
                item.RoomName = item.Room__r.Name;
                item.CoachName = item.Coach__r.Name;
                  //if member is already signed up to class or no space left in class...
                  //sign up button will be disabled
                  if(this.registeredClasses.includes(item.Id) || item.Spaces_Left__c < 1){
                      item.Button = true;
                  }else{
                      item.Button = false;
                  }
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
            console.log('error getClasses', error);
        })
    }

    //shows classes based on user search input
    handleSearch(event){
        this.searchClass = event.target.value.toLowerCase(); 
        this.filterClass()
    }

    handleStartDateTime(event){
        this.searchStartDateTime = event.target.value;
        console.log('date',this.searchStartDateTime);
        this.filterClass()
    }

     //creates class record using uiRecordApi
     joinClass(event){
        const fields = {};
        fields[CLASS_FIELD.fieldApiName] = event.detail.row.Id;
        fields[MEMBERS_FIELD.fieldApiName] = userID;

        const recordInput = { apiName: CLASS_ATTENDING_OBJECT.objectApiName, fields }
        createRecord(recordInput).then(result =>{
            this.showToast(`Success`, `You have signed up for ${event.detail.row.Class_Name__c} ` , 'success', 'persist' )

            //set delay time before data table refreshes
            clearTimeout(this.timeoutId); 
            this.timeoutId = setTimeout(this.refreshComponent.bind(this), 0); 
        }).catch(error=>{
            window.console.log('error message', error, 'sticky');
        
            if(error.body.output.errors.length >0){
                this.err1 = `${error.body.output.errors[0].message}`;

                this.showToast(this.err1, '' , 'error', 'sticky' );
            } else if(error.body.output.fieldErrors ){
                this.err1 = `${Object.values(error.body.output.fieldErrors)[0][0].message}`;

                this.showToast(this.err1, '' , 'error' );
            } else{
                this.showToast('Error', error.body.message , 'error', 'sticky' );
            }
            this.err1 = '';
        })
    }

 
    //toast notifcation message
    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode,
        });
        this.dispatchEvent(event);
    }

    //refreshes page component
    refreshComponent(event){
        eval("$A.get('e.force:refreshView').fire();");
    }
}