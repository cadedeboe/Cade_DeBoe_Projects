import unittest
from unittest.mock import Mock

from src.enums.color import Color
from src.game.position import Position
from src.pieces.piece import Piece
from src.pieces.queen import Queen


class TestQueen(unittest.TestCase):

    def setUp(self):
        self.mock_board = Mock()

    def test_get_valid_moves_from_center(self):
        self.queen = Queen(Position(4,4), Color.WHITE)
        self.mock_board.get_piece_at.return_value = None
        valid_moves = self.queen.get_valid_moves(self.mock_board)

        expected_moves = [
            Position(4,3), Position(4,2), Position(4,1),
            Position(4,0), Position(4,5), Position(4,6),
            Position(4,7), Position(3,4), Position(2,4),
            Position(1,4), Position(0,4), Position(5,4),
            Position(6,4), Position(7,4), Position(3,3),
            Position(2,2), Position(1,1), Position(0,0),
            Position(5,5), Position(6,6), Position(7,7),
            Position(3,5), Position(2,6), Position(1,7),
            Position(5,3), Position(6,2), Position(7,1),
        ]
        self.assertCountEqual(valid_moves, expected_moves)

    def test_valid_moves_blocked_by_same_color(self):
        self.queen = Queen(Position(4,4), Color.WHITE)
        self.mock_board.get_piece_at.return_value = Mock(color = Color.WHITE)

        valid_moves = self.queen.get_valid_moves(self.mock_board)
        expected_moves = []
        self.assertCountEqual(valid_moves, expected_moves)

    def test_valid_moves_edge_boundary(self):
        queen = Queen(Position(0, 0), Color.WHITE)
        self.mock_board.get_piece_at.return_value = None

        valid_moves = queen.get_valid_moves(self.mock_board)

        expected_moves = [
            Position(0,1), Position(0,2), Position(0,3),
            Position(0,4), Position(0,5), Position(0,6),
            Position(0,7), Position(1,0), Position(2,0),
            Position(3,0), Position(4,0), Position(5,0),
            Position(6,0), Position(7,0), Position(1,1),
            Position(2,2), Position(3,3), Position(4,4),
            Position(5,5), Position(6,6), Position(7,7)
        ]
        self.assertCountEqual(valid_moves, expected_moves)

    def test_queen_captures_opponent_piece(self):
        self.queen = Queen(Position(4,4), Color.WHITE)
        opponent_piece = Mock(spec = Piece)
        opponent_piece.color = Color.BLACK
        self.mock_board.get_piece_at.return_value = opponent_piece

        valid_moves = self.queen.get_valid_moves(self.mock_board)
        expected_move = Position(4,5)

        self.assertIn(expected_move,
                      [move for move in valid_moves if self.mock_board.get_piece_at(move) == opponent_piece])

if __name__ == "__main__":
    unittest.main()