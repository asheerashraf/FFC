@isTest 
public class classAttendingHandlerTest{
    @TestSetup
    public static void testData(){

        List<Account> accountList = new List<Account>();
        List<User> userList = new List<User>();
        List<Class__c> classList = new List<Class__c>();
        List<Class_Attending__c> classAttendingList = new List<Class_Attending__c>();
        List<Room__c> roomList = new List<Room__c>();

        String recordTypeId  = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('FFC Coach').getRecordTypeId();
        system.debug(recordTypeId);

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<User> uu = new List<User>();
        //Creating User Member 1
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
        User u = new User(Alias = uid, Email= 'andrew.jennings@gmail.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York', UserName= uid + '@myorg.com');      
        uu.add(u);
        //Creating User Member 2
        Blob a = Crypto.GenerateAESKey(128);
        String c = EncodingUtil.ConvertTohex(a);
        String cid = c.SubString(0,8);
        User u2 = new User(Alias = cid, Email= cid + '@myorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/New_York', UserName= cid + '@myorg.com');      


        uu.add(u2);
        //Inserting User Records
        insert(uu);
        
        //Creating Account Record for FFC Coach
        Account Coach = new Account();
        Coach.RecordTypeID = recordTypeId;
        Coach.FirstName = 'Joy';
        Coach.LastName = 'Miles';
        Coach.PersonEmail = 'joy.miles@gmail.com';
        accountList.add(Coach);

        //Inserting Account Records
        insert accountList;
        
        //Creating Room Record 1
        Room__c room = new Room__c();
        room.Name = 'Workout Room';
        room.Capacity__c = 40;
        //Creating Room Record 2
        Room__c room2 = new Room__c();
        room2.Name = 'Virtual';
        room2.Capacity__c = 100;

        roomList.add(room);
        roomList.add(room2);
        //Inserting Room Records
        insert roomList;

        //Creating Class 1 Record 
        Class__c class1 = new Class__c();
        class1.Class_Name__c = 'Tabata';
        class1.Class_Size__c = 30;
        class1.Coach__c = Coach.Id;
        class1.Start_DateTime__c = datetime.now();
        class1.End_DateTime__c = datetime.now().addMinutes(30);
        class1.Type__c = 'In person';
        class1.Status__c = 'Published';
        class1.Room__c = room.Id;

        Class__c class2 = new Class__c();
        class2.Class_Name__c = 'Boxing';
        class2.Class_Size__c = 10;
        class2.Coach__c = Coach.Id;
        class2.Start_DateTime__c = datetime.now().addMinutes(60);
        class2.End_DateTime__c = datetime.now().addMinutes(90);
        class2.Type__c = 'Virtual';
        class2.Status__c = 'Published';
        class2.Room__c = room2.Id;

        Class__c class3 = new Class__c();
        class3.Class_Name__c = 'Sweat';
        class3.Class_Size__c = 30;
        class3.Coach__c = Coach.Id;
        class3.Start_DateTime__c = datetime.now();
        class3.End_DateTime__c = datetime.now().addMinutes(45);
        class3.Type__c = 'In person';
        class3.Status__c = 'Published';
        class3.Room__c = room.Id;

        Class__c class4 = new Class__c();
        class4.Class_Name__c = 'Free';
        class4.Class_Size__c = 30;
        class4.Coach__c = Coach.Id;
        class4.Start_DateTime__c = datetime.now().addMinutes(180);
        class4.End_DateTime__c = datetime.now().addMinutes(240);
        class4.Type__c = 'In person';
        class4.Status__c = 'Published';
        class4.Room__c = room.Id;

        classList.add(class1);
        classList.add(class2);
        classList.add(class3);
        classList.add(class4);
        //Inserting Class Records
        insert classList;

        //Creating Class Attending Record 1
        Class_Attending__c classAttending1 = new Class_Attending__c();
        classAttending1.Class__c = class1.Id;
        classAttending1.Members__c = u.Id;

        //Creating Class Attending Record 2 
        Class_Attending__c classAttending2 = new Class_Attending__c();
        classAttending2.Class__c = class2.Id;
        classAttending2.Members__c = u2.Id;

        //Creating Class Attending Record 3
        Class_Attending__c classAttending3 = new Class_Attending__c();
        classAttending3.Class__c = class4.Id;
        classAttending3.Members__c = u.Id;

        classAttendingList.add(classAttending1);
        classAttendingList.add(classAttending2);
        classAttendingList.add(classAttending3);
        //Inserting Class Attending Records
        List <Database.SaveResult> lsr = Database.insert(classAttendingList, false);
        //Updating Class Attending Records
        classAttending3.Members__c = u2.Id;
        Database.SaveResult lsr2 = Database.update(classAttending3, false);
    }

    @isTest
    static void sendEmailTest(){
    }

    @isTest
    static void timeSlotConflict(){
        Test.startTest(); 
        User Andrew = [SELECT Id FROM User WHERE Email = 'andrew.jennings@gmail.com'];
        Class__c sc = [SELECT Id FROM Class__c WHERE Class_Name__c = 'Sweat'];

        Class_Attending__c classAttending = new Class_Attending__c();
        classAttending.Class__c = sc.Id;
        classAttending.Members__c = Andrew.Id;

        Database.SaveResult insertResult = Database.insert(classAttending, false);
        Test.stopTest(); 
    }

    @isTest
    static void sameClassSignUpConflict(){
        Test.startTest(); 
        User Andrew = [SELECT Id FROM User WHERE Email = 'andrew.jennings@gmail.com'];
        Class__c sc = [SELECT Id FROM Class__c WHERE Class_Name__c = 'Tabata'];

        Class_Attending__c classAttending = new Class_Attending__c();
        classAttending.Class__c = sc.Id;
        classAttending.Members__c = Andrew.Id;

        Database.SaveResult insertResult = Database.insert(classAttending, false);
        Test.stopTest(); 
    }

    @isTest
    static void noDateTimeClassConflict(){
        Test.startTest(); 
        User Andrew = [SELECT Id FROM User WHERE Email = 'andrew.jennings@gmail.com'];
        Class__c classDraft = new Class__c();
        classDraft.Class_Name__c = 'No Date';
        classDraft.Status__c = 'Draft';

        insert classDraft;

        Class_Attending__c classAttending = new Class_Attending__c();
        classAttending.Class__c = classDraft.Id;
        classAttending.Members__c = Andrew.Id;

        Database.SaveResult insertResult = Database.insert(classAttending, false);
        Test.stopTest(); 
    }
}