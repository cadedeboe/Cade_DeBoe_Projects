from unittest import TestCase, mock
from unittest.mock import Mock
from src.enums.color import Color
from src.game.square import Square
from src.game.position import Position
from src.pieces.piece import Piece
from src.pieces.knight import Knight


class TestKnight(TestCase):

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
        knight = Knight(Position(4, 4), Color.WHITE)
        self.mock_board.squares[4][4].set_piece(knight)

        valid_moves = knight.get_valid_moves(self.mock_board)

        expected_moves = [
            Position(3, 6), Position(5, 6),
            Position(3, 2), Position(5, 2),
            Position(2, 3), Position(6, 3),
            Position(2, 5), Position(6, 5)
        ]
        self.assertCountEqual(valid_moves, expected_moves)

    def test_knight_blocked_by_same_color(self):
        self.mock_empty_board()
        knight = Knight(Position(4, 4), Color.WHITE)
        self.mock_board.squares[4][4].set_piece(knight)

        # Place same-color pieces in positions the knight can jump to
        self.mock_board.squares[3][6].set_piece(Knight(Position(3, 6), Color.WHITE))
        self.mock_board.squares[5][6].set_piece(Knight(Position(5, 6), Color.WHITE))

        valid_moves = knight.get_valid_moves(self.mock_board)

        expected_moves = [
            Position(3, 2), Position(5, 2),
            Position(2, 3), Position(6, 3),
            Position(2, 5), Position(6, 5)
        ]
        self.assertCountEqual(valid_moves, expected_moves)

    def test_knight_captures_opponent_piece(self):
        self.mock_empty_board()
        knight = Knight(Position(4, 4), Color.WHITE)
        self.mock_board.squares[4][4].set_piece(knight)

        # Place opponent pieces in positions the knight can jump to
        opponent_piece = mock.Mock(spec=Piece)
        opponent_piece.color = Color.BLACK
        self.mock_board.squares[3][6].set_piece(opponent_piece)

        valid_moves = knight.get_valid_moves(self.mock_board)

        # The knight should include position (3, 6) as a valid move
        self.assertIn(Position(3, 6), valid_moves)

    def test_knight_moves_edge_of_board(self):
        self.mock_empty_board()
        knight = Knight(Position(0, 0), Color.WHITE)
        self.mock_board.squares[0][0].set_piece(knight)

        valid_moves = knight.get_valid_moves(self.mock_board)

        expected_moves = [
            Position(1, 2), Position(2, 1)
        ]
        self.assertCountEqual(valid_moves, expected_moves)


if __name__ == "__main__":
    import unittest
    unittest.main()
