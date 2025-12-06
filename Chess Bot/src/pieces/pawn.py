from src.enums.color import Color
from src.pieces.bishop import Bishop
from src.pieces.knight import Knight
from src.pieces.piece import Piece
from src.game.position import Position
from typing import List

from src.pieces.queen import Queen
from src.pieces.rook import Rook


class Pawn(Piece):
    def get_valid_moves(self, board) -> List[Position]:
        """Gets list of available moves."""

        valid_moves = []
        direction = 1 if self.color == Color.WHITE else -1  # White moves up, Black moves down
        starting_row = 1 if self.color == Color.WHITE else 6

        # One square move (checks promotion)
        forward_pos = Position(self.position.x, self.position.y + direction)
        if 0 <= forward_pos.y < 8 and not board.get_piece_at(forward_pos):
                valid_moves.append(forward_pos)

        # Move two squares (first turn)
        if not self.has_moved and self.position.y == starting_row:
            double_forward_pos = Position(self.position.x, self.position.y + 2 * direction)
            if not board.get_piece_at(forward_pos) and not board.get_piece_at(double_forward_pos):
                valid_moves.append(double_forward_pos)

        # Capturing moves (diagonal)
        for dx in [-1, 1]:
            capture_pos = Position(self.position.x + dx, self.position.y + direction)
            if 0 <= capture_pos.x < 8 and 0 <= capture_pos.y < 8:
                piece_at_capture = board.get_piece_at(capture_pos)
                if piece_at_capture and piece_at_capture.color != self.color:  # Capture an opponent's piece
                    valid_moves.append(capture_pos)

        return valid_moves

    def can_promote(self) -> bool:
        """Determines if the pawn can be promoted."""
        return self.position.y == 7 if self.color == Color.WHITE else self.position.y == 0

    def promote(self):
        """Promotes the pawn to another piece."""
        if self.can_promote():

            print("Your pawn is promotable. Select an option.\n1. Bishop\n2. Knight\n3. Queen\n4. Rook\n")

            option = input("Please enter your choice (1-4):")

            while option not in ['1','2','3','4']:
                print("Invalid entry. Please try again.")
                option = input("Please enter your choice (1-4): ")

            if option == '1':
                print("You selected: Bishop")
                return Bishop(self.position, self.color)
            elif option == '2':
                print("You selected: Knight")
                return Knight(self.position, self.color)
            elif option == '3':
                print("You selected: Queen")
                return Queen(self.position, self.color)
            elif option == '4':
                print("You selected: Rook")
                return Rook(self.position, self.color)

            return None


