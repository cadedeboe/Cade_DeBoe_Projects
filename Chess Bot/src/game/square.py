from src.pieces.piece import Piece
from src.game.position import Position
from src.enums.color import Color
from typing import Optional
from src.pieces.pawn import Pawn
class Square:
    def __init__(self, position: Position, color: Color, piece: Optional['Piece'] = None):
        self.position = position
        self.color = color
        self.piece = piece

    def is_occupied(self) -> bool:
        """Checks if a piece occupies the square."""
        return self.piece is not None

    def set_piece(self, piece: 'Piece'):
        """Sets a piece on the square."""
        self.piece = piece

    def remove_piece(self):
        """Clears the square."""
        self.piece = None
        
    def is_promotable(self, piece: 'Piece') -> bool:
        """Determines if the given piece can be promoted"""
        if self.position.y == 7:
            if isinstance(piece, Pawn):
                if piece.color == Color.WHITE:
                    return True
        if self.position.y == 0:
            if isinstance(piece, Pawn):
                if piece.color == Color.BLACK:
                    return True
        return False
        