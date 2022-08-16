public class eventLogHandler {
    public static void handleException(System.Exception exc, String processName){
        Events_Log__c eventLog = new Events_Log__c();
        eventLog.Log_Details__c = exc.getStackTraceString() + '\n' + 'Message: '+exc.getMessage()
            + '\n' + 'Cause: '+ exc.getCause() + '\n' + 'Exception Type: '+exc.getTypeName()
            + '\n' + 'Line Number: '+exc.getLineNumber();
    	eventLog.Log_Date_Time__c = System.now();
        eventLog.Process_Name__c = processName;
        
        insert eventLog;
    }

    public static void handleErrors(String errors, String processName){
        Events_Log__c eventLog = new Events_Log__c();
        eventLog.Log_Details__c = errors;
    	eventLog.Log_Date_Time__c = System.now();
        eventLog.Process_Name__c = processName;
        
        insert eventLog;
    }
}