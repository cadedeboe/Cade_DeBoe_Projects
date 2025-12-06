import unittest
from unittest.mock import Mock, patch

from src.enums.color import Color
from src.game.position import Position
from src.game.square import Square
from src.pieces.pawn import Pawn
from src.pieces.queen import Queen


class TestPawn(unittest.TestCase):

    def setUp(self):
        self.mock_board = Mock()
        self.mock_board.squares = [[Square(Position(x, y), Color.WHITE if (x + y) % 2 == 0 else Color.BLACK)
                                    for y in range(8)] for x in range(8)]

    def mock_empty_board(self):
        """Clears all pieces from the board."""
        for x in range(8):
            for y in range(8):
                self.mock_board.squares[x][y].remove_piece()

    def test_pawn_single_move(self):
        pawn = Pawn(Position(0, 1), Color.WHITE)
        self.mock_board.get_piece_at.return_value = None
        self.mock_board.squares[0][1].set_piece(pawn)

        valid_moves = pawn.get_valid_moves(self.mock_board)
        self.assertIn(Position(0, 2), valid_moves)

    def test_pawn_double_move(self):
        pawn = Pawn(Position(0, 1), Color.WHITE)
        self.mock_board.get_piece_at.return_value = None
        self.mock_board.squares[0][1].set_piece(pawn)

        valid_moves = pawn.get_valid_moves(self.mock_board)
        self.assertIn(Position(0, 3), valid_moves)

    def test_pawn_blocked_by_piece(self):
        pawn = Pawn(Position(4, 4), Color.WHITE)
        blocking_pawn = Pawn(Position(0,2), Color.WHITE)

        def mock_get_piece_at(pos):
            if pos == Position(4, 5):
                return Mock(Color.WHITE)
            return None

        self.mock_board.get_piece_at.side_effect = mock_get_piece_at

        valid_moves = pawn.get_valid_moves(self.mock_board)
        expected_moves = []
        self.assertCountEqual(valid_moves, expected_moves)

    def test_get_valid_moves_captures_diagonally(self):
        pawn = Pawn(Position(3,3), Color.WHITE)

        def mock_get_piece_at(pos):
            if pos == Position(4,4):
                return Mock(color = Color.BLACK)
            if pos == Position(2,4):
                return Mock(color = Color.BLACK)
            if pos == Position(3,4):
                return Mock(color = Color.WHITE)
            return None

        self.mock_board.get_piece_at.side_effect = mock_get_piece_at

        valid_moves = pawn.get_valid_moves(self.mock_board)

        expected_moves = [Position(4, 4), Position(2, 4)]
        self.assertCountEqual(valid_moves, expected_moves)

    def test_pawn_promotion(self):
        pawn = Pawn(Position(4, 6), Color.WHITE)

        self.mock_board.get_piece_at.return_value = None
        pawn.move_to(Position(4,7))
        self.assertTrue(pawn.can_promote())

        # Mock promotion input to '3' (Queen)
        with patch('builtins.input', return_value = '3'):
            promoted_piece = pawn.promote()
            self.assertIsInstance(promoted_piece, Queen)
            self.assertEqual(promoted_piece.position, Position(4, 7))
            self.assertEqual(promoted_piece.color, Color.WHITE)

    def test_get_valid_moves_edge_boundary(self):
        pawn = Pawn(Position(7, 6), Color.WHITE)
        self.mock_board.get_piece_at.return_value = None

        valid_moves = pawn.get_valid_moves(self.mock_board)

        expected_moves = [Position(7, 7)]
        self.assertCountEqual(valid_moves, expected_moves)

if __name__ == "__main__":
    unittest.main()