"""Base configuration for face recognition project."""
import torch
from pathlib import Path
import random
import numpy as np

# Project root directory
PROJECT_ROOT = Path(__file__).parent.parent

# Data directories
RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"
PROC_DATA_DIR = PROJECT_ROOT / "data" / "processed"

# Model checkpoints directory
CHECKPOINTS_DIR = PROJECT_ROOT / "checkpoints"

# Results directory
RESULTS_DIR = PROJECT_ROOT / "results"

# Create directories if they don't exist
for dir_path in [RAW_DATA_DIR, PROC_DATA_DIR, CHECKPOINTS_DIR, RESULTS_DIR]:
    dir_path.mkdir(parents=True, exist_ok=True)


def set_seed(seed: int = 42):
    """Set random seed for reproducibility."""
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    if torch.cuda.is_available():
        torch.cuda.manual_seed(seed)
        torch.cuda.manual_seed_all(seed)
    torch.backends.cudnn.deterministic = True
    torch.backends.cudnn.benchmark = False


def check_gpu():
    """Check GPU availability."""
    if torch.cuda.is_available():
        print(f"GPU available: {torch.cuda.get_device_name(0)}")
        print(f"CUDA version: {torch.version.cuda}")
        return True
    else:
        print("No GPU available, using CPU")
        return False


def query_yes_no(question: str, default: str = "yes") -> bool:
    """Ask a yes/no question and return the answer."""
    valid = {"yes": True, "y": True, "ye": True, "no": False, "n": False}
    if default is None:
        prompt = " [y/n] "
    elif default == "yes":
        prompt = " [Y/n] "
    elif default == "no":
        prompt = " [y/N] "
    else:
        raise ValueError("invalid default answer: '%s'" % default)

    while True:
        choice = input(question + prompt).lower()
        if default is not None and choice == "":
            return valid[default]
        elif choice in valid:
            return valid[choice]
        else:
            print("Please respond with 'yes' or 'no' (or 'y' or 'n').")

