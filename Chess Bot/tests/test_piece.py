import unittest
from abc import ABC
from typing import List
from unittest.mock import Mock, patch
from src.game.position import Position
from src.enums.color import Color
from src.pieces.pawn import Pawn
from src.pieces.piece import Piece

class TestPiece(unittest.TestCase):

    def test_piece_initialization(self):

        class ConcretePiece(Piece):
            def get_valid_moves(self, board):
                return[]

        position = Position(4, 4)
        piece = ConcretePiece(position, Color.WHITE)

        self.assertEqual(piece.position, position)
        self.assertEqual(piece.color, Color.WHITE)
        self.assertFalse(piece.has_moved)

    def test_abstract_method_enforcement(self):
        """Test that Piece cannot be instantiated directly."""
        with self.assertRaises(TypeError):
            Piece(Position(4, 4), Color.WHITE)


    def test_move_to_updates_position(self):
        class ConcretePiece(Piece):
            def get_valid_moves(self, board):
                return []

        piece = ConcretePiece(Position(4, 4), Color.WHITE)
        new_position = Position(5, 5)

        piece.move_to(new_position)

        self.assertEqual(piece.position, new_position)
        self.assertTrue(piece.has_moved)

if __name__ == "__main__":
    unittest.main()
