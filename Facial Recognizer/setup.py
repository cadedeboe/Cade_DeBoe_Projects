"""Setup script for face recognition package."""
from setuptools import setup, find_packages
from pathlib import Path

# Read README for long description
readme_file = Path(__file__).parent / "README.md"
long_description = readme_file.read_text() if readme_file.exists() else ""

setup(
    name="face-recognition-system",
    version="1.0.0",
    description="A comprehensive face recognition system with multiple architectures",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="Your Name",
    author_email="your.email@example.com",
    packages=find_packages(),
    install_requires=[
        "torch>=2.0.0",
        "torchvision>=0.15.0",
        "numpy>=1.24.0",
        "Pillow>=9.5.0",
        "opencv-python>=4.7.0",
        "facenet-pytorch>=2.5.0",
        "albumentations>=1.3.0",
        "scikit-learn>=1.3.0",
        "pandas>=2.0.0",
        "tqdm>=4.65.0",
        "optuna>=3.0.0",
    ],
    extras_require={
        "demo": ["streamlit>=1.25.0"],
        "kaggle": ["kaggle>=1.5.0"],
    },
    python_requires=">=3.8",
    entry_points={
        "console_scripts": [
            "face-recognition=src.main:main",
        ],
    },
)

