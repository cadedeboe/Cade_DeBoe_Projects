from unittest.mock import Mock

from src.enums.color import Color
from src.game.square import Square

from unittest import TestCase, mock
from src.game.position import Position
from src.pieces.piece import Piece
from src.pieces.rook import Rook

class TestRook(TestCase):

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

        self.rook = Rook(Position(4,4), Color.WHITE)
        self.mock_board.squares[4][4].set_piece(self.rook)  # Place the rook at (4, 4)

        valid_moves = self.rook.get_valid_moves(self.mock_board)

        expected_moves = [
            Position(4,3), Position(4,2), Position(4,1),
            Position(4,0), Position(4,5), Position(4,6),
            Position(4,7), Position(3,4), Position(2,4),
            Position(1,4), Position(0,4), Position(5,4),
            Position(6,4), Position(7,4)
        ]
        self.assertCountEqual(valid_moves, expected_moves)

    def test_valid_moves_blocked_by_same_color(self):
        """Test Rook moves when blocked by same-color pieces."""
        self.mock_empty_board()
        self.rook = Rook(Position(4,4), Color.WHITE)

    # Place same-color pieces to block rook's movement
        self.mock_board.squares[4][5].set_piece(Rook(Position(4, 5), Color.WHITE))  # Right
        self.mock_board.squares[5][4].set_piece(Rook(Position(5, 4), Color.WHITE))  # Down
        self.mock_board.squares[4][3].set_piece(Rook(Position(4, 3), Color.WHITE))  # Left
        self.mock_board.squares[3][4].set_piece(Rook(Position(3, 4), Color.WHITE))  # Up

        # Rook should stop before reaching same-color pieces
        valid_moves = self.rook.get_valid_moves(self.mock_board)

        expected_moves = []

        self.assertCountEqual(valid_moves, expected_moves)

    def test_valid_moves_edge_boundary(self):

        self.mock_empty_board()
        self.rook = Rook(Position(0, 0), Color.WHITE)
        self.mock_board.squares[0][0].set_piece(self.rook)

        valid_moves = self.rook.get_valid_moves(self.mock_board)

        expected_moves = [
            Position(0,1), Position(0,2), Position(0,3),
            Position(0,4), Position(0,5), Position(0,6),
            Position(0,7), Position(1,0), Position(2,0),
            Position(3,0), Position(4,0), Position(5,0),
            Position(6,0), Position(7,0)
        ]
        self.assertCountEqual(valid_moves, expected_moves)

    def test_rook_captures_opponent_piece(self):
        self.mock_empty_board()
        self.rook = Rook(Position(4,4), Color.WHITE)
        self.mock_board.squares[4][4].set_piece(self.rook)

        opponent_piece = mock.Mock(spec = Piece)
        opponent_piece.color = Color.BLACK
        self.mock_board.squares[4][5].set_piece(opponent_piece)

        valid_moves = self.rook.get_valid_moves(self.mock_board)

        self.assertIn(Position(4,5), valid_moves)

if __name__ == "__main__":
    import unittest
    unittest.main()



