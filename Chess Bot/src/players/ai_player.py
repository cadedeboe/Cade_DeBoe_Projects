from src.game.position import Position
from src.players.player import Player
from src.enums.color import Color
from src.game.move import Move
from src.game.game import Game
from src.enums.game_status import GameStatus
from typing import Optional, List
import random

class AIPlayer(Player):

    PIECE_VALUES = {
        'Pawn': 1,
        'Knight': 3,
        'Bishop': 3,
        'Rook': 5,
        'Queen': 9,
        'King': 100
    }

    @staticmethod
    def _convert_to_chess_notation(position) -> str:
        """Converts x,y coordinates to chess notation (e.g., 0,0 -> A1)"""
        col = chr(position.x + ord('A'))  # Convert 0-7 to A-H
        row = str(position.y + 1)  # Convert 0-7 to 1-8
        return f"{col}{row}"

    def make_move(self, game: Game) -> Optional[Move]:
        """Selects and announces the best move for the current game state."""
        if game.board is None:
            raise ValueError("Invalid board state")
            
        if game.game_status != GameStatus.ONGOING:
            return None

        selected_move = self.minimax_root(3, game, True)
        
        if selected_move:
            # Format the move announcement using chess notation
            piece_type = selected_move.piece_moved.__class__.__name__
            from_pos = self._convert_to_chess_notation(selected_move.from_position)
            to_pos = self._convert_to_chess_notation(selected_move.to_position)
            capture_info = f" capturing {selected_move.piece_captured.__class__.__name__}" if selected_move.piece_captured else ""
            
            print(f"AI chooses to move {piece_type} from {from_pos} to {to_pos}{capture_info}")
            
        return selected_move
    
    def move_check(self, game: Game):
            
        if game.self_check():
            valid_moves = game.in_check_valid_moves()
        else:
            valid_moves = self.get_available_moves(game.board)
        random.shuffle(valid_moves)
        return valid_moves

    def minimax_root(self, depth: int, game: Game, is_maximizing_player: bool) -> Optional[Move]:
        """Find the best move by evaluating all possible moves at the root level."""
        if depth < 0:
            raise ValueError("Depth cannot be negative")
            
        available_moves = self.move_check(game)
        if not available_moves:
            return None

        best_move = None
        best_value = float('-inf')
        alpha = float('-inf')
        beta = float('inf')

        for move in available_moves:
            # Make move
            move.execute(game.board)
            # Evaluate position
            value = self.minimax(depth - 1, game, alpha, beta, False)
            # Undo move
            move.undo(game.board)

            if value > best_value:
                best_value = value
                best_move = move

            alpha = max(alpha, value)
            if beta <= alpha:
                break

        return best_move

    def minimax(self, depth: int, game: Game, alpha: float, beta: float, is_maximizing_player: bool) -> float:
        """Implementation of minimax algorithm with alpha-beta pruning."""
        if depth == 0 or game.game_status != GameStatus.ONGOING:
            return self.evaluate_position(game, is_maximizing_player)

        if is_maximizing_player:
            max_eval = float('-inf')
            moves = self.move_check(game)
            
            for move in moves:
                move.execute(game.board)
                eval = self.minimax(depth - 1, game, alpha, beta, False)
                move.undo(game.board)
                
                max_eval = max(max_eval, eval)
                alpha = max(alpha, eval)
                if beta <= alpha:
                    break
            return max_eval
        else:
            min_eval = float('inf')
            moves = self.move_check(game) 
            
            for move in moves:
                move.execute(game.board)
                eval = self.minimax(depth - 1, game, alpha, beta, True)
                move.undo(game.board)
                
                min_eval = min(min_eval, eval)
                beta = min(beta, eval)
                if beta <= alpha:
                    break
            return min_eval
        
    

    def evaluate_position(self, game: Game, player) -> int:
        """
        Position evaluation based on material count.
        Uses standard chess piece values.
        """
        
        if self.color == Color.WHITE:
            opponent_color = Color.BLACK
        else:
            opponent_color = Color.WHITE

        score = 0
        for row in range(8):
            for col in range(8):
                piece = game.board.get_piece_at(Position(row, col))
                if piece:
                    value = self.PIECE_VALUES.get(piece.__class__.__name__, 0)
                    if piece.color == self.color:
                        score -= value
                    else:
                        score += value
        if game.is_check(self.color):
            score += 7
        elif game.is_check(opponent_color):
            score -= 7
        if player:
            if game.is_checkmate():
                score -= 99999
        else:
            if game.is_checkmate():
                score += 99999
        # Bonus/malus for checkmate or check

        return score