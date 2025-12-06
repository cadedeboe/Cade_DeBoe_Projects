from src.game.board import Board
from src.game.move import Move
from src.game.position import Position
from src.players.player import Player
from typing import List
from src.enums.color import Color
from src.enums.game_status import GameStatus

class Game:
    def __init__(self):
        self.board = Board()
        self.players: List[Player] = []
        self.current_player: Player = None
        self.game_status = GameStatus.ONGOING

    def start_game(self, player1, player2):
        """Initializes and begins the game. And sets the players"""
        self.board.initialize_board()
        self.setup_players(player1, player2)
        self.current_player = self.players[0]
        
    
    def play_turn(self):
        """executes the current turn"""
        player_move = self.current_player.make_move(self)  
        
        if player_move is None:
            if self.is_checkmate():
                self.game_status = GameStatus.CHECKMATE
            elif self.is_stalemate():
                self.game_status = GameStatus.STALEMATE
            return
            
        player_move.execute(self.board)
        

        player_move.piece_moved.move_to(player_move.to_position)
        

        if player_move.piece_captured:
            print(f"{player_move.piece_moved.__class__.__name__} captures {player_move.piece_captured.__class__.__name__}")
            

        self.switch_turn()
        
    def setup_players(self, player1, player2):
        """Adds players to players list, this player2 can be algorithm or human."""
        self.players.append(player1)
        self.players.append(player2)
        

    def end_game(self):
        """Ends the game."""
        match self.game_status:
            case GameStatus.CHECKMATE:
                print("Checkmate")
            case GameStatus.STALEMATE:
                print("Stalemate")
            case GameStatus.DRAW:
                print("Draw")
            case GameStatus.ONGOING:
                print("Draw")
        

    def switch_turn(self):
        """Switches the current player."""
        if self.players[0] == self.current_player:
            self.current_player = self.players[1]
        else:
            self.current_player = self.players[0]          
        

    def is_check(self, color = None) -> bool:
        """Determines if a player is in check."""
        if color == None:
            color = self.current_player.color
        to_positions = self.get_valid_moves()
        if color == Color.WHITE:
            enemy_king_position = self.board.find_kings_position(Color.BLACK)
        else:
            enemy_king_position = self.board.find_kings_position(Color.WHITE)
        if enemy_king_position == None:
            self.game_status = GameStatus.CHECKMATE
            self.end_game()
            return True
        for position in to_positions:
            if position.x == enemy_king_position.x and position.y == enemy_king_position.y:
                return True
        return False
    def get_valid_moves_for_color(self, color: Color) -> List[Position]:
        """Returns a list of all positions attacked by the given color's pieces."""
        pieces = self.board.get_pieces(color)
        positions = []
        for piece in pieces:
            positions.extend(piece.get_valid_moves(self.board))
        return positions
    
    def self_check(self):
        current_index = self.players.index(self.current_player)
        non_current_index = (current_index + 1) % 2
        opponent = self.players[non_current_index]
        to_positions = self.get_valid_moves(opponent)
        if self.current_player == Color.WHITE:
            king_position = self.board.find_kings_position(Color.WHITE)
        else:
            king_position = self.board.find_kings_position(Color.BLACK)
        if king_position == None:
            return True
        for position in to_positions:
            if position.x == king_position.x and position.y == king_position.y:
                return True
        return False

    def is_checkmate(self) -> bool:
        """Determines if the current player is in checkmate."""
        if self.board.find_kings_position(self.current_player.color) == None:
            self.game_status = GameStatus.CHECKMATE
            return True
        if not self.is_check():
            return False

        # Try all possible moves for the current player
        color_to_check = None
        if self.current_player.color == Color.WHITE:
            color_to_check = Color.BLACK
        else:
            color_to_check = Color.WHITE
        pieces = self.board.get_pieces(color_to_check)
        for piece in pieces:
            from_position = piece.position
            valid_moves = piece.get_valid_moves(self.board)

            for to_position in valid_moves:
                captured_piece = self.board.get_piece_at(to_position)
                move = Move(from_position, to_position, piece, captured_piece)
                move.execute(self.board)

                # Check if this move gets out of check
                is_still_in_check = self.is_check()

                move.undo(self.board)

                if not is_still_in_check:
                    return False
        else:
            self.game_status = GameStatus.CHECKMATE
            return True
        
                        
    def in_check_valid_moves(self) -> List[Move]:
        move_list = []
        pieces = self.board.get_pieces(self.current_player.color)
        for piece in pieces:
            from_position = piece.position
            valid_moves = piece.get_valid_moves(self.board)

            for to_position in valid_moves:
                captured_piece = self.board.get_piece_at(to_position)
                move = Move(from_position, to_position, piece, captured_piece)
                move.execute(self.board)

                # Check if this move gets out of check
                is_still_in_check = self.self_check()

                move.undo(self.board)

                if not is_still_in_check:
                    move_list.append(move)
        return move_list
                    

            
            

    def is_stalemate(self) -> bool:
        """Determines if the game is a stalemate."""
        if len(self.current_player.get_available_moves(self.board)) == 0:
            if not self.is_check():
                self.game_status = GameStatus.STALEMATE
                return True
        else:
            return False

    def get_valid_moves(self, player=None) -> List[Position]:
        """Retrieves all valid moves for the current player."""
        if player == None:
            player = self.current_player
        current_player_moves = []
        
        current_player_pieces = self.board.get_pieces(player.color)
        for current_player_piece in current_player_pieces:
            for position in current_player_piece.get_valid_moves(self.board):
                current_player_moves.append(position)
            
        return current_player_moves
        

