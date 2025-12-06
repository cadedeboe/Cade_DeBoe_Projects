# Name: dfa.py
# Author: Sebastian Fernandez, Cade Deboe
# Date: October 06, 2024
# Description: dfa class for pa1, for comp 370

import sys

class FileFormatError(Exception):
    """
    Exception that is raised if the 
    input file to the DFA constructor
    is incorrectly formatted.
    """

    pass

class DFA:
    def __init__(self, *, filename=None):
        """
        Initializes DFA object from the dfa specification
        in named parameter filename.
        """
        if filename is not None:
            with open(filename, "r") as f:
                # Read the first two lines for state_amount and language
            
                self.state_amount = f.readline().strip()
                
                
                # Check if more than one entry for amount of states
                
                state_amount = self.state_amount.split()
                
                if len(state_amount) > 1:
                    raise FileFormatError("Num states not valid.")
                
                if len(state_amount) == 0:
                    raise FileFormatError("No state amount given")
                
                # Validate state_amount is an integer
                try:
                   self.property_num_states = int(state_amount[0])
                except ValueError:
                    raise FileFormatError("Num states not valid.")
                
                self.language = []
                characters = f.readline().rstrip('\n')

                if not characters:
                    raise FileFormatError("No symbols in alphabet.")
                # Adding characters in language to list
                for ch in characters:
                    self.language.append(ch)

                self.property_alphabet = self.language
                # Calculate the number of transitions
                self.num_transitions = int(self.state_amount) * len(self.language)

                # Initialize dictionary and process transitions
                self.transitions = {}

                for i in range(self.num_transitions):
                    entry = f.readline().strip().split()

                    # Check if the line contains exactly three parts (start state, symbol, exit state)
                    if len(entry) != 3:
                        raise FileFormatError("Missing transition.")
                    
                    trans_key = (entry[0],entry[1][1])
                    

                    # Check if the transition symbol is in the alphabet
                    if trans_key[1] not in self.language:
                        raise FileFormatError("Symbol in transition not in alphabet.")
                    
                    # Check if the starting state is a valid integer and within the valid range
                    try:
                        trans_start_state = int(entry[0])
                        if trans_start_state < 0 or trans_start_state> int(self.state_amount):
                            raise FileFormatError("State in transition not a valid state.")
                    except ValueError:
                        raise FileFormatError("State in transition not a valid state.")
                    
                    # Check if the exiting state is a valid integer and within the valid range
                    try:
                        exit_state = int(entry[2])
                        if exit_state < 0 or exit_state > int(self.state_amount):
                            raise FileFormatError("State in transition not a valid state.")
                    except ValueError:
                        raise FileFormatError("State in transition not a valid state.")
                    
                    # Check if the transition is already defined
                    if trans_key in self.transitions:
                        raise FileFormatError("Transition redefined.")
                    
                    # Add the transition to the dictionary
                    self.transitions[trans_key] = entry[2]

                # Check for extra transitions
                line = f.readline().strip()
                if len(line.split()) > 2:
                    raise FileFormatError("Too many transitions.")
                else:
                    # No extra transitions so set line to start state
                    self.dfa_start_state = line

                # Check if valid start state
                _start_state = self.dfa_start_state.split()
                if len(_start_state) > 1:
                    raise FileFormatError("Invalid start state.")
                
                # Check if the start state is a valid integer
                try:
                    start_state_int = int(self.dfa_start_state)
                except ValueError:
                    raise FileFormatError("Invalid start state.")
                
                self.property_start_state = start_state_int

                # Check if start state is within the valid range
                if start_state_int > int(self.state_amount) or start_state_int < 0:
                    raise FileFormatError("Invalid start state.")

                # Initialize list adding each defined accepting state
                self.accepting_states = []
                accepts = f.readline().strip().split()

                # Set of integers for states
                self.property_accept_states = set()

                # Check if the accept state is a valid integer then append
                for states in accepts:
                    try:
                        int(states)
                        self.accepting_states.append(states)
                        self.property_accept_states.add(int(states))
                    except ValueError:
                        raise FileFormatError("Invalid accept state.")

                # Check if there is more content after accepting states
                remaining_content = f.read().strip()
                if remaining_content:
                    raise FileFormatError("Extra content after accept states.")
        else:
            # Initialize an empty DFA object
            self.property_num_states = 0
            self.property_alphabet = []
            self.property_start_state = None
            self.property_accept_states = set()
            self.transitions = {}
        
    

    def simulate(self, input_str):
        """
        Returns True if input_str is in the language of the DFA,
        and False if not.

        Assumes that all characters in input_str are in the alphabet 
        of the DFA.
        """
        current_state = self.property_start_state
        
        # Ensure the start state is a tuple or an integer
        if isinstance(current_state, tuple) and len(current_state) == 1:
            current_state = current_state[0]  # Flatten the tuple if it's a single element

        for symbol in input_str:

            # Flatten the current state if it's a single-element tuple
            if isinstance(current_state, tuple) and len(current_state) == 1:
                current_state = current_state[0]

            # Check if the transition exists
            if (current_state, symbol) not in self.transitions:
                return False

            # Get the next state from transitions
            next_state = self.transitions[(current_state, symbol)]

            # Ensure the next state is flattened if it's a single-element tuple
            if isinstance(next_state, tuple) and len(next_state) == 1:
                next_state = next_state[0]

            current_state = next_state  # Update current state
        # Return if the final state is an accepting state
        return current_state in self.property_accept_states

    def transition(self, state, symbol):
        """
        Returns the state(s) to transition to from "state" on input symbol "symbol".
        The "state" must be in the range 1, ..., num_states.
        The "symbol" must be in the alphabet or 'e' (epsilon transition).
        """
        if isinstance(state, int):
            state = (state,)  # Ensure state is a tuple

        if state[0] < 0 or state[0] > self.property_num_states: # use first state in tuple
            raise ValueError("State must be in the range 0, ..., num_states - 1.")
        if symbol not in self.property_alphabet and symbol != 'e':
            raise ValueError("Symbol must be in the alphabet or 'e' (epsilon transition).")

        key = (state[0], symbol)
        return self.transitions.get(key, None)

        

    @property
    def num_states(self):
        """ Number of states property """
        return self.property_num_states
    
    @property
    def start_state(self):
        """ Starting state of dfa """
        return self.property_start_state
    
    @property
    def accept_states(self):
        """ States accepted by dfa """
        return self.property_accept_states
    
    @property
    def alphabet(self):
        """ Symbols of the dfa language """
        return self.property_alphabet

    
if __name__ == "__main__":
    # You can run your dfa.py code directly from a
    # terminal command line:

    # Check for correct number of command line arguments
    if len(sys.argv) != 3:
        print("Usage: python3 pa1.py dfa_filename str")
        sys.exit(0)

    dfa = DFA(filename = sys.argv[1])
    str = sys.argv[2]
    ans = dfa.simulate(str)
    if ans:
        print(f"The string {str} is in the language of the DFA")
    else:
        print(f"The string {str} is in the language of the DFA")

