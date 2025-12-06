import unittest
from unittest.mock import Mock

from src.enums.color import Color
from src.game.position import Position
from src.game.square import Square
from src.pieces.pawn import Bishop
from src.pieces.piece import Piece


class TestBishop(unittest.TestCase):

    def setUp(self):
        self.mock_board = Mock()
        self.mock_board.squares = [[Square(Position(x, y), Color.WHITE if (x + y) % 2 == 0 else Color.BLACK)
                                    for y in range(8)] for x in range(8)]

    def mock_empty_board(self):
        """Clears all pieces from the board."""
        for x in range(8):
            for y in range(8):
                self.mock_board.squares[x][y].remove_piece()

    def test_get_valid_moves_from_center(self):
        self.mock_empty_board()
        bishop = Bishop(Position(4, 4), Color.WHITE)
        self.mock_board.squares[4][4].set_piece(bishop)

        valid_moves = bishop.get_valid_moves(self.mock_board)

        expected_moves = [
            Position(3, 3), Position(2, 2), Position(1, 1), Position(0, 0),  # Top-left
            Position(5, 5), Position(6, 6), Position(7, 7),  # Bottom-right
            Position(3, 5), Position(2, 6), Position(1, 7),  # Bottom-left
            Position(5, 3), Position(6, 2), Position(7, 1)   # Top-right
        ]

        self.assertCountEqual(valid_moves, expected_moves)

    def test_valid_moves_blocked_by_same_color(self):
        self.mock_empty_board()
        bishop = Bishop(Position(4, 4), Color.WHITE)

        # Place same-color pieces diagonally to block movement
        self.mock_board.squares[3][3].set_piece(Bishop(Position(3, 3), Color.WHITE))  # Top-left
        self.mock_board.squares[5][5].set_piece(Bishop(Position(5, 5), Color.WHITE))  # Bottom-right
        self.mock_board.squares[3][5].set_piece(Bishop(Position(3, 5), Color.WHITE))  # Bottom-left
        self.mock_board.squares[5][3].set_piece(Bishop(Position(5, 3), Color.WHITE))  # Top-right

        self.mock_board.squares[4][4].set_piece(bishop)

        valid_moves = bishop.get_valid_moves(self.mock_board)
        expected_moves = []

        self.assertCountEqual(valid_moves, expected_moves)

    def test_valid_moves_edge_boundary(self):
        self.mock_empty_board()
        bishop = Bishop(Position(0, 0), Color.WHITE)
        self.mock_board.squares[0][0].set_piece(bishop)

        valid_moves = bishop.get_valid_moves(self.mock_board)

        expected_moves = [
            Position(1, 1), Position(2, 2), Position(3, 3),
            Position(4, 4), Position(5, 5), Position(6, 6), Position(7, 7)
        ]

        self.assertCountEqual(valid_moves, expected_moves)

    def test_bishop_captures_opponent_piece(self):
        self.mock_empty_board()
        bishop = Bishop(Position(4, 4), Color.WHITE)
        self.mock_board.squares[4][4].set_piece(bishop)

        opponent_piece = Mock(spec = Piece)
        opponent_piece.color = Color.BLACK
        self.mock_board.squares[2][2].set_piece(opponent_piece)  # Place opponent piece diagonally

        valid_moves = bishop.get_valid_moves(self.mock_board)

        self.assertIn(Position(2, 2), valid_moves)

if __name__ == "__main__":
    unittest.main()
