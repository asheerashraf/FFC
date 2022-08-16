global class deleteClassBatch implements Database.Batchable<sObject>, Database.Stateful{

    //Stores info about records processed
    global integer count = 0;
    global integer success = 0;
    global integer fail = 0;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        //Find classes that have end dates more than 3 months
        String query = 'SELECT  Name, Id FROM Class__c WHERE End_DateTime__c < LAST_N_MONTHS:9 ';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Class__c> classList){
        if(!classList.isEmpty()){
            List<Database.DeleteResult> deleteResult = Database.delete(classList);
            for(Database.DeleteResult a : deleteResult){
                //tallys total records processed
                count++;
                if(a.isSuccess()){
                    //tallys records successfully processed
                    success++;
                }
                if(!a.isSuccess()){
                    List<Database.Error> errors = a.getErrors();
                    //Converting list into string
                    String allErrors = String.join(errors, ',');
                    //calling custom apex class to store error info in Events_Log__c object
                    eventLogHandler.handleErrors(allErrors,'deleteClassBatch');
                    //tallys records failed to process
                    fail++;
                }
            }
        }
    } 

    global void finish(Database.BatchableContext bc){
        
        //Variable to store multiple emails
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        //stores multiple email addresses of a single member
        List<String> emailAddress = new List<String>();
        emailAddress.add('architectasheer@gmail.com');

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        //seting email subject
        email.setSubject('Batch Processing Completed');
        //seting send to address
        email.setToAddresses(emailAddress);
        //seting sender display name
        email.setSenderDisplayName('FFC Sandbox System');
        //setting email body
        email.setHTMLBody('Batch Apex class (deleteClassBatch) has been completed.<br>Total proccesed is: ' +count+ 
                        '<br>Success is: ' + success + '<br>Failed is: ' + fail);
        //adding email to list of emails
        emailList.add(email);
        
        try{
            //Send email notification once batch is completed
            List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emailList, false);
            for(Messaging.SendEmailResult email1 : emailResults){
                if(!email1.isSuccess()){
                    List<Messaging.SendEmailError> emailError = email1.getErrors();
                    eventLogHandler.handleErrors(JSON.serialize(emailError), 'deleteClassBatch');
                }
            }            
        }catch(System.Exception ex){
            //calling custom apex class to store error info in Events_Log__c object
            eventLogHandler.handleException(ex, 'deleteClassBatch');
        }
    }
}