from enum import Enum

class GameStatus(Enum):
    ONGOING = 1
    CHECKMATE = 2
    STALEMATE = 3
    DRAW = 4