public class Machinist {

    public static Machine getMachine(String machineName) {
        machinist_Machine__c machineRecord =
            new Machine_Selector()
                .selectByMachineName(machineName)
                ?.get(0);

        return new Machine(machineRecord);
    }
    public static void deleteMachines(Machine[] machines) {

    }

    public static void createTransition(Id machineId, Transition transition) {

    }


    public static void updateTransition(Id machineId, Transition transition) {
        // Machinist.updateTransitions()
    }


    public static void deleteTransition(Transition transition) {

    }

    public static void transition(Machine machine, String action, SObject[] records) {
        for(SObject record : records) {
            transition(machine, action, record);
        }
    }

    public static void transition(
        Machine machine,
        String action,
        SObject record
    ) {

        String incomingSObjectType = String.valueOf(record.getSObjectType());
        if(incomingSObjectType != machine.targetSObjectType) {
            System.debug('Wrong object');
        }

        String currentStateName = (String)record.get(machine.targetSObjectField);
        State currentState = machine.statesByName.get(currentStateName);

        Transition transition =
            currentState
            ?.toTransitionsByAction
            .get(action);

        if(transition == null) {
            return;
        }

        transition.guard?.call(record);

        if(record.hasErrors()) {
            System.debug(record.getErrors());
            return;
        }

        record.put(machine.targetSObjectField, transition.toState);
    }

    public class Machine {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String targetSObjectType;
        @AuraEnabled
        public String targetRecordType;
        @AuraEnabled
        public String targetSObjectField;
        @AuraEnabled
        public Map<String, State> statesByName =
            new Map<String, State>();

        private Machine(machinist_Machine__c machineRecord) {
            this.id = machineRecord.Id;
            this.name = machineRecord.Name;
            this.targetSObjectType = machineRecord.TargetSObjectType__c;
            this.targetSObjectField = machineRecord.TargetSObjectField__c;
            this.targetRecordType = machineRecord.TargetRecordType__c;

            for(machinist_Transition__c transitionRecord : machineRecord.Transitions__r) {
                String fromState = transitionRecord.FromState__c;
                if(!statesByName.keySet().contains(fromState)) {
                    State newState = new State(fromState);
                    this.statesByName.put(newState.name, newState);
                }

                this.statesByName
                    .get(fromState)
                    .toTransitionsByAction
                    .put(transitionRecord.Action__c, new Transition(transitionRecord));
            }

        }
    }

    public class State {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Map<String, Transition> toTransitionsByAction =
            new Map<String, Transition>();

        private State(String name) {
            this.name = name;
        }
    }

    public class Transition {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String fromState;
        @AuraEnabled
        public String toState;
        @AuraEnabled
        public String action;
        @AuraEnabled
        public String event;
        @AuraEnabled
        public String guardName;
        public IGuard guard;

        private Transition(machinist_Transition__c transitionRecord) {
            this.id = transitionRecord.Id;
            this.fromState = transitionRecord.FromState__c;
            this.toState = transitionRecord.ToState__c;
            this.action = transitionRecord.Action__c;
            this.event = transitionRecord.Event__c;
            this.guardName = transitionRecord.Guard__c;

            if(!String.isEmpty(transitionRecord.Guard__c)) {
                Type guardType = Type.forName(this.guardName);
                if(guardType != null) {
                    this.guard = (IGuard) guardType.newInstance();
                }
            }

        }
    }

    public interface IGuard {
        void call(SObject record);
    }

    private inherited sharing class Machine_Selector {
        public machinist_Machine__c[] selectByMachineName(String machineName) {
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
            ];
        }
    }
}