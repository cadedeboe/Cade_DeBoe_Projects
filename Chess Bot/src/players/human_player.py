from src.players.player import Player
from typing import List, Optional, Dict, Tuple
from src.game.move import Move
from src.game.game import Game
from collections import defaultdict
from src.game.board import Board

class HumanPlayer(Player):
    def make_move(self, game: Game) -> Optional[Move]:
        if game.self_check():
            valid_moves = game.in_check_valid_moves()
        else:
            valid_moves = self.get_available_moves(game.board)
        
        if not valid_moves:
            print(f"\nNo valid moves available for {self.name}")
            return None
            
        return self.select_move(valid_moves, game.board)

    def print_moves_list(self, categorized_moves: Dict[str, Dict[str, List[Move]]], board: Board) -> Dict[int, Move]:
        """Prints the categorized list of moves and returns move lookup dictionary."""
        move_lookup = {}
        move_number = 1

        print("Available Moves:")
        for piece_type, move_types in categorized_moves.items():
            print(f"\n{piece_type} Moves:")
            for move_type, moves in move_types.items():
                if moves:  # Only print categories that have moves
                    print(f"  {move_type}:")
                    for move in moves:
                        print(board.format_move_description(move, move_number))
                        move_lookup[move_number] = move
                        move_number += 1

        return move_lookup

    def get_player_choice(self, move_lookup: Dict[int, Move], board: Board) -> Move:
        """Gets and validates the player's move choice."""
        while True:
            try:
                choice = input("\nEnter the number of your move choice: ")
                move_index = int(choice)
                
                if move_index in move_lookup:
                    selected_move = move_lookup[move_index]
                    self.print_move_confirmation(selected_move, board)
                    return selected_move
                else:
                    print("Invalid move number. Please try again.")
            except ValueError:
                print("Please enter a valid number.")

    def print_move_confirmation(self, move: Move, board: Board):
        """Prints confirmation of the selected move."""
        piece_type = move.piece_moved.__class__.__name__
        from_pos = board.convert_to_chess_notation(move.from_position)
        to_pos = board.convert_to_chess_notation(move.to_position)
        capture_info = f" capturing {move.piece_captured.__class__.__name__}" if move.piece_captured else ""
        print(f"\nMoving {piece_type} from {from_pos} to {to_pos}{capture_info}")

    def select_move(self, valid_moves: List[Move], board: Board) -> Move:
        """Main method for move selection process."""
        print(f"\nAvailable moves for {self.name}:")
        
        #Categorize moves
        categorized_moves = board.categorize_moves(valid_moves)
        
        #Create board display
        board_display, move_lookup = board.create_move_display(valid_moves)
        
        #Print board
        board.display_board_state(board_display)
        
        #Print moves list and get updated move lookup
        move_lookup = self.print_moves_list(categorized_moves, board)
        
        #Get player choice and return selected move
        return self.get_player_choice(move_lookup, board)