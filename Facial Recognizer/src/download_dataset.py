"""Script to download and prepare face recognition datasets from Kaggle."""
import os
from pathlib import Path
import zipfile
import shutil


def download_kaggle_dataset(dataset_name: str, output_dir: Path):
    """Download dataset from Kaggle.
    
    Args:
        dataset_name: Kaggle dataset name (e.g., 'user/dataset-name')
        output_dir: Directory to save the dataset
    """
    try:
        import kaggle
    except ImportError:
        print("Kaggle API not installed. Install with: pip install kaggle")
        print("Also ensure kaggle.json is in ~/.kaggle/")
        return
    
    output_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"Downloading dataset: {dataset_name}")
    print(f"Output directory: {output_dir}")
    
    # Download dataset
    kaggle.api.dataset_download_files(dataset_name, path=str(output_dir), unzip=True)
    
    print("Download completed!")
    print(f"Files saved to: {output_dir}")


def setup_kaggle_credentials():
    """Setup Kaggle API credentials."""
    kaggle_dir = Path.home() / ".kaggle"
    kaggle_dir.mkdir(exist_ok=True)
    
    kaggle_json = kaggle_dir / "kaggle.json"
    
    if not kaggle_json.exists():
        print("Kaggle credentials not found.")
        print("Please download kaggle.json from https://www.kaggle.com/account")
        print(f"and place it in: {kaggle_dir}")
        return False
    
    # Set permissions
    os.chmod(kaggle_json, 0o600)
    return True


if __name__ == '__main__':
    from .base_config import RAW_DATA_DIR
    
    print("Kaggle Dataset Downloader")
    print("=" * 50)
    
    if not setup_kaggle_credentials():
        print("Please setup Kaggle credentials first.")
        exit(1)
    
    dataset_name = input("Enter Kaggle dataset name (e.g., 'user/dataset-name'): ").strip()
    if dataset_name:
        download_kaggle_dataset(dataset_name, RAW_DATA_DIR)
    else:
        print("No dataset name provided.")

