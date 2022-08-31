public class Machinist {

    public class Machine {

        public String id { get; private set; }
        public State currentState { get; private set; }
        private String initial;
        private States states;

        public void transition(String event) {
            String nextStateName =
                this.currentState.transitions.nextState(event);

            if (nextStateName != null) {
                State nextState = this.states.get(nextStateName);
                this.currentState = nextState;
            }
        }

        public Machine(
            String id,
            String initial,
            States states
        ) {
            this(id, initial, states, initial);
        }

        public Machine(
            String id,
            String initial,
            States states,
            String currentState
        ) {
            this.id = id;
            this.initial = initial;
            this.states = states;
            this.currentState = this.states.get(currentState);
        }
    }

    public class Transitions {
        Map<String, String> statesByEvent =
            new Map<String, String>();

        public Transitions() {}

        public Transitions add(String event, String nextState) {
            statesByEvent.put(event.toUpperCase(), nextState);
            return this;
        }

        public String nextState(String event) {
            return this.statesByEvent.get(event);
        }
    }

    public class State {
        public String name { get; private set; }

        @TestVisible
        Transitions transitions;

        @TestVisible
        States states;

        public State(
            String name,
            Transitions transitions
        ) {
            this(name, transitions, null);
        }

        public State(
            String name,
            Transitions transitions,
            States states
        ) {
            this.name = name;
            this.transitions = transitions;
            this.states = states;
        }
    }

    public class States {
        private Map<String, State> statesByName =
            new Map<String, State>();

        public States() {}

        public States add(State newState) {
            this.statesByName.put(newState.name, newState);

            return this;
        }

        public State get(String name) {
            return this.statesByName.get(name);
        }
    }

}