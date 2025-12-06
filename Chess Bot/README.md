# Chess Bot

A Python-based chess game implementation featuring an AI opponent powered by the minimax algorithm with alpha-beta pruning. Play against the AI or another human player in a fully functional chess game.

## Features

- **Complete Chess Implementation**: All standard chess pieces (Pawn, Rook, Knight, Bishop, Queen, King) with proper movement rules
- **AI Opponent**: Intelligent AI player using minimax algorithm with alpha-beta pruning for optimal move selection
- **Human vs AI / Human vs Human**: Flexible player setup supporting both human and AI players
- **Game Rules**: Full implementation of chess rules including:
  - Check detection
  - Checkmate detection
  - Stalemate detection
  - Move validation
  - Piece capture mechanics
- **Chess Notation**: Uses standard algebraic notation (e.g., A1, E4, H8) for move representation
- **Interactive Gameplay**: User-friendly interface with move selection and board visualization
- **Comprehensive Testing**: Full test suite covering all game components

## Project Structure

```
Chess Bot/
├── src/
│   ├── enums/
│   │   ├── color.py          # Color enum (WHITE/BLACK)
│   │   └── game_status.py    # Game status enum (ONGOING/CHECKMATE/STALEMATE/DRAW)
│   ├── game/
│   │   ├── board.py          # Chess board implementation
│   │   ├── game.py           # Main game logic and state management
│   │   ├── move.py           # Move representation and execution
│   │   ├── position.py       # Position/coordinate system
│   │   └── square.py         # Square representation
│   ├── pieces/
│   │   ├── piece.py          # Abstract base class for all pieces
│   │   ├── pawn.py           # Pawn implementation
│   │   ├── rook.py           # Rook implementation
│   │   ├── knight.py         # Knight implementation
│   │   ├── bishop.py         # Bishop implementation
│   │   ├── queen.py          # Queen implementation
│   │   └── king.py           # King implementation
│   └── players/
│       ├── player.py         # Abstract base class for players
│       ├── human_player.py   # Human player implementation
│       └── ai_player.py      # AI player with minimax algorithm
└── tests/
    └── [test files for all components]
```

## Requirements

- Python 3.7+

## Installation

1. Clone or download this repository
2. Navigate to the project directory:
   ```bash
   cd "Chess Bot"
   ```

## Usage

### Basic Game Setup

To start a game, create a Python script that initializes the game and players:

```python
from src.game.game import Game
from src.players.human_player import HumanPlayer
from src.players.ai_player import AIPlayer
from src.enums.color import Color

# Create a new game
game = Game()

# Create players
player1 = HumanPlayer("Player 1", Color.WHITE)
player2 = AIPlayer("AI_Player", Color.BLACK)

# Start the game
game.start_game(player1, player2)

# Game loop
while game.game_status == GameStatus.ONGOING:
    game.play_turn()

# End game
game.end_game()
```

### Player Types

**Human Player:**
```python
from src.players.human_player import HumanPlayer
from src.enums.color import Color

player = HumanPlayer("Your Name", Color.WHITE)
```

**AI Player:**
```python
from src.players.ai_player import AIPlayer
from src.enums.color import Color

ai = AIPlayer("AI_Opponent", Color.BLACK)
```

### AI Configuration

The AI uses minimax with alpha-beta pruning. You can adjust the search depth in `ai_player.py`:

```python
# In AIPlayer.make_move(), change the depth parameter:
selected_move = self.minimax_root(3, game, True)  # Depth of 3
```

Higher depth values result in stronger play but slower move calculation.

## How It Works

### AI Algorithm

The AI player uses the **minimax algorithm** with **alpha-beta pruning**:

1. **Minimax**: Explores possible moves up to a certain depth, alternating between maximizing (AI's turn) and minimizing (opponent's turn) the evaluation score
2. **Alpha-Beta Pruning**: Optimizes the search by cutting off branches that won't affect the final decision
3. **Position Evaluation**: Scores positions based on:
   - Material count (piece values)
   - Check/checkmate detection
   - Piece positioning

### Piece Values

The AI uses standard chess piece values:
- Pawn: 1
- Knight: 3
- Bishop: 3
- Rook: 5
- Queen: 9
- King: 100

## Testing

Run the test suite to verify all components:

```bash
python -m pytest tests/
```

Or run individual test files:
```bash
python -m pytest tests/test_game.py
python -m pytest tests/test_ai_player.py
```

## Game Rules Implementation

- ✅ Standard piece movements
- ✅ Check detection
- ✅ Checkmate detection
- ✅ Stalemate detection
- ✅ Move validation (prevents illegal moves)
- ✅ Piece capture mechanics
- ✅ Turn-based gameplay

## Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## License

This project is open source and available for educational purposes.

