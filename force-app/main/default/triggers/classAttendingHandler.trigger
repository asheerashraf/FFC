trigger classAttendingHandler on Class_Attending__c (before insert, after insert, before update) {

    Switch on Trigger.operationtype {
        when BEFORE_INSERT { 
            classAttendingTriggerHandler.checkClassConflict(Trigger.new);   
        }

        when AFTER_INSERT { 
            classAttendingTriggerHandler.sendConfirmationEmail(Trigger.new); 
        }
        
        when BEFORE_UPDATE {
            classAttendingTriggerHandler.beforeUpdateHandler(Trigger.new, Trigger.oldmap);
        } 
    }  

}