
from regex import RegEx
class InvalidToken(Exception):
	""" 
	Raised if while scanning for a token,
	the lexical analyzer cannot identify 
	a valid token, but there are still
	characters remaining in the input file
	"""
	pass

class Lex:
	def __init__(self, regex_file, source_file):
		"""
		Initializes a lexical analyzer.  regex_file
		contains specifications of the types of tokens
		(see problem assignment for format), and source_file
		is the text file that tokens are returned from.
		"""
		self.source_file = source_file
		#For this to work with pa3, all we need to have determined is the regex for every token, and the alphabet
		with open(regex_file, "r") as f:
			alphabet = f.readline().strip()
			alphabet = alphabet[1:-1]
			alphabet_list = []
			self.dfa_token_lookup = {}
			for char in alphabet:
				alphabet_list.append(char)
			alphabet_list.append("e")
			regex = RegEx()
			#Here is where we set up everything for RegEx
			regex.alphabet = alphabet_list
			token_expr = f.readline().split()

			#Keeps going through each line of regex_file, associating each token with its recognizing DFA
			while token_expr:
				token = token_expr[0].strip()
				expr = token_expr[1].strip()
				regex.reg_expr = expr
				#Call the parse_tree maker, this was separated from init because we wanted to have alphabet and regex defined before creating parse tree
				regex.parse_tree()
				#Assign the newly created dfa to token_dfa
				token_dfa = regex.dfa()
				#Associate that dfa(key) with the token(value)
				self.dfa_token_lookup[token_dfa] = token
				#Create a new RegEx to create another dfa for the next token in regex_file
				regex = RegEx()
				alphabet_list.append('e')
				regex.alphabet = alphabet_list
				token_expr = f.readline().split()
			#This will use our new token_lookup dictionary to see if a string is associated with a token
			self.source_file_reader()
			
	def source_file_reader(self):
		"""This reads through the source_file and breaks everything up based on spaces.
		We considered turning the entire file into one long string but the token_finder method
		is much faster at finding tokens with smaller chunks of strings, so we break them up based
		on spacing as a way to help token_finder."""
		with open(self.source_file, 'r') as f:
			src_line = f.readline()
			src_list = []
			while src_line:
				split_list = src_line.split()
				for string in split_list:
					src_list.append(string)
				src_line = f.readline()
			self.token_tuple_list = []
			for string in src_list:
				self.token_finder(string)
			self.token_tuple_list.reverse()



	def token_finder(self, src_str, remaining = ""):
		"""The string passed in from source_file_reader is a string form the source file, this string is either a string
		issolated due to spaces or the source file was just one long string to begin with(like test 12). We then move backwards through the
		string trying it on every dfa we created based on the tokens we got in the regex files. If it doesn't accept in any dfa, we
		shorten the string by one on the right side and store the remainder. Once that string is accepted it is associated with its token
		based on the dfa_token_lookup dictionary and the remainder is reversed and passed in as src_str on token_finder(remainder is emptied by default).
		This continues tell src_str is empty."""
		accepting = False
		#if src_str is empty, but we still have a remainder, it means that string has no valid token.
		if len(src_str) == 0:
			remaining = remaining[::-1]
			#This also supports returning the string that has no valid token, but the tester doesn't need that
			self.token_tuple_list.append(("INVALID", remaining))

		for dfa in self.dfa_token_lookup:
			if dfa.simulate(src_str):
				accepting = True
				self.token_tuple_list.append((self.dfa_token_lookup[dfa], src_str))
				if remaining != "":
					remaining = remaining[::-1]
					self.token_finder(remaining)
				break
		# We take of one from the end of src_str and put it in remainder
		if not accepting and len(src_str) != 0:
			remaining += src_str[-1]
			src_str = src_str[0:-1]
			self.token_finder(src_str, remaining)

		

	
				

	def next_token(self):
		"""
		Returns the next token from the source_file.
		The token is returned as a tuple with 2 item:
		the first item is the name of the token type (a string),
		and the second item is the specific value of the token (also
		as a string).
		Raises EOFError exception if there are not more tokens in the
		file.
		Raises InvalidToken exception if a valid token cannot be identified,
		but there are characters remaining in the source file.
		"""
		if len(self.token_tuple_list) == 0:
			raise EOFError()
		else:
			token = self.token_tuple_list.pop()
			if token[0] == "INVALID":
				raise InvalidToken()
			else:
				return token

		

# You may add additional functions/classes if you need to.

if __name__ == "__main__":
	num = 19   # can replace this with any number 1, ... 22.
	          # can also create your own test files.
	reg_ex_filename = f"regex{num}.txt" 
	source_filename = f"src{num}.txt"
	lex = Lex(reg_ex_filename, source_filename)
	
	try:
		while True:
			token = lex.next_token()
			print(token)
	

	except EOFError:
		pass
	except InvalidToken:
		print("Invalid token")
		
