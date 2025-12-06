# Lexical Analyzer

A Python implementation of a lexical analyzer (lexer) that uses regular expressions, finite automata (NFA/DFA), and parsing techniques to tokenize source code files.

## Overview

This project implements a complete lexical analysis system that:
- Parses regular expressions and converts them to finite automata
- Converts NFAs (Nondeterministic Finite Automata) to DFAs (Deterministic Finite Automata)
- Tokenizes source files based on regex patterns
- Provides an LR parser framework (incomplete)

## Project Structure

```
.
├── dfa.py          # DFA (Deterministic Finite Automaton) implementation
├── nfa.py          # NFA (Nondeterministic Finite Automaton) implementation
├── regex.py        # Regular expression parser and converter to NFA/DFA
├── lexer.py        # Main lexical analyzer that tokenizes source files
├── parse.py        # LR parser implementation (incomplete)
└── test_pa5.py     # Test suite for the parser component
```

## Components

### DFA (`dfa.py`)
- Implements a Deterministic Finite Automaton class
- Reads DFA specifications from files
- Simulates DFA execution on input strings
- Validates file format and DFA structure

### NFA (`nfa.py`)
- Implements a Nondeterministic Finite Automaton class
- Handles epsilon transitions and epsilon closure
- Converts NFAs to equivalent DFAs using subset construction
- Reads NFA specifications from files

### RegEx (`regex.py`)
- Parses regular expressions with operators: `|` (union), `*` (Kleene star), `°` (concatenation)
- Builds parse trees from regular expressions
- Converts regular expressions to NFAs using Thompson's construction
- Automatically converts NFAs to DFAs for efficient simulation

### Lexer (`lexer.py`)
- Main lexical analyzer class
- Reads token specifications from regex files
- Tokenizes source files using longest match strategy
- Returns tokens as tuples: `(token_type, token_value)`
- Raises `InvalidToken` exception for unrecognized tokens
- Raises `EOFError` when no more tokens are available

### Parser (`parse.py`)
- Implements an LR(1) parser framework
- Computes FIRST and FOLLOW sets
- Builds parse tables for LR parsing
- Currently incomplete (parse method not fully implemented)

## Usage

### Basic Lexer Usage

```python
from lexer import Lex, InvalidToken

# Initialize lexer with regex file and source file
lex = Lex("regex1.txt", "src1.txt")

try:
    while True:
        token = lex.next_token()
        print(token)  # Prints (token_type, token_value)
except EOFError:
    print("End of file reached")
except InvalidToken:
    print("Invalid token encountered")
```

### Running Tests

```bash
# Run the parser test suite
python test_pa5.py

# Run lexer directly (modify test number in lexer.py)
python lexer.py
```

## File Formats

### Regex File Format
```
[alphabet]
TOKEN_NAME regex_pattern
TOKEN_NAME regex_pattern
...
```

Example:
```
[abc]
IDENTIFIER a(a|b|c)*
NUMBER (0|1|2|3|4|5|6|7|8|9)+
```

### Source File Format
Plain text file containing the input to be tokenized.

### Grammar File Format (for parser)
```
terminal1 terminal2 ...
%%
S : A B
A : a
B : b
```

## Regular Expression Operators

- `|` - Union (OR)
- `*` - Kleene star (zero or more repetitions)
- `°` - Concatenation (implicit or explicit)
- `()` - Grouping
- `\` - Escape character for special symbols

## Requirements

- Python 3.x
- No external dependencies (uses only standard library)

## Features

- **Efficient Tokenization**: Uses DFAs for fast token recognition
- **Longest Match**: Implements longest match strategy for token recognition
- **Error Handling**: Comprehensive error handling with custom exceptions
- **Epsilon Transition Handling**: Properly handles epsilon transitions in NFAs
- **Subset Construction**: Efficient NFA to DFA conversion

## Author

Cade DeBoe (and Sebastian Fernandez for some components)

## Course

Comp 370 - Fall 2024

## Notes

- The parser component (`parse.py`) is incomplete and requires implementation of the `parse()` method
- The project was developed as part of programming assignments (PA1-PA5) for a compiler/automata theory course
- Test files (regex*.txt, src*.txt, grammar*.txt, tokens*.txt) are expected to be in the same directory

