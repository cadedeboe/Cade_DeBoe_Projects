# Cade_DeBoe_Projects

A collection of diverse computer science and engineering projects showcasing skills in machine learning, algorithms, computer architecture, and theoretical computer science.

## 📋 Table of Contents

- [Overview](#overview)
- [Projects](#projects)
  - [Face Recognition System](#1-face-recognition-system)
  - [Chess Bot with Minimax](#2-chess-bot-with-minimax-algorithm)
  - [RISC-V Processor](#3-risc-v-processor)
  - [Lexical Analyzer](#4-lexical-analyzer)
- [Technologies](#technologies)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)

## Overview

This repository contains four distinct projects demonstrating expertise across multiple domains:

- **Machine Learning**: Deep learning face recognition with multiple architectures
- **Algorithms**: Chess AI using minimax algorithm with alpha-beta pruning
- **Computer Architecture**: RISC-V processor implementation
- **Theoretical Computer Science**: Lexical analyzer using automata theory

Each project is self-contained with its own documentation and can be explored independently.

---

## Projects

### 1. Face Recognition System

A comprehensive deep learning face recognition system with multiple model architectures, hyperparameter tuning, and evaluation tools.

**Key Features:**
- Multiple model architectures (Baseline CNN, ResNet, Siamese Networks, Attention Networks, ArcFace, Hybrid CNN-Transformer, Ensemble)
- MTCNN-based face detection and alignment
- Data augmentation pipeline
- Hyperparameter tuning with Optuna
- Comprehensive evaluation metrics (Accuracy, F1, ROC AUC, etc.)
- Command-line interface and interactive menu
- Streamlit demo application

**Technologies:** PyTorch, OpenCV, MTCNN, Optuna, Streamlit

**Quick Start:**
```bash
cd facial-tracking
pip install -r requirements.txt
python -m src.main interactive
```

---

### 2. Chess Bot with Minimax Algorithm

An intelligent chess engine implementing the minimax algorithm with alpha-beta pruning for optimal move selection.

**Key Features:**
- Minimax algorithm implementation
- Alpha-beta pruning for performance optimization
- Evaluation function for board state assessment
- Support for different difficulty levels
- Move validation and game state management
- Command-line or GUI interface

**Technologies:** Python, Chess libraries (if applicable)

**Quick Start:**
```bash
cd chess-bot
python chess_engine.py
```

**Documentation:** See `chess-bot/README.md` for detailed documentation.

---

### 3. RISC-V Processor

A complete RISC-V processor implementation demonstrating understanding of computer architecture and instruction set architecture (ISA).

**Key Features:**
- RISC-V instruction set implementation
- Pipeline architecture (if implemented)
- Register file and ALU
- Memory management unit
- Instruction fetch, decode, execute, write-back stages
- Test benches and verification

**Technologies:** Verilog/SystemVerilog, VHDL, or SystemC (depending on implementation)

**Quick Start:**
```bash
cd risc-v-processor
# Compile and simulate using your preferred toolchain
# (e.g., Verilator, ModelSim, Vivado)
```

**Documentation:** See `risc-v-processor/README.md` for detailed documentation.

---

### 4. Lexical Analyzer

A lexical analyzer (tokenizer) implementation using automata theory principles for parsing and tokenizing source code.

**Key Features:**
- Finite automata implementation
- Token recognition and classification
- Regular expression parsing
- Error handling and reporting
- Support for multiple programming language constructs
- Symbol table management

**Technologies:** Python/C++/Java (depending on implementation), Automata Theory

**Quick Start:**
```bash
cd lexical-analyzer
python lexical_analyzer.py input.txt
```

**Documentation:** See `lexical-analyzer/README.md` for detailed documentation.

---

## Technologies

### Machine Learning & AI
- PyTorch
- NumPy
- OpenCV
- scikit-learn
- Optuna

### Algorithms & Data Structures
- Python
- Algorithm optimization techniques

### Computer Architecture
- Verilog/SystemVerilog/VHDL
- Digital design principles
- Computer organization

### Theoretical Computer Science
- Automata Theory
- Formal languages
- Compiler design principles

---

## Getting Started

### Prerequisites

- **Python 3.8+** (for ML and algorithm projects)
- **Git** (for cloning the repository)
- **Hardware Description Language toolchain** (for RISC-V processor - e.g., Verilator, Vivado, ModelSim)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd portfolio-projects
```

2. Install dependencies for each project individually:

**Face Recognition System:**
```bash
cd facial-tracking
pip install -r requirements.txt
```

**Chess Bot:**
```bash
cd chess-bot
pip install -r requirements.txt  # if applicable
```

**Lexical Analyzer:**
```bash
cd lexical-analyzer
pip install -r requirements.txt  # if applicable
```

**RISC-V Processor:**
- Follow the specific toolchain setup instructions in the project directory

---

---

## Features by Project

| Project | Domain | Complexity | Key Algorithms/Concepts |
|---------|--------|------------|------------------------|
| Face Recognition | Machine Learning | High | CNNs, Transfer Learning, ArcFace, Attention Mechanisms |
| Chess Bot | Algorithms | Medium | Minimax, Alpha-Beta Pruning, Game Trees |
| RISC-V Processor | Computer Architecture | High | Instruction Set Architecture, Pipeline Design |
| Lexical Analyzer | Compiler Design | Medium | Finite Automata, Regular Expressions, Tokenization |

---

## Contributing

This is a personal portfolio repository. If you have suggestions or find issues, please feel free to open an issue or submit a pull request.


---

## Contact

[Your Name]
- GitHub: [@cadedeboe](https://github.com/cadedeboe)
- Email: [cadedeboe@gmail.com]
- LinkedIn: [https://www.linkedin.com/in/cade-deboe-8a15a2346/]

---

## Acknowledgments

- PyTorch team for excellent deep learning framework
- RISC-V Foundation for open ISA specification
- Various open-source libraries and tools used across projects

---

**Note:** Each project directory contains its own detailed README with specific setup instructions, usage examples, and technical documentation. Please refer to individual project READMEs for more information.

