from lexer import InvalidToken, Lex

# Exception classes defined for the project.
class NonLRGrammarError(Exception):
    """ Raised when the parser generator detects on non-LR grammar. """

    pass

class SourceFileSyntaxError(Exception):
    """ Raised when the parser determines that the source file does not match the grammar. """

    pass

class Node:
    """Represents a node in the parse tree supporting LR parsing."""
    
    def __init__(self, symbol, is_terminal=False):
        """Initialize parse tree node.
        
        Args:
            symbol (str): Grammar symbol (terminal or nonterminal)
            is_terminal (bool): True if node represents terminal symbol
        """
        self.symbol = symbol
        self.is_terminal = is_terminal
        self.children = []
        
    def add_child(self, child):
        """Add child node to this node."""
        self.children.append(child)
        
    def pre_order_traversal(self):
        """Perform depth-first pre-order traversal starting at this node.
        
        Returns:
            list: Nodes in pre-order traversal order
        """
        result = [self]
        for child in self.children:
            result.extend(child.pre_order_traversal())
        return result
    
    def __str__(self):
        """String representation showing symbol type."""
        node_type = "Terminal" if self.is_terminal else "Nonterminal"
        return f"{node_type}({self.symbol})"

class Item:
    """ Represents a single item in a state of the LR automaton. 
    
    An item is a single rule from the grammar, plus a dot positioned 
    in the rhs of the rule to indicate how much of the rule has been 
    parsed.
    """
    
    def __init__(self, rule, dot_pos):
        """ Initializes an Item object.

        Parameters:
        rule: Rule
            The rule part of the Item.
        dotpos: int
            Where the dot is in the rule.  (0 if dot is to the left 
            of the leftmost symbol on rhs of rule, 1 if to the right of the
            leftmost symbol on rhs of rule, and so on.)

        Returns None.        
        """

        self.rule = rule
        self.dot_pos = dot_pos

    def __eq__(self, other):
        """ Checks for equality of two items.  """

        if self.__class__ != other.__class__:
            return False
        
        return self.rule == other.rule and self.dot_pos == other.dot_pos
    
    def __hash__(self):
        """ Shows how to hash an Item.  
        
        This then allows an Item to be the key of a dictionary.
        """

        return hash((self.rule, self.dot_pos))
    
class State:
    """ Represents a single state in the LR Automaton. """

    def __init__(self, items):
        """ Initializes a state of the LR Automaton.
        
        Parameters:
        items: set of Item
            The set of items that defines the state.

        Returns None
        """

        self.items = items
        self.action = {} # Dictionary telling what action to take from
        # the "self" state, given the next terminal in the input.  terminal can
        # also be the end of input symbol.  You will fill in this dictionary later.  
        # It should conform to:
        # self.action[terminal] = ("shift", indx)  (shift to state index indx)
        # self.action[terminal] = ("reduce", rule_indx) (reduce by rule whose index is rule_indx)
        # self.action[terminal] = ("accept", ) (accept the input)
        # and if self.action[terminal] is not defined, an error condition - the input is not in the 
        # language of the grammar.
        self.goto = {} # Dictionary telling what state to transition to from this state, 
        # on a reduction operation, given the lhs variable of the rule being reduced.  You
        # will fill in this dictionary later.  It should conform to:
        # self.goto[var] = state_indx (When reducing by a rule for variable var, transition to 
        # # state state_indx)

class Rule:
    """ Represents a single rule of the grammar. """

    def __init__(self, rule, rule_number, lhs, rhs):
        """ Initializes a rule.
        
        Parameters:
        rule: string
            string representation of the rule. For example: "S : A B" (A single space
            separates the different tokens in the rule.)
        rule_number: int
            Rules are numbered so they can be referred to by number in the action and goto 
            dictionaries of a state.
        lhs: string
            Variable on left-hand side of the rule
        rhs: list of strings
            list of symbols that make up the right-hand side of the rule

        Returns None
        """

        self.rule = rule
        self.rule_number = rule_number
        self.lhs = lhs 
        self.rhs = rhs
    
class Parser:
    """ Manages parsing of an input file, given the grammar
        specification, and the specification of the terminals 
        of the grammar.
    """

    def __init__(self, lexer_filename, grammar_filename, source_filename):
        """ Initializes the Parser object.
        
        Parameters:
        lexer_filename: string
            Name of file containing the specifications of the terminals
            of the grammar.  Terminals are specified by regular expressions.
            (Format of this file is specified in pa4 problem statement.)

        grammar_filename: string
            Name of file containing specification of the grammar.  (Format
            of this file is specified in pa5 problem statement.)

        source_filename: string
            Name of the file containing the input to the parser.
        """

        self.end_of_input = "END_OF_INPUT"
        self.dummy_start_symbol = "dummy_start"
        self.start_state_num = 0 # Always 0
        self.epsilon = "eps"  # An epsilon rule in the grammar must have this as its rhs.
        self.accept_action = "accept"

        try:
            # Create lexical analyzer.  Use code from pa4 for this.
            self.lexer = Lex(lexer_filename, source_filename)

            # Read the grammar file.
            self.terminals, self.nonterminals, self.rules, self.rules_by_lhs = \
                self.read_grammar_file(grammar_filename)

            # Compute first and follow functions for the input grammar.
            self.first = self.compute_first()
            self.follow = self.compute_follow()

            # Compute the parse table for the grammar.
            self.states = self.compute_parse_table_states()
        
        except InvalidToken:
            print(f"Invalid token while processing input file {source_filename}")

    def read_grammar_file(self, grammar_filename):
        """ Reads the grammar file, initializing instance variables associated with the grammar.
        
        Parameters:

        grammar_filename: string
            Name of file containing grammar specification.

        Returns: (terminals, nonterminals, rules, rules_by_lhs):

        terminals: set
            Set of grammar terminals

        nonterminals: set
            Set of grammar nonterminals (variables)

        rules: list of Rule
            List of grammar rules

        rules_by_lhs: dict
            Dictionary mapping grammar nonterminals to set of rules
            for that nonterminal.

        Exceptions raised:

        FileNotFoundError, if grammar file could not be opened.

        """
        try:
            # Open file                                                                                                           fd
            f = open(grammar_filename)

            # Initialize variables to store grammar.
            terminals = set()
            nonterminals = set()
            rules = []  
            rules_by_lhs = {}

            # Start counting the rules
            rule_number = 0

            # Read terminals
            while True:
                line = f.readline()
                if line.strip() == "%%":
                    break
                line_terminals = line.split()
                for term in line_terminals:
                    terminals.add(term)
            
            # Add end of input terminal
            terminals.add(self.end_of_input)

            # Read first rule from file.
            line = f.readline()
            rule = self.parse_rule(line, 1)  # Will be rule number 1

            # Create dummy first rule
            nonterminals.add(self.dummy_start_symbol)
            self.dummy_rule = Rule("", rule_number, self.dummy_start_symbol, (rule.lhs,))
            rules.append(self.dummy_rule)
            rules_by_lhs[self.dummy_start_symbol] = {self.dummy_rule}

            # Add first rule from file
            rule_number += 1
            nonterminals.add(rule.lhs)
            rules.append(rule)
            rules_by_lhs[rule.lhs] = {rule}

            # Read remaining rules
            while True:
                # Get the line
                line = f.readline()

                # Check for end of file
                if len(line.strip()) == 0:
                    break
           
                # Check for end of section
                if line.strip() == "%%":
                    break

                # Got another rule
                rule_number += 1
                
                # Process
                rule = self.parse_rule(line, rule_number)
                nonterminals.add(rule.lhs)
                rules.append(rule)
                if rule.lhs not in rules_by_lhs:
                    rules_by_lhs[rule.lhs] = {rule}
                else:
                    rules_by_lhs[rule.lhs].add(rule)
            
            # Return data
            return terminals, nonterminals, rules, rules_by_lhs
        except FileNotFoundError:
            raise FileNotFoundError(f"Could not open grammar file {grammar_filename}")
        
    def parse_rule(self, line, rule_number):
        """ Parse a single rule from the grammar 
        
        Parameters:

        line: string
            Line containing the rule
        
        rule_number: int
            Number assigned to this rule

        Returns: Rule
            The rule that was read in.
        """

        # Strip leading and trailing spaces
        temp_line = line.strip()

        # Get the rule
        tokens = tuple(temp_line.split())
        rule = " ".join(tokens)

        return Rule(rule, rule_number, tokens[0], tokens[2:])

    def compute_first(self):
        """
        Compute first dictionary for all grammar symbols, and for
        all strings of grammar symbols that follow a nonterminal
        in a rule.
        Assumes epsilon only appears in a rule of the form X -> epsilon.

        Returns: dict
            key is string that is any terminal, nonterminal, or any 
            substring of a rule rhs following a nonterminal in the rule rhs.
            value is the set of terminals that can appear first in a string
            derived from the nonterminal.
        """
        # Initialize
        first = {}
        for nonterminal in self.nonterminals:
            first[nonterminal] = set()
        for terminal in self.terminals:
            first[terminal] = {terminal}

        # Compute first for all nonterminals
        
        # Handle rules of the form X -> epsilon
        for rule in self.rules:
            if rule.rhs[0] == self.epsilon:
                first[rule.lhs].add(self.epsilon)

        # Handle other rules.  Keep going until all rules
        # are processed without adding anything to first for a nonterminal.
        while True:
            updated = False
            # Check every rule
            for rule in self.rules:
                # Skip epsilon rules
                if rule.rhs[0] == self.epsilon:
                    continue

                first_of_rhs = self.first_of_substring(first, rule.rhs)
                if not first_of_rhs.issubset(first[rule.lhs]):
                    updated = True
                    first[rule.lhs].update(first_of_rhs)
      
            if not updated:
                # All done
                break
                
        # Compute first for all strings of grammar symbols that follow a nonterminal
        # in a rule
        for rule in self.rules:
            for i in range(len(rule.rhs) - 1):
                if rule.rhs[i] in self.nonterminals:
                    str = rule.rhs[i+1:]
                    first[str] = self.first_of_substring(first, str)

        # Return first
        return first

    def first_of_substring(self, first, symbols):
        """
        Returns the first function of the list of symbols.

        Parameters

        first: dict
            First dictionary where key is a grammar symbol,
            and value is the set of terminals that can appear
            first in a string derived from the grammar symbol.

        symbols: string
            List of symbols whose first function is to be
            computed.

        Returns: set
            Returns set that is the first function of symbols.
        """

        # Initialize first set to return
        first_to_return = set()

        # Check symbols from left to right
        all_symbols_generate_eps = True
        for symbol in symbols:
            terminals = first[symbol]
            for terminal in terminals:
                if terminal != self.epsilon:
                    first_to_return.add(terminal)
            if self.epsilon not in first[symbol]:
                # Don't check any more symbols in rhs of this rule
                all_symbols_generate_eps = False
                break 

        if all_symbols_generate_eps:
            first_to_return.add(self.epsilon)

        return first_to_return
                
    def compute_follow(self):
        """ Compute and return follow dictionary for all nonterminals in the grammar.

        Returns: dict
            key is nonterminal in the grammar.
            value is the set of terminal symbols that can follow 
            a string derived by the nonterminal.
        """

        # Initialize
        follow = {}
        for nonterminal in self.nonterminals:
            follow[nonterminal] = set()
        follow[self.dummy_start_symbol].add(self.end_of_input)

        # Compute follow for all nonterminals

        # Keep adding terminals to follow until no more can be added
        while True:
            updated = False
            for rule in self.rules:
                for i in range(len(rule.rhs) - 1):
                    symbol = rule.rhs[i]
                    if symbol in self.nonterminals:
                        remainder = rule.rhs[i+1:]
                        first_remainder = self.first[remainder]
                        for terminal in first_remainder:
                            if terminal != self.epsilon and terminal not in follow[symbol]:
                                follow[symbol].add(terminal)
                                updated = True
                        if self.epsilon in first_remainder:
                            for terminal in follow[rule.lhs]:
                                if terminal not in follow[symbol]:
                                    follow[symbol].add(terminal)
                                    updated = True

                # Handle last symbol on rhs
                symbol = rule.rhs[-1]
                if symbol in self.nonterminals:
                    for terminal in follow[rule.lhs]:
                        if terminal not in follow[symbol]:
                            follow[symbol].add(terminal)
                            updated = True

            if not updated:
                # all done
                break

        # All done. Return follow dictionary
        return follow
    
    def compute_parse_table_states(self):
        """ Compute the states of the parse table 

        Returns: set of State
            Returns set of states of the parse tables.
        """

        # Initialize set of states with start state
        start_items = {Item(self.rules[0], 0)}
        start_state = State(self.items_closure(start_items))
        states = [start_state]

        # Generate all other states "on demand"
        i = 0
        while i < len(states):
            state = states[i]

            # You will write this method.
            # Compute all transitions (for terminals and nonterminals) out of "state".
            # Transitions for terminals will go into the action dictionary for the state,
            # and transitions for nonterminals will go into the goto dictionary for the state.
            # Remember that there will not necessarily be valid transitions for all grammar symbols.

            # Whenever you define a state to transition to, that state (which is defined by a set
            # of items) will either be a new state (add it to the list of states), or an existing
            # state (don't add it, but gets it's id).  You will have to decide which is the case.

        return states

    def items_closure(self, items):
        """ Updates set of items to contain the closure of itself.

        Parameters:

        items: set of Item
            The set of items to compute the closure of.  These are the
            items that have been initially placed into a state.

        Returns: set of Item
            Returns the closure of the set of items.  This will be the full
            set of items of a state.
        """

        # Add all of the items in the parameter set to the set of items
        # to be returned.
        closure = set(items)

        # Put all of the items in the parameter set in a collection of items
        # to be processed.
        work_list = list(closure)

        # Then, as long as this collection of items is not empty, ...
        while work_list:

        # Take an item i from this collection, and if there is a variable v 
        # directly to the right of the dot in the item, then create items
            item = work_list.pop()
            rhs = item.rule.rhs
            dot_pos = item.dot_pos
            
        # for each of v's rules (with the dot all the way to the left), and for 
        # each of those items, if it is not already in the set of items to be 
        # returned, add it to the set of items to be returned, and also add it to 
        # the collection of items to be processed.
            if dot_pos < len(rhs) and rhs[dot_pos] in self.nonterminals:
                nonterminal = rhs[dot_pos]
            
            # Add items for all productions of the nonterminal
            for rule in self.rules_by_lhs[nonterminal]:
                new_item = Item(rule, 0)
                if new_item not in closure:
                    closure.add(new_item)
                    work_list.append(new_item) 
        return closure

    def parse(self):
        """ Parse the source file.

        Returns: list
            Returns the parse tree for the source file, returned as a list generated
            by visiting the nodes of the parse tree in depth-first, pre-order fashion.
            Each node of the parse tree is a string containing a grammar symbol - nonterminals for 
            interior nodes, and terminals (or eps) for leaf nodes.

        Exceptions raised:

        lex.InvalidToken: raised by the next_token method of the Lex class
        if the next symbols in the input are not a valid token.

        NonLRGrammarError: raised by the parse method of the Parser class
        if the method detects that the input grammar is no an LR(1) grammar.

        SourceFileSyntaxError: raised by the parse method of the Parser class
        if the method detects that the next input token is valid for the grammar.
        """

        # YOU WILL WRITE ALL OF THE CODE FOR THIS METHOD
        pass  

if __name__ == "__main__":
    lexer_filename = "tokens1.txt"
    grammar_filename = "grammar1.txt"
    source_filename = "src1.txt"
    correct_filename = "correct1.txt"

    parser = Parser(lexer_filename, grammar_filename, source_filename)
    
    # Read first line of correct file.
    correct_results_file = open(correct_filename)
    correct_answer = correct_results_file.readline().strip()

    try:
        # Create parser, and parse
        parser = Parser(lexer_filename, grammar_filename, source_filename)
        parse_tree = parser.parse()

        if correct_answer == "InvalidToken":
            print("Incorrect.  You should have raised InvalidToken exception (in source file)")
        elif correct_answer == "NonLRGrammarError":
            print("Incorrect.  You should have raised NonLRGrammar exception")
        elif correct_answer == "SourceFileSyntaxError":
            print("Incorrect.  You should have raised SourceFileSyntaxError exception")
        else:
            # Make sure parse returns correct parse tree

            # Read correct parse tree
            correct_parse_tree = [node for node in correct_results_file.readline().split()]
            if parse_tree == correct_parse_tree:
                print("Correct.  Parse tree correct")
            else:
                print("Incorrect.")
                print(f"Your parse tree = {parse_tree}")
                print(f"Correct parse tree = {correct_parse_tree}")

    except InvalidToken:
        if correct_answer == "InvalidToken":
            print("Invalid token in source file.  Correct")
        else:
            print("Incorrect.  You raise invalid token when there is not one")
    except NonLRGrammarError:
        if correct_answer == "NonLRGrammarError":
            print("NonLRGrammarError.  Correct")
        else:
            print("Incorrect.  You raise NonLRGrammarError when there is not one")
    except SourceFileSyntaxError:
        if correct_answer == "SourceFileSyntaxError":
            print("SourceFileSyntaxError.  Correct")
        else:
            print("Incorrect.  You raise SourceFileSyntaxError when there is not one")
