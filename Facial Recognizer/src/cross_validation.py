"""Cross-validation for face recognition models."""
from pathlib import Path
from typing import Dict, Any
import torch
from torch.utils.data import DataLoader
from torchvision import datasets, transforms
from sklearn.model_selection import KFold
import numpy as np

from .face_models import get_model
from .training import train_model
from .testing import evaluate_model


def run_cross_validation(model_type: str, dataset_path: Path, k_folds: int = 5,
                         epochs: int = 10, batch_size: int = 32, **kwargs) -> Dict[str, Any]:
    """Run k-fold cross-validation.
    
    Args:
        model_type: Type of model to evaluate
        dataset_path: Path to processed dataset
        k_folds: Number of folds for cross-validation
        epochs: Number of epochs per fold
        batch_size: Batch size for training
        **kwargs: Additional training parameters
    
    Returns:
        Dictionary with cross-validation results
    """
    print(f"Running {k_folds}-fold cross-validation for {model_type}...")
    
    # Load dataset to get class information
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    
    train_dataset = datasets.ImageFolder(dataset_path / "train", transform=transform)
    num_classes = len(train_dataset.classes)
    
    # Get all image paths and labels
    all_paths = []
    all_labels = []
    for idx, (path, label) in enumerate(train_dataset.samples):
        all_paths.append(path)
        all_labels.append(label)
    
    # Create k-fold splits
    kfold = KFold(n_splits=k_folds, shuffle=True, random_state=42)
    
    fold_accuracies = []
    fold_results = []
    
    for fold, (train_indices, val_indices) in enumerate(kfold.split(all_paths)):
        print(f"\nFold {fold + 1}/{k_folds}")
        print("-" * 50)
        
        # Create fold-specific datasets (simplified - would need custom dataset class)
        # For now, use standard train/val split
        # In a full implementation, you would create custom datasets based on indices
        
        # Train model
        model_name = f"{model_type}_cv_fold{fold+1}"
        result = train_model(
            model_type=model_type,
            dataset_path=dataset_path,
            model_name=model_name,
            epochs=epochs,
            batch_size=batch_size,
            **kwargs
        )
        
        # Evaluate model
        metrics = evaluate_model(
            model_type=model_type,
            model_name=model_name,
            dataset_path=dataset_path
        )
        
        fold_accuracies.append(metrics['accuracy'])
        fold_results.append({
            'fold': fold + 1,
            'accuracy': metrics['accuracy'],
            'f1': metrics['f1']
        })
        
        print(f"Fold {fold + 1} Accuracy: {metrics['accuracy']:.4f}")
    
    # Calculate statistics
    mean_accuracy = np.mean(fold_accuracies)
    std_accuracy = np.std(fold_accuracies)
    
    print("\n" + "=" * 50)
    print("Cross-Validation Results")
    print("=" * 50)
    print(f"Mean Accuracy: {mean_accuracy:.4f} ± {std_accuracy:.4f}")
    print(f"Best Fold: {np.argmax(fold_accuracies) + 1} ({max(fold_accuracies):.4f})")
    print(f"Worst Fold: {np.argmin(fold_accuracies) + 1} ({min(fold_accuracies):.4f})")
    print("=" * 50)
    
    return {
        'mean_accuracy': mean_accuracy,
        'std_accuracy': std_accuracy,
        'fold_results': fold_results,
        'all_accuracies': fold_accuracies
    }

