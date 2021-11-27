@isTest
public class DuplicateRecordCheck_Test{
    private static Integer NumberOfLoops = 51;
    private static String City = 'Cabin John';
    private static String Zip = '20818';
    private static String Name = 'Test';
    private static String Website = 'website.com';
    private static String Email = 'test@test.com';
    private static Database.DMLOptions DML = new Database.DMLOptions();
    
    @TestSetup
    static void testSetup(){
        DML.DuplicateRuleHeader.AllowSave = true;
        
        Account acct = new Account(
            Name = Name,
            BillingCity = City,
            ShippingCity = City,
            BillingPostalCode = Zip,
            ShippingPostalCode = Zip,
            Website = Website
        );
        Database.SaveResult accountSaves = Database.insert(acct, DML);
        for(Database.Error error : accountSaves.getErrors()){
            System.debug('testSetup Account insertion error - ' + error);
        }

        Lead lead = new Lead(
            LastName = Name,
            Company = Name,
            City = City,
            PostalCode = Zip,
            Website = Website,
            Email = Email
        );
        Database.SaveResult leadSaves = Database.insert(lead, DML);
        for(Database.Error error : leadSaves.getErrors()){
            System.debug('testSetup Lead insertion error - ' + error);
        }
    }
    
    @isTest
    public static void AccountDupeTest(){
        Account acct = [SELECT Id FROM Account LIMIT 1];
        List<DuplicateRecordCheck.Input> inputs = new List<DuplicateRecordCheck.Input>();
        for(Integer i = 1; i <= NumberOfLoops; i++){
            Account dupeAcct = new Account(
                Name = Name,
                BillingCity = City,
                ShippingCity = City,
                BillingPostalCode = Zip,
                ShippingPostalCode = Zip,
                Website = Website
            );
            DuplicateRecordCheck.Input input = new DuplicateRecordCheck.Input();
            input.record = dupeAcct;
            inputs.add(input);
        }

        Test.startTest();
            system.debug('cpu time limit ' + limits.getLimitCpuTime());
            system.debug('before cpu time limit ' + Limits.getCpuTime());
        	List<DuplicateRecordCheck.Duplicate> outputs = DuplicateRecordCheck.findDuplicates(inputs);
            system.debug('after cpu time limit ' + Limits.getCpuTime());
        Test.stopTest();

        System.assertEquals(NumberOfLoops, outputs.size());
        for(DuplicateRecordCheck.Duplicate output : outputs){
            system.debug(output);

            System.assertEquals(TRUE, output.isDuplicate);
            System.assertEquals(acct.Id, output.duplicateRecordId);
            System.assertEquals(string.valueof(acct.getSObjectType()), output.duplicatesObjectType);
        }
    }
    
    @isTest
    public static void NotaDupeTest(){
        List<DuplicateRecordCheck.Input> inputs = new List<DuplicateRecordCheck.Input>();
        for(Integer i = 1; i <= NumberOfLoops; i++){
            Contact dupeCon = new Contact(
                LastName = Name
            );

	        DuplicateRecordCheck.Input input = new DuplicateRecordCheck.Input();
            input.record = dupeCon;
            inputs.add(input);
        }

        Test.startTest();
            system.debug('cpu time limit ' + limits.getLimitCpuTime());
            system.debug('before cpu time limit ' + Limits.getCpuTime());
        	List<DuplicateRecordCheck.Duplicate> outputs = DuplicateRecordCheck.findDuplicates(inputs);
            system.debug('after cpu time limit ' + Limits.getCpuTime());
        Test.stopTest();
        
        System.assertEquals(NumberOfLoops, outputs.size());
        for(DuplicateRecordCheck.Duplicate output : outputs){
            System.assertEquals(FALSE, output.isDuplicate);
            System.assertEquals(NULL, output.duplicateRecordId);
            System.assertEquals(NULL, output.duplicatesObjectType);
        }
    }

    @isTest
    public static void ComparableTest(){
        List<DuplicateRecordCheck.Duplicate> duplicates = new List<DuplicateRecordCheck.Duplicate>();
        for(Integer i = 1; i <= NumberOfLoops; i++){
            if(i == 1){
                duplicates.add(new DuplicateRecordCheck.Duplicate(FALSE,null,null,null));
            } else {
                duplicates.add(new DuplicateRecordCheck.Duplicate(TRUE,null,null,i));
            }
        }
        duplicates.sort();
        
        Integer counter = NumberOfLoops;
        for(DuplicateRecordCheck.Duplicate duplicate : duplicates){
            system.debug(duplicate.matchConfidence);
            if(counter == 1){
                system.assertEquals(null, duplicate.matchConfidence);
            } else {
                system.assertEquals(counter, duplicate.matchConfidence);
            }
            counter--;
        }
        
    }
}
