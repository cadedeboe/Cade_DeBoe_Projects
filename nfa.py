# Name: nfa.py
# Author: Sebastian Fernandez, Cade Deboe
# Date: October 09, 2024
# Description: Implementation of an NFA class for
# Comp370, Fall 2024, pa2.
import sys
from dfa import DFA  # imports your DFA class from pa1


class FileFormatError(Exception):
	pass

class NFA:
	""" Simulates an NFA """

	def __init__(self, nfa_filename=None):
		"""
		Initializes NFA from the file whose name is
		nfa_filename.  (So you should create an internal representation
		of the nfa.)
		"""
		self.transitions = {}
		self.epsilon_transitions = {}
		self.epsilon_list = []
		self.epsilon_only_states = set()
		self.epsilon_associations = {}
		self.language = []
		self.state_num = 0
		state_set = set()
		epsilon_states = set()
		if nfa_filename is not None:
			with open(nfa_filename, "r") as f:
				
				self.state_amount = f.readline().strip()
				state_amount = self.state_amount.split()
				if len(state_amount) > 1:
					raise FileFormatError("Num states not valid.")
				if len(state_amount) == 0:
					raise FileFormatError("No state amount given")
				
				try:
					self.state_amount = int(state_amount[0])
				except ValueError:
					raise FileFormatError("Num states not valid.")
				
				self.language = []
				characters = f.readline().rstrip('\n')
				if not characters:
					raise FileFormatError("No symbols in alphabet.")
				
				for ch in characters:
					self.language.append(ch)
				
				# Initialize dictionary and process transitions
				self.transitions = {}
				self.epsilon_transitions = {}
				self.epsilon_list = []
				state_set = set()
				epsilon_states = set()

				#This is where we get all our transitions and epsilon transitions
				while True:
					line = f.readline().strip()

					if line == "":
						break  # End of transitions section
					
					# Parse the transition line
					entry = line.split()
					
					# Check if the line contains exactly three parts (start state, symbol, exit state)
					if entry[1] == "'" and entry[2] == "'":
						entry[1] = " "
						entry[2] = entry[3]
						entry.pop()
					
					#Check that the transition is in proper format
					if len(entry) != 3:
						raise FileFormatError("Missing transition.")

					#The state number cannot be greater than the total state amount
					try:
						nfa_state = int(entry[0])
						if nfa_state < 0 or nfa_state > self.state_amount:
							raise FileFormatError("State in transition not a valid state.")
					except ValueError:
						raise FileFormatError("State in transition not a valid state.")
					
					#Catching the special case where the transition is a space
					if entry[1] != " ":
						symbol = entry[1].strip("'")
					else:
						symbol = " "
					
					#symbol can only be in the language or e
					if symbol not in self.language and symbol != 'e':
						raise FileFormatError("Transition symbol not allowed.")
					
					# Verifys the transitioned into state is a valid state
					try:
						nfa_transition_exit_state = int(entry[2])
						if nfa_transition_exit_state < 0 or nfa_transition_exit_state > self.state_amount:
			
							raise FileFormatError("State in transition not valid state.")
					except ValueError:
				
						raise FileFormatError("State in transition not a valid state.")
					
					#sets the current transiton key so we can use it for a dictionary association of key to state.
					transition_key = (nfa_state, symbol)
					
					#We have to check if it is an epsilon transition or a non-epsion transition
					#Epsilon transitions must be handled after we know all non-epsion transitions.
					if symbol == 'e' and not self.epsilon_transitions.get(transition_key):
						self.epsilon_list.append(transition_key)
						epsilon_states.add(transition_key[0])
						self.epsilon_transitions[transition_key] = []
						self.epsilon_transitions[transition_key].append(entry[2])
					elif symbol == 'e':
						epsilon_states.add(transition_key[0])
						self.epsilon_transitions[transition_key].append(entry[2])
					elif not self.transitions.get(transition_key):
						state_set.add(int(transition_key[0]))
						self.transitions[transition_key] = []
						self.transitions[transition_key].append(entry[2])
					else:
						state_set.add(int(transition_key[0]))
						self.transitions[transition_key].append(entry[2])

				#Once we have our transitions, we get the state state
				start_state_line = f.readline().strip()
				for number in start_state_line.split():
					try:
						int(number)
					except ValueError:
						raise FileFormatError("Too many transitions.")
				self.start_state = start_state_line.split()

				#Verify start_state is in proper format
				if len(self.start_state) > 1:
					raise FileFormatError("Invalid start state.")
				if int(self.start_state[0]) > int(self.state_amount) or int(self.start_state[0]) < 0:
					raise FileFormatError("Invalid start state.")
				self.start_state[0] = str(self.start_state[0])
				self.accept_states = []
				accepts = f.readline().strip().split()

				#creates a list of all accept states for future reference
				for states in accepts:
					try:
						self.accept_states.append(int(states))
					except ValueError:
						raise FileFormatError("Invalid accept state.")
				
				#At this point we should have no other information in the file
				remaining_content = f.read().strip()
				if remaining_content:
					raise FileFormatError("Extra content after accept states.")


				"""
				This next chunk of code calculates all epsilon associated transitions. We have to consider if there
				are multiple epsilon transitions for a given state and if there are a linked chain of epsilons between
				states. A these possible paths must be calculated and associated with what we refer to as the orginal state.
				Which is state that has an epsilon transition. This is why, up above, we catch all epsilon transitions for
				later processing. These next lines of code is that processing.

				"""
				#A dictionary that associates a state with an epsilon transition with every possible state it could epsilon to
				self.epsilon_associations = {}

				#If a state has only epsilon transitions, espically if it is the start state, must be handled differently. So we track that information.
				self.epsilon_only_states = set()
			
				# We must calculate epsilon closure for every state with any epsilon transitions
				for epsilon_key in self.epsilon_list:
					if int(epsilon_key[0]) not in state_set:
						self.epsilon_only_states.add(str(epsilon_key[0]))
					epsilon_state = int(epsilon_key[0])
					self.epsilon_closure(epsilon_key, epsilon_state)
				
				for transtion in self.transitions:
					for epsilon_state in epsilon_states:
						if str(epsilon_state) in self.transitions[transtion]:
							for state in self.epsilon_associations[epsilon_state]:
								if state not in self.transitions[transtion]:
									self.transitions[transtion].append(state)

	def epsilon_closure(self, epsilon_key, orginal_state):
		"""
		We have to keep track of the orginal state we pass in so we know all the possible epsiloned into states
		to associate it with. If we epsilon into a state that has epsilon transitions, we must assocaite all those
		epsiloned into states with the orginal state. We also must consider if that epsiloned into state has multiple
		epsilon transitions. This is done recursivly. Once every epsilon transition has been process we have full epsilon
		closure for the most part. A start state that has only epsilon transitions must be handled uniquely, but this is
		done in to_dfa if that is the case. 
		"""
		#Creates the association of a state with an epsilon transition with an empty set
		if orginal_state not in self.epsilon_associations:
			self.epsilon_associations[orginal_state] = set()

		#For all states we could possibly epsilon into, associate the orginal state with the set of all those states.
		for state in self.epsilon_transitions[epsilon_key]:
			self.epsilon_associations[orginal_state].add(state)
	
		#If we add a state to our epsilon association that has epsilon transitions, we must run the method again for those states.
		for state in self.epsilon_transitions[epsilon_key]:
			if (int(state), 'e') in self.epsilon_transitions:
				self.epsilon_closure((int(state), 'e') , orginal_state)

	def to_DFA(self):
		"""
		Converts the "self" NFA into an equivalent DFA object
		and returns that DFA.  The DFA object should be an
		instance of the DFA class that you defined in pa1. 
		The attributes (instance variables) of the DFA must conform to 
		the requirements laid out in the pa2 problem statement (and that are the same
		as the DFA file requirements specified in the pa1 problem statement).

		This function should not read in the NFA file again.  It should
		create the DFA from the internal representation of the NFA that you 
		created in __init__.
		"""
		#print(self.start_state)
		#print(self.transitions)
		# Initialize DFA components
	
		self.dfa_states = []
		self.dfa_transitions = {}
		self.dfa_accept_states = set()
		dfa_alphabet = self.language
		
		# This will associate a set of states with its state number to translate for the dfa
		self.state_translator = {}
		
		#The start state needs to be converted to a set like all other states
		#print(self.start_state)
		self.start_state = set(self.start_state)
		#print(self.start_state)
		
		#The start state must be handled if it only has epsilon transitions
		#print(self.epsilon_only_states)
		#print(self.start_state, "HERE")
		#print(self.language, "LANG")
		if self.start_state <= self.epsilon_only_states:
			#print("here3")
			prev_start_state = self.start_state

			#We make the start state every state it could epsilon into. There will only be one state in start_state but it is a set
			for key in self.start_state:
				#Checking if the start state is a start state, this is important for the empty string input
				is_start_accept = int(key) in self.accept_states
				self.start_state = self.epsilon_associations[int(key)]
			#print(self.start_state, "here2")
			#If we have even more epsilons branching off the new start state that aren't associated with the start state, we must associate them
			addtional_states = set()
			for state in self.start_state:
				if int(state) in self.epsilon_associations:
					addtional_states.update(self.epsilon_associations[int(state)])
			self.start_state.update(addtional_states)
			if is_start_accept:
				self.start_state.update(prev_start_state)

		#If the start state has valid transitions but also epsilon transitions	
		else:
			for key in self.epsilon_list:
				if str(key[0]) in self.start_state:
					self.start_state.update(self.epsilon_associations[key[0]])
		
		#Set the DFA start state and its associated state number of 1, so start state will always be 1(Not all that important for DFAs)
		self.dfa_states.append(self.start_state)

		#must be global so that we can keep track of the number of recursive branches
		self.state_num = 1
		#print(self.start_state, "here")
		#This method will create all the new DFA states based on the start_state, like how we do in class
		self.dfa_state_calculator(self.start_state)

		#Must translate all dfa transition values with their corisponding state number
		#This associates the start state with 1, the start state could change around a lot so we must set it here
		for state in self.dfa_states:
			if state == self.start_state:
				dfa_start_state = self.state_translator[frozenset(state)]
		
		#Associate all other states other than start or reject state
		for key in self.dfa_transitions:
			value = self.dfa_transitions[key]
			self.dfa_transitions[key] = self.state_translator[frozenset(value)]

		#If we have an empty set in dfa_states, then it is rejecting, must set up rejecting state here.
		if set() in self.dfa_states:
			reject_state = self.state_translator[frozenset()]
			#every symbol for a reject state goes into itself
			for symbol in self.language:
				self.dfa_transitions[(reject_state, symbol)] = reject_state
	
		
		# Create DFA object
		
		self.dfa = DFA()
		self.dfa.property_num_states = len(self.dfa_states)
		#print(self.dfa.property_num_states)
		self.dfa.property_alphabet = dfa_alphabet
		#print(self.dfa.property_alphabet)
		self.dfa.property_start_state = dfa_start_state
		#print(self.dfa.property_start_state)
		self.dfa.property_accept_states = self.dfa_accept_states
		#print(self.dfa.property_accept_states, "HERE")
		self.dfa.transitions = self.dfa_transitions
		#print(self.dfa.transitions)
		

		return self.dfa
	def dfa_state_calculator(self, current_state):
		"""
		We start with the start state and then determine the set of all possible states it could go to for every symbol in 
		the alphabet, refered to as self.language. From there we create the new states with our transition dictionary. We
		made this dictionary so we can just look up all possible states a state goes to for a given symbol. Thats why our
		keys are transitons. Once a new state is created that has not yet been added to the dfa states, we got to run it 
		back into this method to calculate all its transitions for every symbol. We must remeber that we are working with
		states that are defined by all possible states it could be in for a given instance. So we must consider all those
		"substates" when performing our calculations. Once this method is done, all dfa states will have been created along
		with their transitions. This infomation is held in a dfa state transition dictionary, but when we assign a state number
		so that the dfa can interpret that state, we can't assign it's transitioned into state number, because it is very likely
		that state hasn't been created yet. So we must create a state translator, to associated the transitions with their correct
		state number.
		"""
		#We must determine if the new state is accepting
		accept_state = False
		#We want to keep track of newly created states, so we know which states we have to run back through this method
		brandnew_states = []

		#associate the current state, which is always a new state, with its state num
		self.state_translator[frozenset(current_state)] = self.state_num
		
		#Every state must have a transition for every symbol
		for symbol in self.language:
			dfa_state = set()

			#Creates the new dfa state for a given transition out of the current state
			for sub_state in current_state:
				#check if a sub-state is accepting(then the whole state is accepting)
				if int(sub_state) in self.accept_states:
					accept_state = True
				#if it is a state with only epsilon transitions, we got to get those transitions
				if int(sub_state) in self.epsilon_only_states:
					dfa_state.update(self.epsilon_associations[int(sub_state)])
				#Calculates a substates associations to make the new dfa state
				if (int(sub_state), symbol) in self.transitions:
					next_state_sets = self.transitions[(int(sub_state), symbol)]
					dfa_state.update(next_state_sets)
			
			if accept_state:
				self.dfa_accept_states.add(self.state_num)
			
			#Checks if it is a newly created state
			if dfa_state not in self.dfa_states:
				brandnew_states.append(dfa_state)
				self.dfa_states.append(dfa_state)
			self.dfa_transitions[(self.state_num, symbol)] = dfa_state
		
		#processes all newly created states
		for state in brandnew_states:
			#since we created a new state, the number of states also increases
			self.state_num += 1
			self.dfa_state_calculator(state)
			
		

			
	
		

	
if __name__ == "__main__":

	# Test one nfa file.  You can modify which file
	# in the next three lines.
	this_nfa = NFA()
	this_nfa.to_DFA()
	"""
	nfa_filename = "nfa19.txt"
	input_filename = "str19.txt"
	correct_results_filename = "correct19.txt"

	print(f"Testing NFA {nfa_filename} on strings from {input_filename}")
	try:
		# Create NFA
		this_nfa = NFA(nfa_filename)

		# Convert to DFA
		equiv_dfa = this_nfa.to_DFA()

		# Check the format of the DFA file
		if not dfa_data_ok(equiv_dfa, nfa_filename):
			print("  DFA file has incorrect format")
		else:
			# Open string file.
			string_file = open(input_filename)

			# Simulate DFA on test strings
			results = []
			for str in string_file:
				results.append(equiv_dfa.simulate(str.rstrip('\n')))

			# Get correct results
			correct_results = read_results_file(correct_results_filename)

			# Check if correct
			if results == correct_results:
				print("  Correct results")
			else:
				print("  Incorrect results")
				print(f"  Your results = {results}")
				print(f"  Correct results = {correct_results}")
			print()
	except OSError as err:
		print(f"Could not open file: {err}")
	except Exception as err:
		print(f"Error simulating dfa: {err}")
		"""