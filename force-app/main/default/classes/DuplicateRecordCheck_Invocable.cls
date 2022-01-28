/**
 * @description       : Contains the Invocable Method that runs the duplicate rules on a particular record or recordId to see if a duplicate record exists.
 * @author            : Ryan Mercer
 * @last modified on  : 01-27-2022
 * @last modified by  : Ryan Mercer
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   06-16-2021   Ryan Mercer   Initial Version
 * 2.0   11-27-2021   Ryan Mercer   Code Optimization
 * 3.0   01-27-2022   Ryan Mercer   Implementing Dependency Injection
**/

public with sharing class DuplicateRecordCheck_Invocable{
    /**
    * @description Invocable Method that runs the duplicate rules on a particular record or recordId to see if a duplicate record exists.
    * @author Ryan Mercer | 01-27-2022
    * @param List<Input> inputs 
    * @return List<Duplicate> 
    **/
    @InvocableMethod(
        label='Check for Duplicate Records'
        description='Runs the duplicate rules on a particular record or recordId to see if a duplicate record exists.'
        category='Duplicate Record Check'
    )
    public static List<DuplicateRecordCheck_Util.Duplicate> findDuplicates(List<Input> inputs){

        List<sObject> listsObjectsToCheck = new List<sObject>();
        for(Input input : inputs){
            listsObjectsToCheck.add(input.record);
        }

        return DuplicateRecordCheck_Util.findDuplicates(listsObjectsToCheck);
    }

    /**
    * @description Wrapper class for invocable inputs
    **/
    public class Input{
        @InvocableVariable(label='Record to Check for Duplicates' required=TRUE)
        public sObject record;
    }
}