import unittest
from unittest.mock import Mock
from src.players.player import Player
from src.enums.color import Color
from src.game.position import Position
from src.game.move import Move

class TestPlayer(Player):
    def make_move(self, game):
        pass

class TestPlayerGetAvailableMoves(unittest.TestCase):
    def setUp(self):
        self.board = Mock()
        self.white_player = TestPlayer("White Player", Color.WHITE)
        self.black_player = TestPlayer("Black Player", Color.BLACK)

    def create_mock_piece(self, color: Color, valid_moves: list[Position]) -> Mock:
        mock_piece = Mock()
        mock_piece.color = color
        mock_piece.get_valid_moves.return_value = valid_moves
        return mock_piece

    def setup_board_pieces(self, piece_positions: dict[Position, Mock]):
        def get_piece_at_side_effect(position):
            return piece_positions.get(position)
        self.board.get_piece_at.side_effect = get_piece_at_side_effect

    def test_get_moves_empty_board(self):
        """Should return empty list when no pieces on board"""
        self.board.get_piece_at.return_value = None
        moves = self.white_player.get_available_moves(self.board)
        self.assertEqual(len(moves), 0)

    def test_get_moves_collects_all_piece_moves(self):
        """Should collect valid moves from all player's pieces"""
        # Setup two pieces with known valid moves
        piece1_pos = Position(1, 1)
        piece2_pos = Position(0, 0)
        moves1 = [Position(1, 2), Position(1, 3)]
        moves2 = [Position(0, 1), Position(0, 2)]
        
        mock_piece1 = self.create_mock_piece(Color.WHITE, moves1)
        mock_piece2 = self.create_mock_piece(Color.WHITE, moves2)
        
        self.setup_board_pieces({
            piece1_pos: mock_piece1,
            piece2_pos: mock_piece2
        })
        
        moves = self.white_player.get_available_moves(self.board)
        self.assertEqual(len(moves), 4)  # Should collect all moves from both pieces

    def test_get_moves_only_collects_own_color(self):
        """Should only collect moves from pieces of player's color"""
        white_piece = self.create_mock_piece(Color.WHITE, [Position(1, 2)])
        black_piece = self.create_mock_piece(Color.BLACK, [Position(2, 2)])
        
        self.setup_board_pieces({
            Position(1, 1): white_piece,
            Position(2, 1): black_piece
        })
        
        moves = self.white_player.get_available_moves(self.board)
        self.assertEqual(len(moves), 1)  # Should only get white piece's move

    def test_get_moves_null_board(self):
        """Should handle null board input"""
        with self.assertRaises(ValueError):
            self.white_player.get_available_moves(None)

if __name__ == '__main__':
    unittest.main()