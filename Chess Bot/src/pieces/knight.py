from src.pieces.piece import Piece
from src.game.position import Position
from typing import List

class Knight(Piece):
    def get_valid_moves(self, board) -> List[Position]:
        """Gets list of available moves."""

        directions = [
                  (-1,2),    (1,2),
            (-2,1),                (2,1),
            (-2,-1),               (2,-1),
                  (-1,-2),   (1,-2)
        ]

        valid_moves = []

        for dx,dy in directions:
            new_x = self.position.x + dx
            new_y = self.position.y + dy

            # Checks new position is within board bounds
            if 0 <=new_x < 8 and 0 <= new_y < 8:
                target_square = board.squares[new_x][new_y]

                if not target_square.is_occupied() or target_square.piece.color !=self.color:
                    valid_moves.append(Position(new_x,new_y))

        return valid_moves