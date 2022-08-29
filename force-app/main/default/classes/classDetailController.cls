public with sharing class classDetailController {

    //gets list of members signed up to each class
    @AuraEnabled
    public static List<Class_Attending__c> getMembersByClass (String classId){
        List<Class_Attending__c> memberList = [SELECT Id, Members__r.Name, Members__r.email, Members__r.phone
                                    FROM Class_Attending__c
                                    WHERE Class__c = :classId
                                    WITH SECURITY_ENFORCED];
        return memberList;
    }

    //gets list of upcoming classes each member has signed up 
    @AuraEnabled
    public static List<Class_Attending__c> getUpcomingClassesByMember (String memberId){
        //UTC time now in ISO format
        DateTime today = datetime.now();
        List<Class_Attending__c> classList = [SELECT Id, Class__r.Name, Class__r.Class_Name__c, Class__r.Coach__r.Name, Class__r.Start_DateTime__c,
                                    Class__r.End_DateTime__c, Class__r.Room__r.Name
                                    FROM Class_Attending__c
                                    WHERE Members__c = :memberId
                                    AND Class__r.Start_DateTime__c >= :today
                                    WITH SECURITY_ENFORCED];
        return classList;
    }

    //gets list of past classes each member has signed up 
    @AuraEnabled
    public static List<Class_Attending__c> getPastClassesByMember (String memberId){
        //UTC time now in ISO format
        DateTime today = datetime.now();
        List<Class_Attending__c> classList = [SELECT Id, Class__r.Class_Name__c, Class__r.Coach__r.Name, Class__r.Start_DateTime__c,
                                    Class__r.End_DateTime__c, Class__r.Room__r.Name
                                    FROM Class_Attending__c
                                    WHERE Members__c = :memberId
                                    AND Class__r.Start_DateTime__c <= :today
                                    WITH SECURITY_ENFORCED];
        return classList;
    }

    //gets list of coaches assigned to a class
    @AuraEnabled
    public static List<Class__c> getCoach(String classId){
        List<Class__c> coachList = [SELECT Coach__r.Name, Coach__r.FirstName, Coach__r.lastName, Coach__r.id, 
                        Coach__r.personemail, Coach__r.phone 
                        FROM Class__c
                        WHERE Id = :classId
                        WITH SECURITY_ENFORCED];

        return coachList;
    }

    /*gets list of upcoming class (old)
    @AuraEnabled
    public static List<Class__c> getClasses(){
        DateTime today = datetime.now();
        List<Class__c> classList = [SELECT Id, Name, Class_Name__c, Room__r.Name, Spaces_Left__c, 
                        Start_DateTime__c, Coach__r.Name, End_DateTime__c
                        FROM Class__c
                        WHERE Start_DateTime__c >= :today
                        WITH SECURITY_ENFORCED];

        return classList;
    } */

        //gets list of upcoming class
        @AuraEnabled
        public static List<sObject> getClassesFilter(String className, DateTime startDate){
            DateTime today = datetime.now();
            List<String> condition = new List<String>();
            String whereC = ' ';

            //Query class date starting today and after
            if(startDate < today){
                condition.add('Start_DateTime__c >= :today');
            }else{
                condition.add('Start_DateTime__c >= :startDate');
            }
            
            //Query class by Name
            if(!String.isEmpty(className)){
                String classNameSearch = '%'+className+'%';
                condition.add('Class_Name__c LIKE :classNameSearch');
            }

            if(condition.size() > 0){
                whereC = ' WHERE '+String.join( condition, ' AND ' );
            }
             
            String query = 'SELECT Id, Name, Class_Name__c, Room__r.Name, Spaces_Left__c, '+ 
                            'Start_DateTime__c, Coach__r.Name, End_DateTime__c ' +
                            'FROM Class__c' + whereC + ' WITH SECURITY_ENFORCED';

            return Database.query(query);
        }
}