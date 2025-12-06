from src.pieces.piece import Piece
from src.pieces.pawn import Pawn
from src.pieces.rook import Rook
from src.pieces.knight import Knight
from src.pieces.bishop import Bishop
from src.pieces.queen import Queen
from src.pieces.king import King
from src.game.square import Square
from src.game.position import Position
from src.enums.color import Color
from typing import Optional
from src.game.move import Move
from typing import List, Dict, Tuple, Optional
from collections import defaultdict  

class Board:
    def __init__(self):
        self.squares = [[Square(Position(x, y), Color.WHITE if (x + y) % 2 == 0 else Color.BLACK)
                         for y in range(8)] for x in range(8)]

    def initialize_board(self):
        """Sets up pieces in the starting positions."""
        for x in range(8):
            self.squares[x][1].piece = Pawn(Position(x,1), Color.WHITE)
            self.squares[x][6].piece = Pawn(Position(x,6), Color.BLACK)
        
        for x in [0,7]:
            self.squares[x][0].piece = Rook(Position(x, 0), Color.WHITE)
            self.squares[x][7].piece = Rook(Position(x,7), Color.BLACK)
        
        for x in [1,6]:
            self.squares[x][0].piece = Knight(Position(x, 0), Color.WHITE)
            self.squares[x][7].piece = Knight(Position(x,7), Color.BLACK)
        
        for x in [2,5]:
            self.squares[x][0].piece = Bishop(Position(x, 0), Color.WHITE)
            self.squares[x][7].piece = Bishop(Position(x,7), Color.BLACK)
            
        
        self.squares[3][0].piece = Queen(Position(3, 0), Color.WHITE)
        self.squares[3][7].piece = Queen(Position(3,7), Color.BLACK)
        
        self.squares[4][0].piece = King(Position(4, 0), Color.WHITE)
        self.squares[4][7].piece = King(Position(4,7), Color.BLACK)
        pass

    def get_captured_pieces(self, color: Color) -> list:
        """Returns list of captured pieces of specified color"""
        all_pieces = {
            Color.WHITE: {'♙': 8, '♖': 2, '♘': 2, '♗': 2, '♕': 1, '♔': 1},
            Color.BLACK: {'♟': 8, '♜': 2, '♞': 2, '♝': 2, '♛': 1, '♚': 1}
        }
        
        # Count current pieces on board
        current_pieces = {'♙': 0, '♖': 0, '♘': 0, '♗': 0, '♕': 0, '♔': 0,
                        '♟': 0, '♜': 0, '♞': 0, '♝': 0, '♛': 0, '♚': 0}
        
        for y in range(8):
            for x in range(8):
                piece = self.squares[x][y].piece
                if piece:
                    symbol = self.get_piece_symbol(piece).strip()
                    current_pieces[symbol] += 1
        
        # Calculate captured pieces
        captured = []
        target_pieces = all_pieces[color]
        for symbol, total in target_pieces.items():
            diff = total - current_pieces[symbol]
            captured.extend([symbol] * diff)
        
        return captured

    def display(self):
        """Prints the current state of the board."""
        # Get captured pieces
        captured_white = self.get_captured_pieces(Color.WHITE)
        captured_black = self.get_captured_pieces(Color.BLACK)
        
        print("\n    A  B  C  D  E  F  G  H        Captured Pieces")
        print("   -----------------------        White:", end=" ")
        print(" ".join(captured_white) if captured_white else "None")
        
        for y in range(7, -1, -1):
            print(f"{y+1} |", end=" ")
            for x in range(8):
                print(self.format_square(x, y), end="")
            if y == 4:  # Print black captured pieces in middle of board
                print(f"| {y+1}        Black:", end=" ")
                print(" ".join(captured_black) if captured_black else "None")
            else:
                print(f"| {y+1}")
        
        print("   -----------------------")
        print("    A  B  C  D  E  F  G  H\n")

    def format_square(self, x: int, y: int) -> str:
        """Returns a formatted string for a square with consistent width."""
        piece = self.squares[x][y].piece
        if piece is None:
            # Return empty square with background
            return "⬛ " if (x + y) % 2 == 0 else "⬜ "
        else:
            # Get piece symbol and ensure it has a space after
            symbol = self.get_piece_symbol(piece)
            # Ensure total width is same as empty squares
            return f" {symbol} "

    def get_piece_symbol(self, piece):
        """Returns the symbol for a given piece."""
        symbols = {
            'Pawn': '♟' if piece.color == Color.BLACK else '♙',
            'Rook': '♜' if piece.color == Color.BLACK else '♖',
            'Knight': '♞' if piece.color == Color.BLACK else '♘',
            'Bishop': '♝' if piece.color == Color.BLACK else '♗',
            'Queen': '♛' if piece.color == Color.BLACK else '♕',
            'King': '♚' if piece.color == Color.BLACK else '♔'
        }
        return symbols.get(piece.__class__.__name__, '?')

    def get_piece_at(self, position: Position) -> Optional['Piece']:
        """Returns the piece at a specific position."""
        return self.squares[position.x][position.y].piece
        
    
    def get_pieces(self, color: Color) -> list[Piece]:
        """ Gets all none taken pieces based on Color(Black|White)"""
        piece_list = []
        for y in range(8):
            for x in range(8):
                square_piece = self.squares[x][y].piece
                if square_piece:
                    if square_piece.color == color:
                        piece_list.append(square_piece)
                
        return piece_list
    
    def find_kings_position(self, color: Color) -> Position:
        """Gets the kings position based on Color"""
        for y in range(8):
            for x in range(8):
                if isinstance(self.squares[x][y].piece, King):
                    if self.squares[x][y].piece.color == color:
                        return Position(x,y) 
        return None
        

    @staticmethod
    def convert_to_chess_notation(position) -> str:
        """Converts x,y coordinates to chess notation (e.g., 0,0 -> A1)"""
        col = chr(position.x + ord('A'))
        row = str(position.y + 1)
        return f"{col}{row}"

    def determine_move_type(self, move: Move) -> str:
        """Determines the type of move based on the piece and movement."""
        piece_type = move.piece_moved.__class__.__name__
        
        if move.piece_captured:
            return "Captures"
        elif piece_type == "Pawn" and abs(move.to_position.y - move.from_position.y) == 2:
            return "Two Square Advances"
        elif piece_type == "King" and abs(move.to_position.x - move.from_position.x) == 2:
            return "Castle"
        return "Standard Moves"

    def categorize_moves(self, moves: List[Move]) -> Dict[str, Dict[str, List[Move]]]:
        """Categorizes moves by piece type and movement type."""
        categorized = defaultdict(lambda: defaultdict(list))
        
        for move in moves:
            piece_type = move.piece_moved.__class__.__name__
            move_type = self.determine_move_type(move)
            categorized[piece_type][move_type].append(move)
            
        return categorized

    def create_move_display(self, moves: List[Move]) -> Tuple[List[List[str]], Dict[int, Move]]:
        """Creates the visual board display and move lookup dictionary."""
        board_display = [[" " for _ in range(8)] for _ in range(8)]
        move_lookup = {}
        current_number = 1

        for move in moves:
            to_pos = move.to_position
            board_display[7 - to_pos.y][to_pos.x] = str(current_number)
            move_lookup[current_number] = move
            current_number += 1

        return board_display, move_lookup

    def display_board_state(self, board_display: List[List[str]] = None):
        """Prints the chess board with either pieces or numbered possible moves."""
        print("\n    A  B  C  D  E  F  G  H")
        print("   -----------------------")
        
        for y in range(8):
            print(f"{8-y} |", end=" ")
            for x in range(8):
                if board_display is None:
                    # Display actual pieces
                    print(self.format_square(x, y), end="")
                else:
                    # Display possible moves
                    if board_display[y][x] != " ":
                        print(f"{board_display[y][x]:2}", end=" ")
                    else:
                        print("· ", end=" ")
            print(f"| {8-y}")
            
        print("   -----------------------")
        print("    A  B  C  D  E  F  G  H\n")

    def format_move_description(self, move: Move, move_number: int) -> str:
        """Formats a move description with chess notation."""
        from_pos = self.convert_to_chess_notation(move.from_position)
        to_pos = self.convert_to_chess_notation(move.to_position)
        capture_info = f" capturing {move.piece_captured.__class__.__name__}" if move.piece_captured else ""
        return f"    {move_number}. {from_pos} → {to_pos}{capture_info}"

