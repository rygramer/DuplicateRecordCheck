/**
 * @description       : Test class for DuplicateRecordCheck
 * @author            : Ryan Mercer
 * @group             : Kicksaw
 * @last modified on  : 12-03-2021
 * @last modified by  : Ryan Mercer
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   06-16-2021   Ryan Mercer   Initial Version
 * 2.0   11-27-2021   Ryan Mercer   Code Optimization
 * 2.5   12-03-2021   Ryan Mercer   Test Simplification
**/
@isTest
public class DuplicateRecordCheck_Test{
    
    //─────────────────────────────────────────────────────────────────┐
    // You'll find two methods below:
    // 1. createDuplicateRecord()
    // 2. createNonDuplicateRecord()
    // Based on your org's Duplicate & Matching Rule configuration,
    // adjust the record data to trigger (or not trigger) your org's rules.
    //─────────────────────────────────────────────────────────────────┘
    private static sObject createDuplicateRecord(){
        // If your org uses the Standard Account Duplicate Rule or Matching Rule
        // you probably don't want to edit this code.
        // If your org uses a custom Duplicate and Matching rule,
        // you will want to edit this code in such a way that the rules will be triggered.
        Account acct = new Account(
            Name = 'Salesforce',
            BillingCity = 'San Francisco',
            ShippingCity = 'San Francisco',
            BillingPostalCode = '94105',
            ShippingPostalCode = '94105',
            Website = 'www.salesforce.com'
        );
        return (sObject) acct;
    }

    private static sObject createNonDuplicateRecord(){
        // If your org uses the Standard Account Duplicate Rule or Matching Rule
        // you probably don't want to edit this code.
        // If your org uses a custom Duplicate and Matching rule,
        // you will want to edit this code in such a way that the rules will NOT be triggered
        // (when compared to the record created by the previous method).
        Account acct = new Account(
            Name = 'Some Other Account'
        );
        return (sObject) acct;
    }

    //─────────────────────────────────────────────────────────────────┐
    // You probably don't want to edit any of the code below this line.
    //─────────────────────────────────────────────────────────────────┘
    
    @TestSetup
    static void testSetup(){
        insert createDuplicateRecord();
    }

    // This should be at least 51 for full test coverage.
    private static Integer NumberOfLoops = 51;

    @isTest
    public static void Duplicate_Test(){
        
        List<DuplicateRecordCheck.Input> inputs = new List<DuplicateRecordCheck.Input>();
        for(Integer i = 1; i <= NumberOfLoops; i++){
            DuplicateRecordCheck.Input input = new DuplicateRecordCheck.Input();
            input.record = createDuplicateRecord();
            inputs.add(input);
        }

        Test.startTest();
        	List<DuplicateRecordCheck.Duplicate> outputs = DuplicateRecordCheck.findDuplicates(inputs);
        Test.stopTest();

        String sObjectName = String.valueOf(createDuplicateRecord().getSObjectType());
        sObject existingRecord = Database.Query('SELECT Id FROM ' + sObjectName + ' LIMIT 1');

        System.assertEquals(NumberOfLoops, outputs.size());
        for(DuplicateRecordCheck.Duplicate output : outputs){
            System.assertEquals(TRUE, output.isDuplicate);
            System.assertEquals(existingRecord.Id, output.duplicateRecordId);
            System.assertEquals(sObjectName, output.duplicatesObjectType);
        }
    }
    
    @isTest
    public static void Non_Duplicate_Test(){
        List<DuplicateRecordCheck.Input> inputs = new List<DuplicateRecordCheck.Input>();
        for(Integer i = 1; i <= NumberOfLoops; i++){
	        DuplicateRecordCheck.Input input = new DuplicateRecordCheck.Input();
            input.record = createNonDuplicateRecord();
            inputs.add(input);
        }

        Test.startTest();
        	List<DuplicateRecordCheck.Duplicate> outputs = DuplicateRecordCheck.findDuplicates(inputs);
        Test.stopTest();
        
        System.assertEquals(NumberOfLoops, outputs.size());
        for(DuplicateRecordCheck.Duplicate output : outputs){
            System.assertEquals(FALSE, output.isDuplicate);
            System.assertEquals(NULL, output.duplicateRecordId);
            System.assertEquals(NULL, output.duplicatesObjectType);
        }
    }

    @isTest
    public static void Comparable_Test(){
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
