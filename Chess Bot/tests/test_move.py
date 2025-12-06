import unittest
from unittest.mock import MagicMock, patch
from src.game.board import Move
from src.game.board import Board
from src.game.position import Position
from src.pieces.bishop import Bishop
from src.pieces.knight import Knight
from src.game.square import Square
from src.enums.color import Color


#These tests are all done with assumption that the given move is valid
class test_move(unittest.TestCase):
    """The move class works under the assumptions that only valid moves are created.
    There will never be a need to test if an invalid move is trying to execute."""
    
    def setUp(self):
        self.from_position = Position(0,0)
        self.to_position = Position(1,1)
        self.piece_moved = MagicMock(spec=Bishop)
        self.piece_captured = MagicMock(spec=Knight)
        self.move = Move(self.from_position, self.to_position, self.piece_moved, self.piece_captured)
        
    def test_move_initialization(self):
        self.assertEqual(self.move.from_position, self.from_position)
        self.assertEqual(self.move.to_position, self.to_position)
        self.assertEqual(self.move.piece_moved, self.piece_moved)
        self.assertEqual(self.move.piece_captured, self.piece_captured)
        self.assertFalse(self.move.executed)
    
    @patch('src.game.board.Board')
    @patch('src.game.square.Square')
    def test_execute_undo_move(self,MockSquare, MockBoard):
        
                
        mock_board = MockBoard()
        mock_board.squares = [[Square(Position(x, y), Color.WHITE if (x + y) % 2 == 0 else Color.BLACK)
                         for y in range(8)] for x in range(8)]
        
        mock_from_square = MockSquare(self.from_position, Color.WHITE, self.piece_moved)
        mock_to_square = MagicMock(spec=Square)
        mock_to_square.piece = self.piece_captured
        
        def remove_from_piece_side_effect():
            mock_from_square.piece = None
        
        mock_from_square.remove_piece.side_effect = remove_from_piece_side_effect

        
        def set_piece_side_effect(mock_self):
            mock_to_square.piece = self.piece_moved
        
        mock_to_square.set_piece.side_effect = set_piece_side_effect
        
        mock_board.squares[self.from_position.x][self.from_position.y] = mock_from_square
        mock_board.squares[self.to_position.x][self.to_position.y] = mock_to_square
        
        self.move.execute(mock_board)
        self.assertTrue(self.move.executed)
        self.assertIsInstance(mock_board.squares[self.to_position.x][self.to_position.y].piece, Bishop)
        self.assertEqual(mock_board.squares[self.from_position.x][self.from_position.y].piece, None)
        
        def set_to_piece_side_effect2(mock_self):
            mock_to_square.piece = self.piece_captured
        
        mock_to_square.set_piece.side_effect = set_to_piece_side_effect2
        
        def set_from_piece_side_effect2(mock_self):
            mock_from_square.piece = self.piece_moved
        
        mock_from_square.set_piece.side_effect = set_from_piece_side_effect2
        
        self.move.undo(mock_board)
        self.assertFalse(self.move.executed)
        self.assertIsInstance(mock_board.squares[self.to_position.x][self.to_position.y].piece, Knight)
        self.assertIsInstance(mock_board.squares[self.from_position.x][self.from_position.y].piece, Bishop)
        
    @patch('src.game.board.Board')
    def test_undo_no_execute(self, MockBaord):
        mock_board = MockBaord()
        self.assertFalse(self.move.executed)
        self.move.undo(mock_board)
        self.assertFalse(self.move.executed)
        
        
    @patch('src.game.board.Board')
    @patch('src.game.square.Square')
    def test_execute_after_execute(self,MockSquare, MockBoard):
        
                
        mock_board = MockBoard()
        mock_board.squares = [[Square(Position(x, y), Color.WHITE if (x + y) % 2 == 0 else Color.BLACK)
                         for y in range(8)] for x in range(8)]
        
        mock_from_square = MockSquare(self.from_position, Color.WHITE, self.piece_moved)
        mock_to_square = MagicMock(spec=Square)
        mock_to_square.piece = self.piece_captured
        
        def remove_from_piece_side_effect():
            mock_from_square.piece = None
        
        mock_from_square.remove_piece.side_effect = remove_from_piece_side_effect

        
        def set_piece_side_effect(mock_self):
            mock_to_square.piece = self.piece_moved
        
        mock_to_square.set_piece.side_effect = set_piece_side_effect
        
        mock_board.squares[self.from_position.x][self.from_position.y] = mock_from_square
        mock_board.squares[self.to_position.x][self.to_position.y] = mock_to_square
        
        self.move.execute(mock_board)
        self.assertTrue(self.move.executed)
        self.assertIsInstance(mock_board.squares[self.to_position.x][self.to_position.y].piece, Bishop)
        self.assertEqual(mock_board.squares[self.from_position.x][self.from_position.y].piece, None)
        #execute again
        self.move.execute(mock_board)
        self.assertTrue(self.move.executed)
        self.assertIsInstance(mock_board.squares[self.to_position.x][self.to_position.y].piece, Bishop)
        self.assertEqual(mock_board.squares[self.from_position.x][self.from_position.y].piece, None)
        

        
        
    
    
    
    
    
    