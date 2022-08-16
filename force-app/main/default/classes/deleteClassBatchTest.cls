@isTest 
public class deleteClassBatchTest {
    @TestSetup
    public static void testData(){
        List<Class__c> classList = new List<Class__c>();

        for(Integer i = 0; i<300; i++){
            Class__c exClass = new Class__c();
            exClass.Class_Name__c = 'Class '+i;
            exclass.Status__c = 'Draft';

            datetime myDate = datetime.newInstance(2021, 12, 1);
            exClass.End_DateTime__c = myDate;

            classList.add(exClass);
        }

        insert classList;
    }

    @isTest
    static void testDeleteBatch(){
        Test.startTest();
        String jobId = Database.executeBatch(new deleteClassBatch(), 300);
        Test.stopTest();
    } 


}