from unittest.mock import Mock

from src.enums.color import Color
from src.game.square import Square

from unittest import TestCase, mock
from src.pieces.piece import Piece
from src.game.position import Position
from src.pieces.king import King

class TestKing(TestCase):

    def setUp(self):
        self.mock_board = Mock()
        self.mock_squares = [[mock.Mock(spec = Square) for _ in range(8)] for _ in range(8)]
        self.mock_board.squares = self.mock_squares
        self.king = King(Position(4,4), Color.WHITE)

    def test_get_valid_moves_from_center(self):
        for x in range(8):
            for y in range (8):
                self.mock_board.squares[x][y].is_occupied.return_value = False

        valid_moves = self.king.get_valid_moves(self.mock_board)

        expected_moves = [
            Position(3,3), Position(3,4), Position(3,5),
            Position(4,3), Position (4,5), Position(5,3),
            Position(5,4), Position(5,5)
        ]
        self.assertCountEqual(valid_moves, expected_moves)

    def test_valid_moves_blocked_by_same_color(self):
        for dx, dy in [
            (-1,-1), (-1,0), (-1,1),
            (0,-1),          (0,1),
            (1,-1), (1,0), (1,1)]:

            x = 4 + dx
            y = 4 + dy
            self.mock_board.squares[x][y].is_occupied.return_value = True
            self.mock_board.squares[x][y].piece = mock.Mock(spec = Piece)
            self.mock_board.squares[x][y].piece.color = Color.WHITE

        valid_moves = self.king.get_valid_moves(self.mock_board)
        expected_moves = []
        self.assertCountEqual(valid_moves, expected_moves)

    def test_valid_moves_edge_boundary(self):
        self.king = King(Position(0, 0), Color.WHITE)
        for x in range(8):
            for y in range(8):
                self.mock_board.squares[x][y].is_occupied.return_value = False

        valid_moves = self.king.get_valid_moves(self.mock_board)

        expected_moves = [
            Position(0, 1), Position(1, 0), Position(1, 1)
        ]
        self.assertCountEqual(valid_moves, expected_moves)


    def test_king_captures_opponent_piece(self):
        opponent_piece = mock.Mock(spec = Piece)
        opponent_piece.color = Color.BLACK
        self.mock_board.squares[5][5].is_occupied.return_value = True
        self.mock_board.squares[5][5].piece = opponent_piece

        for x in range(8):
            for y in range(8):
                if(x,y) != (5,5):
                    self.mock_board.squares[x][y].is_occupied.return_value = False
                    self.mock_board.squares[x][y].piece = None

        valid_moves = self.king.get_valid_moves(self.mock_board)

        #Check if (5,5) is in the valid moves for a potential capture move
        self.assertIn(Position(5,5), valid_moves)