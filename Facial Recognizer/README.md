# Face Recognition System

A comprehensive face recognition system with multiple model architectures, hyperparameter tuning, and evaluation tools.

## Features

- **Multiple Model Architectures**:
  - Baseline CNN
  - ResNet Transfer Learning
  - Siamese Networks
  - Attention-based Networks
  - ArcFace
  - Hybrid CNN-Transformer
  - Ensemble Models

- **Data Preprocessing**:
  - MTCNN face detection and alignment
  - Data augmentation
  - Train/validation/test splits

- **Training Features**:
  - Learning rate scheduling with warmup
  - Gradient clipping
  - Two-phase training for ArcFace
  - Comprehensive metrics tracking

- **Evaluation**:
  - Accuracy, Precision, Recall, F1
  - ROC AUC and PR AUC
  - Inference time measurement
  - Cross-validation support

- **Hyperparameter Tuning**:
  - Optuna integration
  - Learning rate finder
  - Model-specific parameter optimization

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd facial-tracking
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Setup Kaggle credentials (optional, for dataset download):
   - Download `kaggle.json` from https://www.kaggle.com/account
   - Place it in `~/.kaggle/kaggle.json`
   - Set permissions: `chmod 600 ~/.kaggle/kaggle.json`

## Project Structure

```
facial-tracking/
├── src/
│   ├── __init__.py
│   ├── main.py                 # Main entry point
│   ├── base_config.py          # Project configuration
│   ├── face_models.py          # Model architectures
│   ├── data_prep.py            # Data preprocessing
│   ├── data_utils.py           # Dataset utilities
│   ├── training.py             # Training functions
│   ├── testing.py              # Evaluation functions
│   ├── hyperparameter_tuning.py # Optuna hyperparameter tuning
│   ├── cross_validation.py     # Cross-validation
│   ├── interactive.py          # Interactive CLI
│   ├── app.py                  # Streamlit demo app
│   └── download_dataset.py      # Kaggle dataset downloader
├── data/
│   ├── raw/                    # Raw datasets
│   └── processed/              # Processed datasets
├── checkpoints/                # Saved models
├── results/                    # Results and metrics
├── requirements.txt            # Python dependencies
└── README.md                   # This file
```

## Usage

### Command Line Interface

#### Preprocess Data
```bash
python -m src.main preprocess
```

#### Train a Model
```bash
python -m src.main train --model-type arcface --epochs 100 --batch-size 32 --lr 0.0003
```

#### Evaluate a Model
```bash
python -m src.main evaluate --model-type arcface --model-name arcface_1234567890
```

#### Predict on an Image
```bash
python -m src.main predict --model-type arcface --image-path path/to/image.jpg
```

#### Interactive Menu
```bash
python -m src.main interactive
```

#### Check GPU
```bash
python -m src.main check-gpu
```

#### List Available Models
```bash
python -m src.main list-models
```

### Python API

```python
from src.training import train_model
from src.testing import evaluate_model, predict_image
from pathlib import Path

# Train a model
result = train_model(
    model_type='arcface',
    dataset_path=Path('data/processed/dataset1'),
    epochs=100,
    batch_size=32,
    lr=0.0003
)

# Evaluate a model
metrics = evaluate_model(
    model_type='arcface',
    model_name=result['model_name']
)

# Predict on an image
class_name, confidence = predict_image(
    model_type='arcface',
    image_path='path/to/image.jpg'
)
```

## Model Types

- **baseline**: Simple CNN baseline
- **cnn**: ResNet18 transfer learning
- **siamese**: Siamese network for face verification
- **attention**: Attention-based ResNet
- **arcface**: ArcFace with angular margin loss
- **hybrid**: Hybrid CNN-Transformer architecture
- **ensemble**: Ensemble of multiple models

## Data Format

The system expects data in the following structure:

```
data/
└── raw/
    ├── dataset1/
    │   ├── person1/
    │   │   ├── image1.jpg
    │   │   └── image2.jpg
    │   └── person2/
    │       └── ...
    └── dataset2/
        └── ...
```

After preprocessing, data will be organized as:

```
data/
└── processed/
    └── dataset1/
        ├── train/
        │   ├── person1/
        │   └── person2/
        ├── val/
        │   ├── person1/
        │   └── person2/
        └── test/
            ├── person1/
            └── person2/
```

## Configuration

Edit `src/base_config.py` to modify:
- Data directories
- Checkpoint locations
- Default hyperparameters

## Hyperparameter Tuning

Use Optuna for automated hyperparameter optimization:

```python
from src.hyperparameter_tuning import run_hyperparameter_tuning
from pathlib import Path

results = run_hyperparameter_tuning(
    model_type='arcface',
    dataset_path=Path('data/processed/dataset1'),
    n_trials=50,
    epochs_per_trial=10,
    use_lr_finder=True
)
```

## License

[Add your license here]

## Citation

[Add citation if applicable]

