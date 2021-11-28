/**
 * @description       : Runs the duplicate rules on a particular record or recordId to see if a duplicate record exists.
 * @author            : Ryan Mercer
 * @group             : Kicksaw
 * @last modified on  : 11-27-2021
 * @last modified by  : Ryan Mercer
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   06-16-2021   Ryan Mercer   Initial Version
 * 1.0   11-27-2021   Ryan Mercer   Code Optimization
**/

public with sharing class DuplicateRecordCheck{
    /**
    * @description Invocable Method that runs the duplicate rules on a particular record or recordId to see if a duplicate record exists.
    * @author Ryan Mercer | 11-27-2021 
    * @param List<Input> inputs 
    * @return List<Duplicate> 
    **/
    @InvocableMethod(
        label='Check for Duplicate Records'
        description='Runs the duplicate rules on a particular record or recordId to see if a duplicate record exists.'
        category='Kicksaw'
    )
    public static List<Duplicate> findDuplicates(List<Input> inputs){
        
        // The documentation states that the input array for the findDuplicates method is 50.
        // We are instantiating a new list to house the results in case we have to execute the method multiple times.
        List<Datacloud.FindDuplicatesResult> results = new List<Datacloud.FindDuplicatesResult>();
        List<sObject> listsObjectsToCheck = new List<sObject>();
        for(Input input : inputs){
            listsObjectsToCheck.add(input.record);
            
            // Check to see if the list size equals 50.
            // If so, execute the findDuplicates method and clear the list.
            if(listsObjectsToCheck.size() == 50){
                results.addAll(Datacloud.FindDuplicates.findDuplicates(listsObjectsToCheck));
                listsObjectsToCheck.clear();
            }
        }

        // Execute the findDuplicates method a final time.
        if(!listsObjectsToCheck.isEmpty()){
            results.addAll(Datacloud.FindDuplicates.findDuplicates(listsObjectsToCheck));
        }

        // The mapIndexToDuplicate is a map where the key is the index and the value is the best Duplicate result (if any exist).
        Integer index = 0;
        Map<Integer,Duplicate> mapIndexToDuplicate = new Map<Integer,Duplicate>();
        for(Datacloud.FindDuplicatesResult find : results) {
            // Add the default Duplicate to the map, which is simply Duplicate.isDuplicate = FALSE.
            mapIndexToDuplicate.put(index,new Duplicate(FALSE,null,null,null));
            for(Datacloud.DuplicateResult result : find.getDuplicateResults()) {
                // result has a bunch of information about the Duplicate Rule being applied.
                for(Datacloud.MatchResult match : result.getMatchResults()) {
                    // match has a bunch of information about the Matching Rule being applied.
                    
                    // Instantiate a new list of Duplicates with the Duplicate from the map.
                    List<Duplicate> duplicates = new List<Duplicate>{mapIndexToDuplicate.get(index)};
                    for(Datacloud.MatchRecord record : match.getMatchRecords()) {
                        Id recordId = record.getRecord().Id;
                        Double matchConfidence = record.getMatchConfidence() == null ? 0 : record.getMatchConfidence();
                        String sObjectType = recordId.getSObjectType().getDescribe().getName();
                        duplicates.add(new Duplicate(TRUE,recordId,sObjectType,matchConfidence));
                    }
                    
                    // The Duplicate object implements the Comparable interface, so we are sorting the list in a specific way.
                    // The best Duplicate is the first object from the list because it has the highest matchConfidence.
                    duplicates.sort();
                    mapIndexToDuplicate.put(index,duplicates.remove(0));
                }
            }
            index++;
        }

        return mapIndexToDuplicate.values();
    }

    /**
    * @description Wrapper class for invocable inputs
    **/
    public class Input{
        @InvocableVariable(label='Record to Check for Duplicates' required=TRUE)
        public sObject record;
    }

    /**
    * @description Wrapper class for invocable outputs
    **/
    public class Duplicate implements Comparable{
        @InvocableVariable(label='Is there a Duplicate?')
        public Boolean isDuplicate;

        @InvocableVariable(label='Duplicate Record Id')
        public Id duplicateRecordId;

        @InvocableVariable(label='Duplicate sObject Type')
        public String duplicatesObjectType;

        @TestVisible
        private Double matchConfidence; 

        public Duplicate(Boolean isDuplicate, Id duplicateRecordId, String duplicatesObjectType, Double matchConfidence){
            this.isDuplicate = isDuplicate;
            this.duplicateRecordId = duplicateRecordId;
            this.duplicatesObjectType = duplicatesObjectType;
            this.matchConfidence = matchConfidence;
        }

        /**
        * @description Comparable method that sorts the objects in decsending order based on matchConfidence (nulls last)
        * @param Object compareTo 
        * @return Integer 
        **/
        public Integer compareTo(Object compareTo){
            Duplicate that = (Duplicate)compareTo;
            if(this.matchConfidence == that.matchConfidence) return 0;
            if(this.matchConfidence == null) return 1;
            if(that.matchConfidence == null) return -1;
            return (this.matchConfidence < that.matchConfidence) ? 1 : -1;
        }
    }
}

