# Name: test_pa5.py
# Author: Dr. Glick
# Date: November 17, 2024
# Description: Tests pa5 for comp 370

from lexer import Lex, InvalidToken
from parse import Parser, NonLRGrammarError, SourceFileSyntaxError 

from time import process_time

if __name__ == "__main__":

    # time that testing has to complete in, in processor seconds
    TARGET_RUN_TIME = 0.3

    # Start timing tests
    start_time = process_time() 

    num_test_files = 12
    num_correct_tests = 0
    for i in range(1, num_test_files + 1):
        # Generate filenames
        grammar_filename = f"grammar{i}.txt"
        lexer_filename = f"tokens{i}.txt"
        source_filename = f"src{i}.txt"
        correct_results_filename = f"correct{i}.txt"

        print(f"\nTesting grammar file {grammar_filename}, lexer file {lexer_filename} on source from {source_filename}")

        # Read first line of correct file.
        correct_results_file = open(correct_results_filename)
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
                    num_correct_tests += 1
                else:
                    print("Incorrect.")
                    print(f"Your parse tree = {parse_tree}")
                    print(f"Correct parse tree = {correct_parse_tree}")

        except InvalidToken:
            if correct_answer == "InvalidToken":
                print("Invalid token in source file.  Correct")
                num_correct_tests += 1
            else:
                print("Incorrect.  You raise invalid token when there is not one")
        except NonLRGrammarError:
            if correct_answer == "NonLRGrammarError":
                print("NonLRGrammarError.  Correct")
                num_correct_tests += 1
            else:
                print("Incorrect.  You raise NonLRGrammarError when there is not one")
        except SourceFileSyntaxError:
            if correct_answer == "SourceFileSyntaxError":
                print("SourceFileSyntaxError.  Correct")
                num_correct_tests += 1
            else:
                print("Incorrect.  You raise SourceFileSyntaxError when there is not one")

    # Stop timing the testing.
    finish_time = process_time()
    run_time = finish_time - start_time
    print(f"\nYour runtime was {run_time}\n")

    if num_correct_tests == num_test_files:
        print("All correct.  Nice job")
        print(f"Your runtime was {run_time}")
        if run_time > TARGET_RUN_TIME:
            print("But run time too long.  Review your algorithm implementation.")
            print(f"Target run time is {TARGET_RUN_TIME}")
        else:
            print("Run time less than target.  Nice job!")
            print("Check your program for style requirements before submtting")
    else:
        print(f"Num tests = {num_test_files}")
        print(f"Num correct = {num_correct_tests}.  Keep working on it.")     
        
