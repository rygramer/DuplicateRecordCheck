/**
* @Name:         DuplicateRecordCheck
* @Author:       Kicksaw, RM
* @Date:         2021-06-16
* @Description:  Runs the duplicate rules on a particular record or recordId to see if a duplicate record exists.
*/
public with sharing class DuplicateRecordCheck{
    /**
    * @Description  Runs the duplicate rules on a particular record or recordId to see if a duplicate record exists.
    * @Param        inputs - List<InputParameters>
    * @Return       List<OutputParameters>
    */
    @InvocableMethod(
        label='Check for Duplicate Records'
        description='Runs the duplicate rules on a particular record or recordId to see if a duplicate record exists.'
        category='Kicksaw'
    )
    public static List<Duplicate> findDuplicates(List<Input> inputs){
        
        List<Datacloud.FindDuplicatesResult> results = new List<Datacloud.FindDuplicatesResult>();
        List<sObject> listsObjectsToCheck = new List<sObject>();
        for(Input input : inputs){
            listsObjectsToCheck.add(input.record);
            if(listsObjectsToCheck.size() == 50){
                results.addAll(Datacloud.FindDuplicates.findDuplicates(listsObjectsToCheck));
                listsObjectsToCheck.clear();
            }
        }
        if(!listsObjectsToCheck.isEmpty()){
            results.addAll(Datacloud.FindDuplicates.findDuplicates(listsObjectsToCheck));
        }

        Integer index = 0;
        Map<Integer,Duplicate> mapIndexToDuplicate = new Map<Integer,Duplicate>();
        for(Datacloud.FindDuplicatesResult find : results) {
            mapIndexToDuplicate.put(index,new Duplicate(FALSE,null,null,null));

            system.debug('find.geterrors '+find.getErrors());
            system.debug('find.issuccess '+find.isSuccess());

            for(Datacloud.DuplicateResult result : find.getDuplicateResults()) {
                
                system.debug('result.getduplicaterule '+result.getDuplicateRule());
                system.debug('result.getduplicateruleentitytype '+result.getDuplicateRuleEntityType());
                system.debug('result.geterrormessage '+result.getErrorMessage());
                system.debug('result.isallowsave '+result.isAllowSave());

                for(Datacloud.MatchResult match : result.getMatchResults()) {

                    system.debug('match.getentitytype '+match.getEntityType());
                    system.debug('match.geterrors '+match.getErrors());
                    system.debug('match.getmatchengine '+match.getMatchEngine());
                    system.debug('match.getrule '+match.getRule());
                    system.debug('match.getsize '+match.getSize());

                    List<Duplicate> duplicates = new List<Duplicate>{mapIndexToDuplicate.get(index)};
                    for(Datacloud.MatchRecord record : match.getMatchRecords()) {

                        system.debug('match.getMatchConfidence '+record.getMatchConfidence());

                        Id recordId = record.getRecord().Id;
                        Double matchConfidence = record.getMatchConfidence() == null ? 0 : record.getMatchConfidence();
                        String sObjectType = recordId.getSObjectType().getDescribe().getName();
                        duplicates.add(new Duplicate(TRUE,recordId,sObjectType,matchConfidence));
                    }
                    
                    system.debug('pre-sort '+duplicates);
                    duplicates.sort();
                    system.debug('post-sort '+duplicates);
                    mapIndexToDuplicate.put(index,duplicates.remove(0));
                }
            }
            index++;
        }

        return mapIndexToDuplicate.values();
    }

    public class Input{
        @InvocableVariable(label='Record to Check for Duplicates' required=TRUE)
        public sObject record;
    }

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

        public Integer compareTo(Object compareTo){
            Duplicate that = (Duplicate)compareTo;
            if(this.matchConfidence == that.matchConfidence) return 0;
            if(this.matchConfidence == null) return 1;
            if(that.matchConfidence == null) return -1;
            return (this.matchConfidence < that.matchConfidence) ? 1 : -1;
        }
    }
}

