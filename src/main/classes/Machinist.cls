public class Machinist {

    public static Machine getMachine(String machineName) {
        machinist_MachineState__c[] states =
            new MachineState_Selector().selectByMachineName(machineName);

        return new Machine(states);
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
        if(incomingSObjectType != machine.sObjectType) {
            System.debug('Wrong object');
        }

        String currentStateName = (String)record.get(machine.sObjectField);
        State currentState = machine.statesByName.get(currentStateName);

        Transition transition =
            currentState
            .toTransitionsByAction
            .get(action);

        if(transition == null) {
            return;
        }

        transition.guard?.call(record);

        if(record.hasErrors()) {
            System.debug(record.getErrors());
            return;
        }

        record.put(machine.sObjectField, transition.toState);
    }

    public class Machine {
        public String name;
        public String sObjectType;
        public String sObjectField;
        public Map<String, State> statesByName =
            new Map<String, State>();

        private Machine(machinist_MachineState__c[] stateRecords) {
            machinist_Definition__c definition =
                (machinist_Definition__c)stateRecords
                    .get(0)
                    .getSObject(machinist_MachineState__c.Machine__c);

            this.name = definition.Name;
            this.sObjectType = definition.SObjectType__c;
            this.sObjectField = definition.SObjectField__c;

            for(machinist_MachineState__c stateRecord : stateRecords) {
                State state = new State(stateRecord);
                this.statesByName.put(state.name, state);
            }

        }
    }

    public class State {
        public String name;
        public Boolean isInitial;
        public Map<String, Transition> toTransitionsByAction =
            new Map<String, Transition>();

        private State(machinist_MachineState__c stateRecord) {
            this.name = stateRecord.State__r.Name;
            this.isInitial = stateRecord.IsInitialState__c;

            for(machinist_Transition__c transitionRecord : stateRecord.FromTransitions__r) {
                Transition newToTransition = new Transition(transitionRecord);
                this.toTransitionsByAction.put(newToTransition.action, newToTransition);
            }
        }
    }

    public class Transition {
        public String fromState;
        public String toState;
        public String action;
        public String event;
        public IGuard guard;

        private Transition(machinist_Transition__c transitionRecord) {
            this.fromState = transitionRecord.FromState__r.State__r.Name;
            this.toState = transitionRecord.ToState__r.State__r.Name;
            this.action = transitionRecord.Action__c;
            this.event = transitionRecord.Event__c;

            if(!String.isEmpty(transitionRecord.Guard__c)) {
                Type guardType = Type.forName(transitionRecord.Guard__c);
                if(guardType != null) {
                    this.guard = (IGuard) guardType.newInstance();
                }
            }

        }
    }

    public interface IGuard {
        void call(SObject record);
    }

    private inherited sharing class MachineState_Selector {
        public machinist_MachineState__c[] selectByMachineName(String machineName) {
            return [
                SELECT
                    Id,
                    Machine__r.Name,
                    Machine__r.SObjectType__c,
                    Machine__r.SObjectField__c,
                    State__r.Name,
                    IsInitialState__c,
                    (
                        SELECT
                            Action__c,
                            Event__c,
                            FromState__r.State__r.Name,
                            ToState__r.State__r.Name,
                            Guard__c
                        FROM FromTransitions__r
                    )
                FROM machinist_MachineState__c
                WHERE Machine__r.Name = :machineName
            ];
        }
    }
}