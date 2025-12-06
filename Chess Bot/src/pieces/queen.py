from src.pieces.piece import Piece
from src.game.position import Position
from typing import List

class Queen(Piece):
    def get_valid_moves(self, board) -> List[Position]:
        """Gets list of available moves."""

        directions = [
            (-1,-1), (-1,0), (-1,1),
            (0,-1),          (0,1),
            (1,-1), (1,0), (1,1)
        ]

        valid_moves = []
        x, y = self.position.x, self.position.y

        for dx, dy in directions:
            nx, ny = x + dx, y + dy  # Start moving in the current direction

            # Traverse in the current direction
            while 0 <= nx < 8 and 0 <= ny < 8:  # Ensure within bounds
                new_pos = Position(nx, ny)  # Create a position object for the target square
                target_piece = board.get_piece_at(new_pos)  # Check what's on the target square

                if target_piece is None:  # Empty square
                    valid_moves.append(new_pos)  # Add to valid moves
                elif target_piece.color != self.color:  # Opponent's piece
                    valid_moves.append(new_pos)  # Add capture move
                    break  # Stop moving further in this direction
                else:  # Same-color piece
                    break  # Stop moving further in this direction

                # Move further in the same direction
                nx += dx
                ny += dy

        return valid_moves


