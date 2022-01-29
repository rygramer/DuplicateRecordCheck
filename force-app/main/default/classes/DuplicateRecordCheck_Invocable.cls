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
    public static List<Output> findDuplicates(List<Input> inputs){

        List<sObject> listsObjectsToCheck = new List<sObject>();
        for(Input input : inputs){
            if(input.record != null) listsObjectsToCheck.add(input.record);
            if(input.records != null) listsObjectsToCheck.addAll(input.records);
        }

        List<Duplicate> duplicates = DuplicateRecordCheck_Util.findDuplicates(listsObjectsToCheck);

        List<Output> outputs = new List<Output>();
        for(Input input : inputs){
            Output output = new Output();
            if(input.record != null){
                output.duplicate = duplicates.remove(0);
            }

            if(input.records != null){
                output.duplicates = new List<Duplicate>();
                for(sObject record : input.records){
                    output.duplicates.add(duplicates.remove(0));
                }
            }

            outputs.add(output);
        }

        return outputs;
    }

    /**
    * @description Wrapper class for invocable inputs
    **/
    public class Input{
        @InvocableVariable(label='Single Record to Check for Duplicates')
        public sObject record;

        @InvocableVariable(label='Collection of Records to Check for Duplicates')
        public List<sObject> records;
    }

    public class Output{
        @InvocableVariable(label='Duplicate Result from Single Record')
        public Duplicate duplicate;

        @InvocableVariable(label='Duplicate Results from Collection of Records')
        public List<Duplicate> duplicates;
    }
}