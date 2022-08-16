public with sharing class classAttendingTriggerHandler {

    //When member signs up for new class, checks whether there is a time or class conflict. 
    public static void checkClassConflict(List<Class_Attending__c> newRecords) {

        //stores member Ids and class Ids
        Set <Id> memberIds = new Set <Id> ();
        Set <Id> classIds = new Set <Id> ();

        //looping through trigger records
        for(Class_Attending__c a : newRecords){
            memberIds.add(a.Members__c);
            classIds.add(a.Class__c);
        }

        //Variables to store Class Id and Class Timings
        Map <Id, DateTime> newclassStartTime = new Map <Id, DateTime> ();
        Map <Id, DateTime> newclassEndTime = new Map <Id, DateTime> ();

        //Queries start and end date/time for classes members were trying to sign up for.
        List<Class__c> classList = [SELECT Id, Start_DateTime__c, End_DateTime__c, Class_Name__c
                                    FROM Class__c
                                    WHERE Id IN :classIds];

        //Mapping class Ids to class start and end date/times                            
        for(Class__c b : classList){
                newclassStartTime.put(b.Id, b.Start_DateTime__c);
                newclassEndTime.put(b.Id, b.End_DateTime__c);
        }

        //Queries classes members are currently enrolled in
        List<Class_Attending__c> memberClasses = [SELECT Id, Class__c, Members__c, Class__r.Start_DateTime__c, 
                                                    Class__r.End_DateTime__c, Class__r.Class_Name__c, Class__r.Name
                                                    FROM Class_Attending__c
                                                    WHERE Members__c IN :memberIds];

        for(Class_Attending__c c : newRecords){
            for(Class_Attending__c d : memberClasses){
                if(d.Members__c == c.Members__c){
                    if(newclassStartTime.get(c.Class__c) != null && newclassEndTime.get(c.Class__c) != null && 
                        d.Class__r.Start_DateTime__c != null && d.Class__r.End_DateTime__c != null ){
                        //class start date/time in trigger record
                        long newStartTime = newclassStartTime.get(c.Class__c).getTime();
                        //class end date/time in trigger record
                        long newEndTime = newclassEndTime.get(c.Class__c).getTime();
                        //class start date/time in already enrolled class
                        long currentStartTime = d.Class__r.Start_DateTime__c.getTime();
                        //class end date/time in already enrolled class
                        long currentEndTime = d.Class__r.End_DateTime__c.getTime();

                        //Determines if member is already enrolled in a class during the same time slot as new class.
                        if((currentStartTime<=newStartTime && newStartTime<=currentEndTime) ||
                            (currentStartTime<=newEndTime && newEndTime<=currentEndTime) || 
                            (currentStartTime>=newStartTime && newEndTime>=currentEndTime)){
                                //error message when conlict is found.
                                c.Class__c.addError('Class conflict. You are already signed up for a class during this time slot. Name: '+d.Class__r.Class_Name__c +' Number: '+d.Class__r.Name);
                        }
                    }
                    else{
                        c.addError('Start and End date/time is missing for record ID '+c.Class__c +' or '+d.Class__c);
                    }

                    //Determines if member is already enrolled in the same class
                    if(c.Class__c == d.Class__c){
                         //error message to display
                         c.Class__c.addError('You are already signed up for this for class. Name: '+d.Class__r.Class_Name__c +' Number: '+d.Class__r.Name);
                    }
                }
            }
        }
    }

    //Handles before update trigger
    public static void beforeUpdateHandler(List<Class_Attending__c> newRecords, map <Id,Class_Attending__c> oldRecordsMap){

        //need to write code for update trigger. Using the code for before insert trigger as a shortcut
        classAttendingTriggerHandler.checkClassConflict(newRecords);
    }

    //Send members email when they successfully sign up to a class
    public static void sendConfirmationEmail(List<Class_Attending__c> newRecords){
        
        //stores member Ids and class Ids
        Set <Id> memberIds = new Set <Id> ();
        Set <Id> classIds = new Set <Id> ();
        //Variable to store multiple emails
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        //looping through trigger records
        for(Class_Attending__c a : newRecords){
            memberIds.add(a.Members__c);
            classIds.add(a.Class__c);
        }

        //Queries class details for classes members signed up for.
        Map<Id, Class__c> classMap = new Map<Id, Class__c> 
            ([SELECT Id, Start_DateTime__c, End_DateTime__c, Room__r.Name, Coach__r.Name, Class_Name__c, Type__c
            FROM Class__c
            WHERE Id IN :classIds]);

        //Queries member details who signed up for a class.
        Map <Id, User> memberMap= new Map <Id, User> 
            ([SELECT Id, FirstName, Email
            FROM User
            WHERE Id IN :memberIds]);


        //looping through trigger records
        for(Class_Attending__c b : newRecords){
            Class__c sClass = classMap.get(b.Class__c);
            User member = memberMap.get(b.Members__c);

            //stores multiple email addresses of a single member
            List<String> emailAddress = new List<String>();
            emailAddress.add(member.Email);

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            //seting email subject
            email.setSubject('Sign up successful for ' +sClass.Class_Name__c);
            //seting send to address
            email.setToAddresses(emailAddress);
            //seting sender display name
            email.setSenderDisplayName('FFC Club');

            //setting email body based on condition
            if(sClass.Type__c == 'In Person'){
                String emailBody = 
                    'Dear ' + member.FirstName + ', <br><br>'+
                    'You have successfully signed up for ' +sClass.Class_Name__c + ' which starts on ' + sClass.Start_DateTime__c.format()
                    + ' and ends on ' + sClass.End_DateTime__c.format() +'. <br>'
                    + 'The class will be held at room ' + sClass.Room__r.Name + ' and we are excited to have you join us this training session. <br><br>'
                    + 'Thanks, <br>'
                    + 'Coach '+ sClass.Coach__r.Name;

                email.setHTMLBody(emailBody);

            }else if(sClass.Type__c == 'Virtual'){
                String emailBody = 
                    'Dear ' + member.FirstName + ', <br><br>'+
                    'You have successfully signed up for ' +sClass.Class_Name__c + ' which starts on ' + sClass.Start_DateTime__c.format()
                    + ' and ends on ' + sClass.End_DateTime__c.format() +'. This is a virtual class and we are excited '
                    +'to have you join us this training session.<br><br>'
                    + 'Thanks, <br>'
                    + sClass.Coach__r.Name;

                email.setHTMLBody(emailBody);
            }

            //adding email to list of emails
            emailList.add(email);
        }
        
        try{
            List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emailList, false);
            for(Messaging.SendEmailResult email : emailResults){
                if(!email.isSuccess()){
                    List<Messaging.SendEmailError> emailError = email.getErrors();
                    eventLogHandler.handleErrors(JSON.serialize(emailError), 'classAttendingTriggerHandler');
                }
            }            
        }catch(System.Exception ex){
            eventLogHandler.handleException(ex, 'classAttendingTriggerHandler');
        }
    }
}