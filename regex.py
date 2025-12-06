

from nfa import NFA

class InvalidExpression(Exception):
	pass
class FileFormatError(Exception):
	pass
class Node:
	def __init__(self, expression=None):
		self.name = expression
		self.left = None
		self.right = None
		self.is_leaf = False
	pass
class RegEx:
	def __init__(self, filename = None):
		"""
		Initializes regular expression from the file "filename"
		"""
		
		self.alphabet = []
		self.reg_expr = str()

	def parse_tree(self):
		#puts implied concats into the regex
		operator_list = ["|","*","°"]
		reg_expr = self.reg_expr
		self.operator_stack = []
		self.operand_stack = []
		concat_regex = []
		for i in range(len(reg_expr)):
			concat_regex.append(reg_expr[i])
			if reg_expr[i-1] == "\\" and reg_expr[i] == "\\":
				if reg_expr[i+1] not in operator_list and reg_expr[i+1] != ")" and (reg_expr[i+1] in self.alphabet or reg_expr[i+1] == "(" or reg_expr[i+1] == "\\"):
						concat_regex.append("°")
			elif reg_expr[i] == "\\":
				if reg_expr[i-1] == "\\":
					if reg_expr[i+1] not in operator_list and (reg_expr[i+1] in self.alphabet or reg_expr[i+1] == "(" or reg_expr[i+1] == "\\"):
						concat_regex.append("°")

			elif reg_expr[i] in operator_list:
				if reg_expr[i-1] == "\\":
					if reg_expr[i+1] not in operator_list and (reg_expr[i+1] in self.alphabet or reg_expr[i+1] == "(" or reg_expr[i+1] == "\\"):
						concat_regex.append("°")
				else:
					if reg_expr[i] == "*":
						if reg_expr[i+1] not in operator_list and reg_expr[i+1] != ")" and (reg_expr[i+1] in self.alphabet or reg_expr[i+1] ==  "(" or reg_expr[i+1] == "\\"):
							concat_regex.append("°")
			elif reg_expr[i] == "(":
				if reg_expr[i-1] == "\\":
					if reg_expr[i+1] not in operator_list and (reg_expr[i+1] in self.alphabet or reg_expr[i+1] ==  "(" or reg_expr[i+1] == "\\"):
						concat_regex.append("°")
			
			elif reg_expr[i] == ")":
				if reg_expr[i+1] not in operator_list and (reg_expr[i+1] in self.alphabet or reg_expr[i+1] ==  "(" or reg_expr[i+1] == "\\"):
					concat_regex.append("°")
			elif reg_expr[i] in self.alphabet:
				if reg_expr[i+1] not in operator_list and reg_expr[i+1] != ")" and (reg_expr[i+1] in self.alphabet or reg_expr[i+1] == "(" or reg_expr[i+1] == "\\"):
					concat_regex.append("°")
				
		#loops through the regex with concats to make parse tree
		for i in range(len(concat_regex)):
			if concat_regex[i] == '"':
				continue
			#checking for previous backslash
			elif concat_regex[i-1] == "\\" and concat_regex[i-2] != "\\":
				symbol = Node(concat_regex[i])
				symbol.is_leaf = True
				self.operand_stack.append(symbol)
				
				continue
			#Checking for operators
			elif concat_regex[i] != "\\":
				current_node = Node(concat_regex[i])
				if current_node.name == "(" or current_node.name in operator_list:
					if current_node.name == "°":
						self.operator_stack.append(current_node)
					elif current_node.name == "*":
						current_node.left = self.operand_stack.pop()
						self.operand_stack.append(current_node)
					elif current_node.name == "|":
						#if we get a build up of concats then an or, we must calculate those concats first before putting on the or
						if len(self.operator_stack) != 0:
							if self.operator_stack[-1].name == "°":
								implied_concat = self.operator_stack.pop()
						
								while implied_concat.name == "°":
									self.concat_converter(implied_concat)
									if len(self.operator_stack) != 0:
										implied_concat = self.operator_stack.pop()
									else:
										break
								if implied_concat.name != "°":
									self.operator_stack.append(implied_concat) 
						
						self.operator_stack.append(current_node)
					else:
						self.operator_stack.append(current_node)
				#Checking for the end of a parand statement
				elif current_node.name == ")":
					operator = self.operator_stack.pop()
					while operator.name != "(":
						if operator.name == "*":
							operator.left = self.operand_stack.pop()
						if operator.name == "°" or operator.name == "|":
							operator.right = self.operand_stack.pop()
							operator.left = self.operand_stack.pop()
						self.operand_stack.append(operator)
						operator = self.operator_stack.pop()
				#It's important we check for alphabet last because operators and parands could be in alphabet
				elif current_node.name in self.alphabet or current_node.name == "e":
					current_node.is_leaf = True
					self.operand_stack.append(current_node)
		#checking if we have anything left over in the two stacks
		while len(self.operator_stack) != 0:
			operator = self.operator_stack.pop()
			if operator.name == "*":
				operator.left = self.operand_stack.pop()
			if operator.name == "°" or operator.name == "|":
				operator.right = self.operand_stack.pop()
				operator.left = self.operand_stack.pop()
			self.operand_stack.append(operator)

		self.root = self.operand_stack.pop()
		
		self.to_nfa()


	def concat_converter(self, implied_concat):
		"""Used to calculate concats when an or is found in the regex."""
		implied_concat.right = self.operand_stack.pop()
		implied_concat.left = self.operand_stack.pop()
		self.operand_stack.append(implied_concat)
	

	def to_nfa(self):
		"""
		Returns an NFA object that is equivalent to 
		the "self" regular expression
		"""
		self.transitions = {}

		#keeps track of every leaf node of the nfa
		self.potential_star = []
		#keeps track of the or branch we are currently adding on to
		self.potential_or = []
		#keeps track of all the leaf nodes that could be added onto when there is a concat
		self.potential_concat = []

		self.accept_states = []
		self.start_state = 1
		self.state_number = self.start_state
		
		#only hits when there is one symbol in the regex
		if self.root.is_leaf or self.root.name == "e":
			self.singal_symbol_calculator(self.root)

		#If the parse tree starts with concat
		elif self.root.name == "°":
			self.concate_calculator(self.root)
			self.accept_state_calculator()
		#If the parse tree starts with or
		elif self.root.name == "|":
			self.or_calculator(self.root, self.state_number)
			self.accept_state_calculator()
		#If the parse tree starts with star
		elif self.root.name == "*":
			self.star_calculator(self.root,self.state_number)
			self.accept_state_calculator()
		self.nfa = NFA()
		self.nfa.accept_states = self.accept_states
		epsilon_states = set()
		state_set = set()
		
		"""An issue we ran into with the old project is that epsilon clousour is handled in the __init__ method. So
		since we were trying to bypass that to convert our nfa to dfa, we have to compute epsilon clousour here. The
		logic is the exact same as the previous project, we then just pass in into the to_dfa method in the previous project
		and then simulate that dfa in the first project from the simulator in this project."""
		for key in self.transitions:
			state_list = self.transitions[key]
			for state in state_list:
				if key[1] == "e" and not self.nfa.epsilon_transitions.get(key):
					self.nfa.epsilon_list.append(key)
					epsilon_states.add(key[0])
					self.nfa.epsilon_transitions[key] = []
					self.nfa.epsilon_transitions[key].append(state)
				elif key[1] == 'e':
					epsilon_states.add(key[0])
					self.nfa.epsilon_transitions[key].append(state)
					pass
				
				else:
					state_set.add(key[0])
		for key in self.nfa.epsilon_list:
			del self.transitions[key]
		
		for epsilon_key in self.nfa.epsilon_list:
			if int(epsilon_key[0]) not in state_set:
				self.nfa.epsilon_only_states.add(str(epsilon_key[0]))
			epsilon_state = int(epsilon_key[0])
			self.nfa.epsilon_closure(epsilon_key, epsilon_state)

		for transtion in self.transitions:
			for epsilon_state in epsilon_states:
				if int(epsilon_state) in self.transitions[transtion]:
					for state in self.nfa.epsilon_associations[epsilon_state]:
						if state not in self.transitions[transtion]:
							self.transitions[transtion].append(state)
		self.alphabet.remove("e")	
		self.nfa.start_state = ["1"]
		self.nfa.accept_states = self.accept_states
		self.nfa.transitions = self.transitions
		self.nfa.language = self.alphabet
		self.nfa.state_num - self.state_number
		self.nfa.to_DFA()
		
	
	def concate_calculator(self,current_node):
		"""We check leaf children first, this method handles if we run into the concat in the parse tree. It will
		add onto any node found within potential_concat and helps to update potential_star and potential_or. """
		
		if current_node.left.is_leaf or current_node.left.name == "e":
			if len(self.potential_concat) != 0:
				temp = []
				for state in self.potential_concat:
					if state in self.potential_star:
						self.potential_star.remove(state)
					if state in self.potential_or:
						self.potential_or.remove(state)
					self.transitions[(state, current_node.left.name)] = [self.state_number + 1]
					self.state_number += 1
					temp.append(self.state_number)
					self.potential_or.append(self.state_number)
					self.potential_star.append(self.state_number)
				self.potential_concat = []
				for state in temp:
					self.potential_concat.append(state)
					
			else:
				self.transitions[(self.state_number, current_node.left.name)] = [self.state_number + 1]
				if self.state_number in self.potential_star:
					self.potential_star.remove(self.state_number)
				if self.state_number in self.potential_or:
					self.potential_or.remove(self.state_number)
				self.state_number += 1
				self.potential_or.append(self.state_number)
				self.potential_star.append(self.state_number)
		elif current_node.left.name == "|":
			if len(self.potential_concat) != 0:
				tmp = self.potential_concat.copy()
				self.potential_concat = []
				self.potential_or = []
				#Bottle_neck refers to taking the leaf of every branch of the nfa and directing them all to a single node
				#It reduces the recurssion by a whole bunch
				bottle_neck = self.state_number + 1
				self.state_number += 1
				#About to create new states off of these nodes, they will no longer be leafs, so we remove them
				for state in tmp:
					self.potential_star.remove(state)
				self.or_calculator(current_node.left, bottle_neck)
				for state in tmp:
					if state in self.potential_star:
						self.potential_star.remove(state)
					if (state, "e") in self.transitions:
						self.transitions[(state, "e")].append(bottle_neck)
					else:
						self.transitions[(state, "e")] = []
						self.transitions[(state, "e")].append(bottle_neck)
			else:
				self.or_calculator(current_node.left, self.state_number)
		
		elif current_node.left.name == "*":
			if len(self.potential_concat) != 0:
				tmp = self.potential_concat.copy()
				self.potential_concat = []
				self.potential_or = []
				bottle_neck = self.state_number + 1
				self.state_number += 1
				for state in tmp:
					self.potential_star.remove(state)
				self.star_calculator(current_node.left, bottle_neck)
				for state in tmp:
					if state in self.potential_star:
						self.potential_star.remove(state)
					if (state, "e") in self.transitions:
						self.transitions[(state, "e")].append(bottle_neck)
					else:
						self.transitions[(state, "e")] = []
						self.transitions[(state, "e")].append(bottle_neck)
			else:
				self.star_calculator(current_node.left, self.state_number)
		
			
		elif current_node.left.name == "°":
			self.concate_calculator(current_node.left)

		#After this point we start checking right children
		#Whats unique about the right side of concat is that we know this is the end of a branch, so this state will be in potential_star forever
		#Unless there is a star calls on all the leafs
		if current_node.right.is_leaf or current_node.right.name == "e":
			if len(self.potential_concat) != 0:
				temp = []
				for state in self.potential_concat:
					if state in self.potential_or:
						self.potential_or.remove(state)
					if state in self.potential_star:
						self.potential_star.remove(state)
					self.transitions[(state, current_node.right.name)] = [self.state_number + 1]
					self.state_number += 1
					temp.append(self.state_number)
					self.potential_or.append(self.state_number)
					self.potential_star.append(self.state_number)
				self.potential_concat = []
				for state in temp:
					self.potential_concat.append(state)
			else:
				self.transitions[(self.state_number, current_node.right.name)] = [self.state_number + 1]
				if self.state_number in self.potential_or:
					self.potential_or.remove(self.state_number)
				if self.state_number in self.potential_star:
					self.potential_star.remove(self.state_number)
				self.state_number += 1
				self.potential_concat.append(self.state_number)
				self.potential_star.append(self.state_number)
				self.potential_or.append(self.state_number)
		elif current_node.right.name == "|":
			if len(self.potential_concat) != 0:
				tmp = self.potential_concat.copy()
				self.potential_concat = []
				self.potential_or = []
				bottle_neck = self.state_number + 1
				self.state_number += 1
				for state in tmp:
					self.potential_star.remove(state)
				self.or_calculator(current_node.right, bottle_neck)
				for state in tmp:
					if state in self.potential_star:
						self.potential_star.remove(state)
					if (state, "e") in self.transitions:
						self.transitions[(state, "e")].append(bottle_neck)
					else:
						self.transitions[(state, "e")] = []
						self.transitions[(state, "e")].append(bottle_neck)
			else:
				self.or_calculator(current_node.right, self.state_number)
		
		elif current_node.right.name == "*":
			if len(self.potential_concat) != 0:
				tmp = self.potential_concat.copy() 
				self.potential_concat = []
				self.potential_or = []
				bottle_neck = self.state_number + 1
				self.state_number += 1
				for state in tmp:
					self.potential_star.remove(state)
				self.star_calculator(current_node.right, bottle_neck)
				for state in tmp:
					if state in self.potential_star:
						self.potential_star.remove(state)
					if (state, "e") in self.transitions:
						self.transitions[(state, "e")].append(bottle_neck)
					else:
						self.transitions[(state, "e")] = []
						self.transitions[(state, "e")].append(bottle_neck)
			else:
				self.star_calculator(current_node.right, self.state_number)

		elif current_node.right.name == "°":
			self.concate_calculator(current_node.right)
		
				
			
	

		
	def singal_symbol_calculator(self, current_node):
		"""This is rarely used an only exist for a regex that is just a symbol."""
		if current_node.name == "e":
			for symbol in self.alphabet:
				self.transitions[(self.state_number, symbol)] = [self.state_number + 1]
			self.accept_states.append(self.state_number)
		else:
			self.transitions[(self.state_number, current_node.name)] = [self.state_number + 1]
			self.state_number += 1
			self.accept_states.append(self.state_number)

	def or_calculator(self, current_node, state_num):
		"""When we see or we are going to epsilon into two new states, this is a valid way of repesenting an or statement
		in a nfa. After that it checks the left children first, then clears or and appends the right branch, cause that is
		the branch we will now be adding onto. We start left, once done, start adding to right."""
		if not self.transitions.get((state_num, "e")):
			self.transitions[(state_num, "e")] = []
			self.transitions[(state_num, "e")].append(self.state_number + 1)
			self.transitions[(state_num, "e")].append(self.state_number + 2)
		else:
			self.transitions[(state_num, "e")].append(self.state_number + 1)
			self.transitions[(state_num, "e")].append(self.state_number + 2)

		left_branch = self.state_number + 2
		right_branch = self.state_number + 1
		self.state_number += 2
		if(state_num in self.potential_or):
			self.potential_or.remove(state_num)
		if(state_num in self.potential_star):
			self.potential_star.remove(state_num)

		self.potential_star.append(right_branch)
		self.potential_or.append(left_branch)
		if current_node.left.is_leaf or current_node.left.name == "e":
			self.potential_or.remove(left_branch)
			self.transitions[(left_branch, current_node.left.name)] = [self.state_number + 1]
			self.state_number += 1
			self.potential_concat.append(self.state_number)
			self.potential_star.append(self.state_number)
		elif current_node.left.name == "|":
			self.or_calculator(current_node.left, left_branch)
		elif current_node.left.name == "*":
			self.star_calculator(current_node.left, left_branch)
		elif current_node.left.name == "°":
			self.concate_calculator(current_node.left)
		
		#We need concat to be up to date with all leafs only once we are done with this or, so we need to keep track of the left branch
		#While we begin adding to right branch, otherwise concat would add to both when we don't want it to.
		concat_tmp = self.potential_concat.copy()
		self.potential_concat = []
		self.potential_or = []
		self.potential_or.append(right_branch)
		if current_node.right.is_leaf or current_node.right.name == "e":
			self.potential_or.remove(right_branch)
			self.potential_star.remove(right_branch)
			self.transitions[(right_branch, current_node.right.name)] = [self.state_number + 1]
			self.state_number += 1
			self.potential_concat.append(self.state_number)
			self.potential_star.append(self.state_number)
		elif current_node.right.name == "|":
			self.or_calculator(current_node.right, right_branch)
		elif current_node.right.name == "*":
			self.star_calculator(current_node.right, right_branch)
		elif current_node.right.name == "°":
			self.potential_concat.append(right_branch)
			self.concate_calculator(current_node.right)
		#Update concat to have all leafs of the or it just finished adding to, this way when we move back up the parse tree we have all that info.
		self.potential_concat.extend(concat_tmp)

	def star_calculator(self, current_node, orginal_state_num):
		"""The way star works is we keep track of the state we are adding on to, once we are done
		adding onto it, all leaf states epsilon to the orginal state and the orginal state epsilons
		to a new state. This allows this computation to be processed as many times as it wants or no times
		for that matter."""
		#If the leaf child is a symbol, then we just self loop on the orgianl state, very important that it is not epsilon though
		#Epsilon closour does not appreciate self looping epsilons in any form. If you were to follow a states epsilons it can't
		#End up in the orginal state, so the structure of the nfa will never allow for that.
		if current_node.left.is_leaf or current_node.left.name == "e":
			self.transitions[(orginal_state_num, current_node.left.name)] = [orginal_state_num]
			if orginal_state_num not in self.potential_star:
				self.potential_star.append(orginal_state_num)
			if orginal_state_num not in self.potential_concat:
				self.potential_concat.append(orginal_state_num)
		else:
			#Star_tmp becomes important when there are branches we don't want to add onto but still want to remeber for later
			star_tmp = self.potential_star.copy()
			if orginal_state_num in star_tmp:
				star_tmp.remove(orginal_state_num)
			self.potential_star = []
			if current_node.left.name == "|":
				self.or_calculator(current_node.left, orginal_state_num)
				if len(self.potential_star) != 0:
					tmp = self.potential_star.copy() 
					self.potential_star = []
					for state in tmp:
						if state in self.potential_or:
							self.potential_or.remove(state)
						if state in self.potential_concat:
							self.potential_concat.remove(state) 
						if not self.transitions.get((state, "e")):
							self.transitions[(state, "e")] = []
							self.transitions[(state, "e")].append(orginal_state_num)
						else:
							self.transitions[(state, "e")].append(orginal_state_num)
					if not self.transitions.get((orginal_state_num, "e")):
						self.transitions[(orginal_state_num, "e")] = []
						self.transitions[(orginal_state_num, "e")].append(self.state_number+1)
						self.state_number += 1
						self.potential_concat.append(self.state_number)
						self.potential_star.append(self.state_number)
						self.potential_or.append(self.state_number)
					else:
						self.transitions[(orginal_state_num, "e")].append(self.state_number +1)
						self.state_number += 1
						self.potential_concat.append(self.state_number)
						self.potential_star.append(self.state_number)
						self.potential_or.append(self.state_number)
				
				for state in star_tmp:
					self.potential_star.append(state)

				
				
				
			#We do not need to copy star if we are dealing with concat
			elif current_node.left.name == "°":
				self.concate_calculator(current_node.left)
				if len(self.potential_star) != 0:
					tmp = self.potential_star
					self.potential_star = []
					for state in tmp:
						if state in self.potential_or:
							self.potential_or.remove(state)
						if state in self.potential_concat:
							self.potential_concat.remove(state)
						if not self.transitions.get((state, "e")):
							self.transitions[(state, "e")] = []
							self.transitions[(state, "e")].append(orginal_state_num)
						else:
							self.transitions[(state, "e")].append(orginal_state_num)
					if not self.transitions.get((orginal_state_num, "e")):
						self.transitions[(orginal_state_num, "e")] = []
						self.transitions[(orginal_state_num, "e")].append(self.state_number+1)
						self.state_number += 1
						self.potential_concat.append(self.state_number)
						self.potential_star.append(self.state_number)
						self.potential_or.append(self.state_number)
					else:
						self.transitions[(orginal_state_num, "e")].append(self.state_number +1)
						self.state_number += 1
						self.potential_concat.append(self.state_number)
						self.potential_star.append(self.state_number)
						self.potential_or.append(self.state_number)
				
					self.potential_star.extend(star_tmp)
			
		pass


	def accept_state_calculator(self):
		#If a leaf nfa state, we will find it and make it accepting
		non_accepting = set()
		for key in self.transitions:
			state_list = self.transitions[key]
			for state in state_list:
				if key[0] != state and state not in self.accept_states:
					non_accepting.add(key[0])

		for i in range(1, self.state_number + 1):
			if i not in non_accepting:
				self.accept_states.append(i)



		pass
	def simulate(self, str):
		"""
		Returns True if str is in the languages defined
		by the "self" regular expression
		"""
		#Newer project becomes wrapper for old projects.
		return self.nfa.dfa.simulate(str)
	def dfa(self):
		return self.nfa.dfa


if __name__ == "__main__":
	#this_regex = RegEx()
	"""
	num = 5
	regex_filename = f"regex{num}.txt"
	str_filename = f"str{num}.txt"
	correct_results_filename = f"correct{num}.txt"

	print(f"Testing regex {regex_filename} on strings from {str_filename}")

	regex = RegEx(regex_filename)
	
	string_file = open(str_filename)

	results = []
	for str in string_file:
		results.append(regex.simulate(str[str.find('"') + 1:str.rfind('"')]))

	file = open(correct_results_filename)
	correct_results = [True if result == "true" else False for result in file.read().split()]

	if results == correct_results:
		print("  Correct results")
	else:
		print("  Incorrect results")
		print(f"  Your results = {results}")
		print(f"  Correct results = {correct_results}")
	print()
	"""