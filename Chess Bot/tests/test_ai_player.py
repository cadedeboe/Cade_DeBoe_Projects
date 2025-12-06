import unittest
from unittest.mock import Mock, patch
from src.players.ai_player import AIPlayer
from src.enums.color import Color
from src.game.move import Move
from src.game.game import Game
from src.game.board import Board
from src.game.position import Position
from src.pieces.piece import Piece
from src.enums.game_status import GameStatus

class TestAIPlayer(unittest.TestCase):
    def setUp(self):
        """Set up test fixtures before each test method."""
        self.ai_player = AIPlayer("AI", Color.WHITE)
        self.game = Mock(spec=Game)
        self.board = Mock(spec=Board)
        self.game.board = self.board
        self.game.game_status = GameStatus.ONGOING

    # Helper Methods
    def create_mock_piece(self, piece_type: str, color: Color) -> Mock:
        """Creates a mock piece with given type and color."""
        piece = Mock()
        piece.color = color
        piece.__class__.__name__ = piece_type
        return piece

    def setup_board_with_pieces(self, piece_positions: list) -> None:
        """Sets up board with pieces at specific positions."""
        def get_piece_at(position):
            for pos, piece in piece_positions:
                if position.x == pos[0] and position.y == pos[1]:
                    return piece
            return None
        self.board.get_piece_at.side_effect = get_piece_at

    def create_mock_moves(self, count: int) -> list:
        """Creates specified number of mock moves."""
        return [Mock(spec=Move) for _ in range(count)]

    def setup_evaluation_counter(self) -> tuple:
        """Sets up a counter for evaluation calls."""
        eval_count = 0
        def count_evals(*args):
            nonlocal eval_count
            eval_count += 1
            return 100
        return eval_count, count_evals

    def setup_move_tracking(self) -> tuple:
        """Sets up tracking for move execution order."""
        execution_order = []
        mock_move = Mock(spec=Move)
        
        def track_execute(board):
            execution_order.append('execute')
        def track_undo(board):
            execution_order.append('undo')
            
        mock_move.execute.side_effect = track_execute
        mock_move.undo.side_effect = track_undo
        return execution_order, mock_move

    # Make Move Tests
    def test_make_move_with_null_board(self):
        """Test make_move raises ValueError with null board."""
        self.game.board = None
        with self.assertRaises(ValueError):
            self.ai_player.make_move(self.game)

    def test_make_move_game_not_ongoing(self):
        """Test make_move returns None when game is not ongoing."""
        self.game.game_status = GameStatus.CHECKMATE
        self.assertIsNone(self.ai_player.make_move(self.game))

    # Minimax Root Tests
    def test_minimax_root_no_available_moves(self):
        """Test minimax_root returns None when no moves are available."""
        with patch.object(self.ai_player, 'get_available_moves', return_value=[]):
            self.assertIsNone(self.ai_player.minimax_root(3, self.game, True))

    def test_minimax_root_finds_best_move(self):
        """Test minimax_root selects the best move."""
        moves = self.create_mock_moves(2)
        with patch.object(self.ai_player, 'get_available_moves', return_value=moves):
            with patch.object(self.ai_player, 'minimax', side_effect=[10, 5]):
                result = self.ai_player.minimax_root(3, self.game, True)
        self.assertEqual(result, moves[0])

    def test_minimax_root_invalid_depth(self):
        """Test minimax_root with negative depth parameter."""
        with self.assertRaises(ValueError):
            self.ai_player.minimax_root(-1, self.game, True)

    # Minimax Tests
    def test_minimax_at_depth_zero(self):
        """Test minimax returns evaluation when depth is zero."""
        with patch.object(self.ai_player, 'evaluate_position', return_value=42):
            result = self.ai_player.minimax(0, self.game, float('-inf'), float('inf'), True)
            self.assertEqual(result, 42)

    def test_minimax_game_not_ongoing(self):
        """Test minimax returns evaluation when game is not ongoing."""
        self.game.game_status = GameStatus.STALEMATE
        with patch.object(self.ai_player, 'evaluate_position', return_value=42):
            result = self.ai_player.minimax(3, self.game, float('-inf'), float('inf'), True)
            self.assertEqual(result, 42)

    def test_minimax_maximizing_player(self):
        """Test minimax when maximizing player."""
        moves = self.create_mock_moves(2)
        with patch.object(self.ai_player, 'get_available_moves', return_value=moves):
            with patch.object(self.ai_player, 'evaluate_position', side_effect=[10, 20]):
                result = self.ai_player.minimax(1, self.game, float('-inf'), float('inf'), True)
                self.assertEqual(result, 20)

    def test_minimax_minimizing_player(self):
        """Test minimax when minimizing player."""
        moves = self.create_mock_moves(2)
        with patch.object(self.ai_player, 'get_available_moves', return_value=moves):
            with patch.object(self.ai_player, 'evaluate_position', side_effect=[10, 5]):
                result = self.ai_player.minimax(1, self.game, float('-inf'), float('inf'), False)
                self.assertEqual(result, 5)

    # Position Evaluation Tests
    def test_evaluate_simple_position(self):
        """Test position evaluation with queen vs pawn."""
        pieces = [
            ((0, 0), self.create_mock_piece("Queen", Color.WHITE)),  # +9
            ((1, 1), self.create_mock_piece("Pawn", Color.BLACK)),   # -1
        ]
        self.setup_board_with_pieces(pieces)
        self.assertEqual(self.ai_player.evaluate_position(self.game), 8)

    def test_evaluate_position_empty_board(self):
        """Test position evaluation with empty board."""
        self.board.get_piece_at.return_value = None
        self.assertEqual(self.ai_player.evaluate_position(self.game), 0)

    def test_evaluate_position_unknown_piece(self):
        """Test evaluate_position with unknown piece type."""
        piece = self.create_mock_piece("UnknownPiece", Color.WHITE)
        self.board.get_piece_at.return_value = piece
        self.assertEqual(self.ai_player.evaluate_position(self.game), 0)

    def test_evaluate_position_all_pieces(self):
        """Test evaluation with all piece types."""
        pieces = [
            ((0, 0), self.create_mock_piece("Queen", Color.WHITE)),   # +9
            ((1, 0), self.create_mock_piece("King", Color.BLACK)),    # -100
            ((2, 0), self.create_mock_piece("Rook", Color.WHITE)),    # +5
        ]
        self.setup_board_with_pieces(pieces)
        self.assertEqual(self.ai_player.evaluate_position(self.game), -86)

    # Alpha-Beta Pruning Tests
    def test_alpha_beta_pruning(self):
        """Test alpha-beta pruning efficiency."""
        eval_count, count_evals = self.setup_evaluation_counter()
        moves = self.create_mock_moves(4)

        # Test with and without pruning
        with patch.object(self.ai_player, 'get_available_moves', return_value=moves):
            with patch.object(self.ai_player, 'evaluate_position', side_effect=count_evals):
                self.ai_player.minimax(2, self.game, float('-inf'), 50, True)
        
        self.assertLess(eval_count, len(moves) * 2)

    # Move Execution Tests
    def test_move_execution_order(self):
        """Test that moves are executed and undone in correct order."""
        execution_order, mock_move = self.setup_move_tracking()
        
        with patch.object(self.ai_player, 'get_available_moves', return_value=[mock_move]):
            with patch.object(self.ai_player, 'evaluate_position', return_value=0):
                self.ai_player.minimax_root(1, self.game, True)

        for i in range(0, len(execution_order), 2):
            self.assertEqual(execution_order[i:i+2], ['execute', 'undo'])

if __name__ == '__main__':
    unittest.main()