import unittest
from unittest.mock import MagicMock, patch
from src.enums.game_status import GameStatus
from src.game.game import Game
from src.game.board import Board, Square
from src.game.position import Position
from src.enums.color import Color
from src.game.move import Move
from src.pieces.king import King
from src.players.player import Player
from src.pieces.piece import Piece
from src.players.human_player import HumanPlayer
from io import StringIO


class test_game(unittest.TestCase):
    
    @patch('src.game.board.Board', return_value=MagicMock(spec=Board))
    @patch('src.players.human_player.HumanPlayer', return_value=MagicMock(spec=HumanPlayer))
    def test_start_game(self, MockPlayer, MockBoard): 
        game = Game()
        player1 = MockPlayer
        player2 = MockPlayer
        game.start_game(player1, player2)
        self.assertEqual(game.game_status, GameStatus.ONGOING)
        self.assertEqual(game.current_player, player1)

    
    @patch('sys.stdout', new_callable=StringIO)
    def test_end_game(self, Mockstdout):
        game = Game()
        game.end_game()
        output = Mockstdout.getvalue().strip()
        self.assertEqual(output, "Draw")
        
    @patch('sys.stdout', new_callable=StringIO)
    def test_checkmate_end_game(self, Mockstdout):
        game = Game()
        game.game_status = GameStatus.CHECKMATE
        game.end_game()
        output = Mockstdout.getvalue().strip()
        self.assertEqual(output, "Checkmate")

    @patch('src.players.player.Player')
    def test_switch_turn(self, MockPlayer):
        player1 = MockPlayer()
        player2 = MockPlayer()
        game = Game()
        game.players = [player1, player2]
        game.current_player = player1

        game.switch_turn()
        self.assertEqual(game.current_player, player2)

        game.switch_turn()
        self.assertEqual(game.current_player, player1)

    @patch('src.game.game.Game.get_valid_moves')
    @patch('src.game.board.Board.find_kings_position')
    @patch('src.players.player.Player')
    def test_is_check(self, mock_player, mock_find_king, mock_get_moves):
        player1 = mock_player
        player1.color = Color.WHITE
        enemy_king_position = Position(4,4)
        
        mock_get_moves.return_value = [Position(4,4), Position(5,5)]
        
        mock_find_king.return_value = enemy_king_position
        game = Game()
        game.current_player = player1
        result = game.is_check()
        
        self.assertTrue(result)
        
    @patch('src.game.game.Game.get_valid_moves')
    @patch('src.game.board.Board.find_kings_position')
    @patch('src.players.player.Player')
    def test_is_not_check(self, mock_player, mock_find_king, mock_get_moves):
        player1 = mock_player
        player1.color = Color.WHITE
        enemy_king_position = Position(4,4)
        
        mock_get_moves.return_value = [Position(5,5), Position(6,6)]
        
        mock_find_king.return_value = enemy_king_position
        
        game = Game()
        game.current_player = player1
        result = game.is_check()
        self.assertFalse(result)
        
    @patch('src.game.game.Game.get_valid_moves')
    @patch('src.game.board.Board.find_kings_position')
    @patch('src.players.player.Player')
    @patch('src.game.board.Board.get_piece_at')
    def test_is_checkmate(self, mock_get_piece_at, mock_player, mock_find_king, mock_get_moves):
        player1 = mock_player
        player1.color = Color.WHITE
        enemy_king_position = Position(0,7)
        
        mock_enemy_king = MagicMock(spec=King)
        mock_enemy_king.get_valid_moves.return_value = [Position(1,7), Position(0,6), Position(1,6)]
        mock_get_piece_at.return_value = mock_enemy_king
        
        
        mock_get_moves.return_value = [Position(0,7), Position(1,7), Position(0,6), Position(1,6)]
        
        mock_find_king.return_value = enemy_king_position
        
        game = Game()
        game.current_player = player1
        result = game.is_checkmate()
        self.assertTrue(result)

    @patch('src.game.game.Game.get_valid_moves')
    @patch('src.game.board.Board.find_kings_position')
    @patch('src.players.player.Player')
    @patch('src.game.board.Board.get_piece_at')
    def test_not_checkmate(self, mock_get_piece_at, mock_player, mock_find_king, mock_get_moves):
        player1 = mock_player
        player1.color = Color.WHITE
        enemy_king_position = Position(0,7)
        
        mock_enemy_king = MagicMock(spec=King)
        mock_enemy_king.get_valid_moves.return_value = [Position(1,7), Position(0,6), Position(1,6)]
        mock_get_piece_at.return_value = mock_enemy_king
        
        
        mock_get_moves.return_value = [Position(0,7), Position(2,7), Position(0,6), Position(1,6)]
        
        mock_find_king.return_value = enemy_king_position
        
        game = Game()
        game.current_player = player1
        result = game.is_checkmate()
        self.assertFalse(result)

    @patch('src.game.game.Game.is_check')
    @patch('src.players.player.Player.get_available_moves')
    def test_is_stalemate(self, mock_get_available_moves, mock_is_check):
        game = Game()
        mock_get_available_moves.return_value = []
        player1 = MagicMock(spec=Player)
        player1.color = Color.WHITE
        mock_is_check.return_value = False
        game.current_player = player1
        
        result = game.is_stalemate()
        self.assertTrue(result)
        self.assertTrue(game.game_status, GameStatus.STALEMATE)
        
    @patch('src.game.board.Board')
    def test_get_valid_moves_no_pieces(self, mock_board):
        game = Game()
        mock_board.get_pieces.return_value = []
        player1 = MagicMock(spec=Player)
        player1.color = Color.WHITE
        game.current_player = player1
        
        result = game.get_valid_moves()
        self.assertEqual(result, [])
        
   
    @patch('src.game.board.Board')
    def test_get_valid_moves_with_valid_moves(self, mock_board):
        game = Game()
        player1 = MagicMock(spec=Player)
        player1.color = Color.WHITE
        
        piece1 = MagicMock(spec=Piece)
        piece2 = MagicMock(spec=Piece)
        
        
        piece1.get_valid_moves.return_value = [Position(0,0)]
        piece2.get_valid_moves.return_value = [Position(2,2)]
        
        mock_board.get_pieces.return_value = [piece1, piece2]
        game.board = mock_board
        game.current_player = player1
        result = game.get_valid_moves()
        self.assertEqual(result, [Position(0,0), Position(2,2)])
        
        
        
    