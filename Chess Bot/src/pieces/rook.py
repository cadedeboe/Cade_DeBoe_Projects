from src.pieces.piece import Piece
from src.game.position import Position
from typing import List

class Rook(Piece):
    def get_valid_moves(self, board) -> List[Position]:
        """Gets list of available moves."""
        directions = [
            (0, 1),  # Right
            (-1, 0),         (1, 0),  # Up, Down
            (0, -1)  # Left
        ]

        valid_moves = []
        x, y = self.position.x, self.position.y

        for dx, dy in directions:
            nx = x + dx
            ny = y + dy

        # Check if the position is within bounds
            while 0 <= nx < 8 and 0 <= ny < 8:
                new_pos = Position(nx, ny)
                target_square = board.squares[nx][ny]

                if target_square.is_occupied():
                    if target_square.piece.color != self.color:
                        valid_moves.append(new_pos)
                    break
                else:
                    valid_moves.append(new_pos)

                nx += dx
                ny += dy

        return valid_moves