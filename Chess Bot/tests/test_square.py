import unittest
from unittest.mock import patch, MagicMock
from src.game.position import Position
from src.enums.color import Color
from src.game.square import Square
from src.pieces.pawn import Pawn

class TestSquare(unittest.TestCase):
    
    @patch('src.pieces.piece.Piece')
    def test_is_occupied(self, PieceMock):
        piece_mock = PieceMock()
        position = Position(0,0)
        piece_mock.position = position
        square = Square(position,Color.WHITE,piece_mock)
        self.assertTrue(square.is_occupied())
        pass

    def test_is_unoccupied(self):
        square = Square(Position(0,0),Color.WHITE,None)
        self.assertFalse(square.is_occupied())
        pass
    
    @patch('src.pieces.piece.Piece')
    def test_set_piece(self, MockPiece):
        position = Position(0,0)
        square = Square(position, Color.WHITE, None)
        mock_piece = MockPiece()
        square.set_piece(mock_piece)
        self.assertEqual(square.piece, mock_piece)
        pass
    
    @patch('src.pieces.piece.Piece')
    def test_set_piece_on_piece(self, MockPiece):
        position = Position(0,0)
        piece_mock1 = MockPiece()
        piece_mock2 = MockPiece()
        piece_mock1.color = Color.WHITE
        piece_mock2.color = Color.BLACK
        square = Square(position, Color.WHITE, piece_mock1)
        square.set_piece(piece_mock2)
        self.assertEqual(square.piece, piece_mock2)
        pass
    
    @patch('src.pieces.piece.Piece')
    def test_remove_piece(self, MockPiece):
        piece_mock = MockPiece()
        square = Square(Position(0,0), Color.WHITE, piece_mock)
        square.remove_piece()
        self.assertEqual(square.piece, None)
        pass
    
    def test_remove_no_piece(self):
        square = Square(Position(0,0), Color.WHITE, None)
        square.remove_piece()
        self.assertEqual(square.piece, None)
        pass
    
    def test_is_promotable(self):
        pawn_mock = MagicMock(spec=Pawn)
        pawn_mock.color = Color.WHITE
        square = Square(Position(0,7), Color.WHITE,pawn_mock)
        promoted = square.is_promotable(pawn_mock)
        self.assertTrue(promoted)
        
    @patch('src.pieces.bishop.Bishop')
    def test_not_pawn_is_promotable(self, BishopMock):
        bishop_mock = BishopMock()
        bishop_mock.color = Color.WHITE
        square = Square(Position(0,7), Color.WHITE, bishop_mock)
        promoted = square.is_promotable(bishop_mock)
        self.assertFalse(promoted)
        
    @patch('src.pieces.piece.Piece')
    def test_wrong_color_is_promotable(self, PieceMock):
        piece_mock = PieceMock()
        piece_mock.color = Color.BLACK
        square = Square(Position(0,7), Color.WHITE, piece_mock)
        promoted = square.is_promotable(piece_mock)
        self.assertFalse(promoted)
    