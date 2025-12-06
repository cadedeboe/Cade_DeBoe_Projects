from typing import TYPE_CHECKING, Optional
from src.game.position import Position

if TYPE_CHECKING:
    from src.game.board import Board
    from src.pieces.piece import Piece

class Move:
    def __init__(self, 
                 from_position: Position, 
                 to_position: Position,
                 piece_moved: 'Piece', 
                 piece_captured: Optional['Piece'] = None):
        self.from_position = from_position
        self.to_position = to_position
        self.piece_moved = piece_moved
        self.piece_captured = piece_captured
        self.executed = False

    def execute(self, board: 'Board'):
        """Executes the move on the board."""
        if not self.executed:
            from_square = board.squares[self.from_position.x][self.from_position.y]
            from_square.remove_piece()
            to_square = board.squares[self.to_position.x][self.to_position.y]
            to_square.set_piece(self.piece_moved)
            self.executed = True
        

    def undo(self, board: 'Board'):
        """Reverts the move."""
        if self.executed:
            to_square = board.squares[self.to_position.x][self.to_position.y]
            to_square.set_piece(self.piece_captured)
            from_square = board.squares[self.from_position.x][self.from_position.y]
            from_square.set_piece(self.piece_moved)
            self.executed = False
        

    def __eq__(self, other):
        if isinstance(other, Move):
            return (self.from_position == other.from_position and
                    self.to_position == other.to_position and
                    self.piece_moved == other.piece_moved and
                    self.piece_captured == other.piece_captured)
        return False