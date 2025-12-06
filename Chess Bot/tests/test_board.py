import unittest
from unittest.mock import patch, MagicMock
from src.game.board import Board
from src.game.position import Position
from src.enums.color import Color
from src.pieces.piece import Piece
from src.pieces.bishop import Bishop
from src.pieces.rook import Rook
from src.pieces.pawn import Pawn
from src.pieces.king import King
from src.pieces.knight import Knight
from src.pieces.queen import Queen


class test_board(unittest.TestCase):
                
 
    def test_board_initializer(self):
        board = Board()
        board.initialize_board()
        for x in range(8):
            for y in range(2):
                self.assertEqual(board.get_piece_at(Position(x,y)).color, Color.WHITE)
        
        for x in range(8):
            for y in range(6,8):
                self.assertEqual(board.get_piece_at(Position(x,y)).color, Color.BLACK)
    
    
    def test_board_initilzer_piece_types(self):
        board = Board()
        board.initialize_board()
        for y in [1,6]:
            for x in range(8):
                self.assertIsInstance(board.get_piece_at(Position(x,y)), Pawn)
        for y in [0,7]:
            for x in [0, 7]:        
                self.assertIsInstance(board.get_piece_at(Position(x,y)), Rook)
        for y in [0,7]:
            for x in [1,6]:        
                self.assertIsInstance(board.get_piece_at(Position(x,y)), Knight)
        for y in [0,7]:
            for x in [2, 5]:        
                self.assertIsInstance(board.get_piece_at(Position(x,y)), Bishop)
        x = 3
        for y in [0,7]:        
            self.assertIsInstance(board.get_piece_at(Position(x,y)), Queen)
        
        x = 4
        for y in [0,7]:
            self.assertIsInstance(board.get_piece_at(Position(x,y)), King)
        
        
    def test_find_kings_position(self):
        board = Board()
        board.initialize_board()
        
        white_kings_position = board.find_kings_position(Color.WHITE)
        self.assertEqual(white_kings_position.y, 0)
        self.assertEqual(white_kings_position.x, 4)   
         
        black_kings_position = board.find_kings_position(Color.BLACK)
        self.assertEqual(black_kings_position.y, 7)
        self.assertEqual(black_kings_position.x, 4)
        
    def test_get_pieces(self):
        board = Board()
        board.initialize_board()
        
        white_pieces_list = board.get_pieces(Color.WHITE)
        self.assertEqual(len(white_pieces_list),16)
        for piece in white_pieces_list:
            self.assertEqual(piece.color, Color.WHITE)
            
        black_pieces_list = board.get_pieces(Color.BLACK)
        self.assertEqual(len(black_pieces_list), 16)
        for piece in black_pieces_list:
            self.assertEqual(piece.color, Color.BLACK)
    
    @patch('src.pieces.knight.Knight', return_value=MagicMock(spec=Knight))
    def test_get_piece_at(self, MockKnight):
        position = Position(5,5)
        board = Board()
        board.squares[5][5].piece = MockKnight        
        piece = board.get_piece_at(position)
        self.assertEqual(piece, MockKnight)
    

    def test_get_no_piece(self):
        board = Board()
        piece = board.get_piece_at(Position(5,5))
        self.assertEqual(None, piece)
        
    
        
        



