/**
 * @description       : Simple factory to instantiate FindDuplicates() so we can mock tests.
 * @author            : Ryan Mercer
 * @last modified on  : 01-28-2022
 * @last modified by  : Ryan Mercer 
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   01-28-2022   Ryan Mercer   Initial Version
**/
public with sharing virtual class FindDuplicatesFactory {
    @TestVisible
    private static FindDuplicatesFactory stubFactory;
    private static FindDuplicatesFactory factory;

    protected FindDuplicatesFactory() {
        // enforce "getFactory" as only way to call Factory
    }

    public static FindDuplicatesFactory getFactory() {
        if (stubFactory != null) {
            return stubFactory;
        } else if (factory == null) {
            factory = new FindDuplicatesFactory();
        }

        return factory;
    }

    public virtual FindDuplicates getFindDuplicates(){
        return new FindDuplicates();
    }
}
