public class Machinist {

    public static Machine getMachine(String machineName, SObject record) {
        return getMachines(machineName, new List<SObject>{record}).get(record.Id);
    }

    public static Map<Id, Machine> getMachines(String machineName, SObject[] records) {
        machinist_MachineState__c[] states = [
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
                        ToState__r.State__r.Name
                    FROM FromTransitions__r
                ),
                (
                    SELECT
                        Action__c,
                        Event__c,
                        FromState__r.State__r.Name,
                        ToState__r.State__r.Name
                    FROM ToTransitions__r
                )
            FROM machinist_MachineState__c
            WHERE Machine__r.Name = :machineName
        ];

        Map<Id, Machine> machinesById = new Map<Id, Machine>();
        for(SObject record : records) {
            machinesById.put(record.Id, new Machine(states, record));
        }

        return machinesById;

    }

    public static void setCurrentState(Machine machine, String newStateName) {
        machine.currentState = machine.statesByName.get(newStateName);
        machine.record.put(machine.sObjectField, newStateName);
    }

    public static void transition(
        Machine machine,
        String action
    ) {
        String nextStateName =
            machine
            .currentState
            .toTransitionsByAction
            .get(action)
            ?.toState;

        if(nextStateName != null) {
            machine.previousState = machine.currentState;
            setCurrentState(machine, nextStateName);
        }
    }


    public class Machine {
        public String name;
        public String sObjectType;
        public String sObjectField;
        public SObject record;
        public State previousState;
        public State currentState;
        public Map<String, State> statesByName =
            new Map<String, State>();

        private Machine(machinist_MachineState__c[] stateRecords, SObject record) {
            machinist_Definition__c definition =
                (machinist_Definition__c)stateRecords
                    .get(0)
                    .getSObject(machinist_MachineState__c.Machine__c);

            this.name = definition.Name;
            this.sObjectType = definition.SObjectType__c;
            this.sObjectField = definition.SObjectField__c;

            for(machinist_MachineState__c stateRecord : stateRecords) {
                State state = new State(stateRecord);
                if(state.isInitial && this.currentState == null) {
                    this.currentState = state;
                }

                this.statesByName.put(state.name, state);
            }

            String incomingSObjectType = String.valueOf(record.getSObjectType());
            if(incomingSObjectType != this.sObjectType) {
                System.debug('Wrong object');
            }

            this.record = record;
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

        private Transition(machinist_Transition__c transitionRecord) {
            this.fromState = transitionRecord.FromState__r.State__r.Name;
            this.toState = transitionRecord.ToState__r.State__r.Name;
            this.action = transitionRecord.Action__c;
            this.event = transitionRecord.Event__c;
        }
    }

}