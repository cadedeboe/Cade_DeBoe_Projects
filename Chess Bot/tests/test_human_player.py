import unittest
from unittest.mock import Mock, patch
from src.players.human_player import HumanPlayer
from src.enums.color import Color
from src.game.position import Position
from src.game.move import Move
from src.pieces.pawn import Pawn
from src.game.game import Game
from src.game.board import Board

class TestHumanPlayer(unittest.TestCase):
    def setUp(self):
        self.player = HumanPlayer("Test Player", Color.WHITE)
        self.game = Game()
        self.board = Board()
        self.game.board = self.board
        
        # Create some sample moves for testing
        self.pawn = Pawn(Position(1, 1), Color.WHITE)
        self.move1 = Move(Position(1, 1), Position(1, 2), self.pawn)
        self.move2 = Move(Position(1, 1), Position(1, 3), self.pawn)
        self.valid_moves = [self.move1, self.move2]

    def test_player_initialization(self):
        """Test if player is initialized with correct name and color"""
        self.assertEqual(self.player.name, "Test Player")
        self.assertEqual(self.player.color, Color.WHITE)

    @patch('builtins.input', side_effect=['1'])
    def test_select_move_valid_input(self, mock_input):
        """Test selecting a valid move from the list"""
        selected_move = self.player.select_move(self.valid_moves, self.board)
        self.assertEqual(selected_move, self.move1)

    @patch('builtins.input', side_effect=['3', '1'])
    def test_select_move_invalid_then_valid_input(self, mock_input):
        """Test handling invalid input before receiving valid input"""
        selected_move = self.player.select_move(self.valid_moves, self.board)
        self.assertEqual(selected_move, self.move1)

    @patch('builtins.input', side_effect=['invalid', '1'])
    def test_select_move_non_numeric_input(self, mock_input):
        """Test handling non-numeric input"""
        selected_move = self.player.select_move(self.valid_moves, self.board)
        self.assertEqual(selected_move, self.move1)

    @patch('builtins.input', side_effect=['1'])
    def test_make_move_execution(self, mock_input):
        """Test if make_move properly executes the selected move"""

        self.player.get_available_moves = Mock(return_value=self.valid_moves)
        
        # Execute make_move
        result_move = self.player.make_move(self.game)
        
        # Verify the correct move was selected and returned
        self.assertEqual(result_move, self.move1)

    def test_make_move_no_valid_moves(self):
        """Test handling when there are no valid moves available"""
        # Mock get_available_moves to return empty list
        self.player.get_available_moves = Mock(return_value=[])
        
        result_move = self.player.make_move(self.game)
        
        self.assertIsNone(result_move)

if __name__ == '__main__':
    unittest.main()