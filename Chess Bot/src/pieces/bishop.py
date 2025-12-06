from src.pieces.piece import Piece
from src.game.position import Position
from typing import List

class Bishop(Piece):
    def get_valid_moves(self, board) -> List[Position]:
        """Gets list of available moves."""

        directions = [
            (-1,-1),        (-1,1),

            (1,-1),         (1,1)
        ]

        valid_moves = []

        for dx,dy in directions:
            x = self.position.x
            y = self.position.y

            while True:
                x += dx
                y += dy
                new_pos = Position(x,y)

                # Checks new position is within board bounds
                if 0 <=x < 8 and 0 <= y < 8:
                    target_square = board.squares[x][y]
                    piece_at_pos = target_square.piece
                    # Adds position if square is empty
                    if not piece_at_pos:
                        valid_moves.append(new_pos)
                    # Adds position if enemy piece present
                    elif piece_at_pos.color != self.color:
                        valid_moves.append(new_pos)
                        break
                    else:
                        break
                else:
                    break

        return valid_moves

