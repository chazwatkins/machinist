public class Machinist {

    public static machinist_Machine__c newMachine() {
        return new machinist_Machine__c();
    }

    public static machinist_Machine__c createMachine(machinist_Machine__c newMachine) {
        insert newMachine;
        return new Machine_Selector()
            .selectById(newMachine.Id);
    }

    public static machinist_Machine__c getMachine(Id machineId) {
        return new Machine_Selector()
            .selectById(machineId);
    }

    public static machinist_Machine__c getMachine(String machineName) {
        return new Machine_Selector()
            .selectByName(machineName);
    }

    public static void transition(machinist_Machine__c machine, String action, SObject[] records) {

        assertMachineAndRecordSObjectTypesMatch(machine, records);

        machinist_Transition__c toTransition = getTransitionByAction(machine, action);

        IGuard guard = getGuard(toTransition);

        for(SObject record : records) {
            guard?.call(record);

            if(record.hasErrors()) {
                continue;
            }

            record.put(machine.TargetSObjectField__c, toTransition.ToState__c);
        }
    }

    private static machinist_Transition__c getTransitionByAction(machinist_Machine__c machine, String action) {
        machinist_Transition__c toTransition;

        for(machinist_Transition__c transition : machine.Transitions__r) {
            if(transition.Action__c == action) {
                toTransition = transition;
                break;
            }
        }

        if(toTransition == null) {
            throw new ActionNotFoundException(action);
        }

        return toTransition;
    }

    private static void assertMachineAndRecordSObjectTypesMatch(
        machinist_Machine__c machine,
        SObject[] records
    ) {
        String incomingSObjectType = String.valueOf(records.getSObjectType());
        if(incomingSObjectType != machine.TargetSObjectType__c) {
            throw new SObjectTypeMismatchException(
                'Expected ' + machine.TargetSObjectType__c + '' +
                    ', but received ' + incomingSObjectType);
        }
    }

    private static IGuard getGuard(machinist_Transition__c transition) {
        IGuard guard;

        if(String.isEmpty(transition.Guard__c)) {
            guard = null;
        }

        Type guardType = Type.forName(transition.Guard__c);
        if(guardType != null) {
            guard = (IGuard) guardType.newInstance();
        }

        return guard;
    }

    public interface IGuard {
        void call(SObject record);
    }

    private inherited sharing class Machine_Selector {

        public machinist_Machine__c selectById(Id machineId) {
            return [
                SELECT
                    Id,
                    Name,
                    TargetSObjectType__c,
                    TargetSObjectField__c,
                    TargetRecordType__c,
                    (
                        SELECT
                            Action__c,
                            Event__c,
                            FromState__c,
                            ToState__c,
                            Guard__c
                        FROM Transitions__r
                    )
                FROM machinist_Machine__c
                WHERE Id = :machineId
                LIMIT 1
            ];
        }
        public machinist_Machine__c selectByName(String machineName) {
            return [
                SELECT
                    Id,
                    Name,
                    TargetSObjectType__c,
                    TargetSObjectField__c,
                    TargetRecordType__c,
                    (
                        SELECT
                            Action__c,
                            Event__c,
                            FromState__c,
                            ToState__c,
                            Guard__c
                        FROM Transitions__r
                    )
                FROM machinist_Machine__c
                WHERE Name = :machineName
                LIMIT 1
            ];
        }
    }

    public class MachineNotFoundException extends Exception {}
    public class SObjectTypeMismatchException extends Exception {}
    public class ActionNotFoundException extends Exception {}
    public class TransitionFailedException extends Exception {}
}