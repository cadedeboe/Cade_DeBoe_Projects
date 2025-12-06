from abc import ABC, abstractmethod
from typing import List
from src.game.position import Position
from src.enums.color import Color
from src.game.board import Board
from src.game.move import Move

class Player(ABC):
    def __init__(self, name: str, color: Color):
        self.name = name
        self.color = color

    @abstractmethod
    def make_move(self, game):
        """Executes a move within the game."""
        pass

    def get_available_moves(self, board: Board) -> List[Move]:
        if board is None:
            raise ValueError("Board cannot be None")
            
        available_moves = []
        
        # Iterate through board and collect all potential moves
        for x in range(8):
            for y in range(8):
                piece = board.get_piece_at(Position(x, y))
                if piece and piece.color == self.color:
                    # Get potential positions this piece could move to
                    possible_positions = piece.get_valid_moves(board)
                    
                    # Create Move objects for each position
                    for to_position in possible_positions:
                        captured_piece = board.get_piece_at(to_position)
                        # Add check to skip moves that would capture same color pieces
                        if captured_piece and captured_piece.color == self.color:
                            continue
                            
                        move = Move(
                            from_position=Position(x, y),
                            to_position=to_position,
                            piece_moved=piece,
                            piece_captured=captured_piece if captured_piece and captured_piece.color != self.color else None
                        )
                        available_moves.append(move)
        
        return available_moves

    @staticmethod
    def create_player(color: Color) -> 'Player':
        """Factory method to create a player."""
        while True:
            choice = input(f"Enter player type for {color.name} (1 for Human, 2 for AI): ").strip()
            if choice not in ['1', '2']:
                print("Invalid choice. Please enter 1 for Human or 2 for AI.")
                continue
                
            if choice == '1':
                # For human players, ask for name
                while True:
                    name = input(f"Enter name for {color.name} player: ").strip()
                    if not name:
                        print("Name cannot be empty. Please try again.")
                        continue
                    return HumanPlayer(name, color)
            else:
                return AIPlayer(f"AI_{color.name}", color)