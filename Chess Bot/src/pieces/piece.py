from abc import ABC, abstractmethod
from src.game.position import Position
from src.enums.color import Color
from typing import List

class Piece(ABC):
    def __init__(self, position: Position, color: Color):
        self.position = position
        self.color = color
        self.has_moved = False

    @abstractmethod
    def get_valid_moves(self, board) -> List[Position]:
        """Returns valid moves for the piece based on the board state."""
        pass

    def move_to(self, new_position: Position):
        """Updates the piece's position."""
        self.position = new_position
        self.has_moved = True