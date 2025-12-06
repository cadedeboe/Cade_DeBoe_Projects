"""Training functions for face recognition models."""
import torch
import torch.nn as nn
import torch.optim as optim
import torch.nn.functional as F
from torch.utils.data import DataLoader
from torchvision import datasets, transforms
from pathlib import Path
import time
import math
import logging
from typing import Optional, Dict, Any, List
import pandas as pd

from .face_models import get_model, ArcFaceNet
from .data_utils import SiameseDataset
from .base_config import CHECKPOINTS_DIR

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class ContrastiveLoss(nn.Module):
    """Contrastive loss for Siamese networks."""
    def __init__(self, margin: float = 2.0):
        super().__init__()
        self.margin = margin
    
    def forward(self, output1: torch.Tensor, output2: torch.Tensor, label: torch.Tensor):
        """Forward pass."""
        euclidean_distance = F.pairwise_distance(output1, output2)
        loss_contrastive = torch.mean((1-label) * torch.pow(euclidean_distance, 2) +
                                     (label) * torch.pow(torch.clamp(self.margin - euclidean_distance, min=0.0), 2))
        return loss_contrastive


def get_criterion(model_type: str, **kwargs) -> nn.Module:
    """Get loss criterion for model type."""
    if model_type == 'siamese':
        margin = kwargs.get('margin', 2.0)
        return ContrastiveLoss(margin=margin)
    else:
        label_smoothing = kwargs.get('label_smoothing', 0.0)
        return nn.CrossEntropyLoss(label_smoothing=label_smoothing)


def get_warmup_scheduler(optimizer, warmup_epochs: int, total_epochs: int, steps_per_epoch: int):
    """Creates learning rate scheduler with warm-up phase followed by cosine annealing."""
    def lr_lambda(current_step):
        warmup_steps = warmup_epochs * steps_per_epoch
        if current_step < warmup_steps:
            # Linear warm-up
            return float(current_step) / float(max(1, warmup_steps))
        else:
            # Cosine annealing after warm-up
            progress = float(current_step - warmup_steps) / float(max(1, total_epochs * steps_per_epoch - warmup_steps))
            return 0.5 * (1.0 + math.cos(math.pi * progress))
            
    return optim.lr_scheduler.LambdaLR(optimizer, lr_lambda)


def plot_learning_curves(train_losses: List[float], val_losses: List[float], 
                       accuracies: List[float], output_dir: str, model_name: str,
                       train_accuracies: Optional[List[float]] = None):
    """Record learning curves metrics without plotting."""
    # Create the output directory structure for metrics
    save_dir = Path(output_dir) / "metrics" / model_name
    save_dir.mkdir(parents=True, exist_ok=True)
    
    # Save metrics to a CSV file for future reference
    epochs = list(range(1, len(train_losses) + 1))
    metrics_dict = {
        'epoch': epochs,
        'train_loss': train_losses,
        'val_loss': val_losses,
        'val_accuracy': accuracies
    }
    
    if train_accuracies is not None:
        metrics_dict['train_accuracy'] = train_accuracies
    
    metrics_df = pd.DataFrame(metrics_dict)
    metrics_df.to_csv(save_dir / 'learning_curves_data.csv', index=False)
    
    # Log summary statistics
    logger.info(f"Final metrics - Train Loss: {train_losses[-1]:.4f}, "
                f"Val Loss: {val_losses[-1]:.4f}, Val Accuracy: {accuracies[-1]:.4f}")


def train_model(model_type: str, dataset_path: Path, model_name: Optional[str] = None,
                batch_size: int = 32, epochs: int = 50, lr: float = 0.001,
                weight_decay: float = 1e-4, clip_grad_norm: Optional[float] = None,
                use_warmup: bool = False, warmup_epochs: int = 10,
                two_phase_training: bool = False, phase1_epochs: int = 20,
                easy_margin: bool = True, **kwargs) -> Dict[str, Any]:
    """Train a face recognition model.
    
    Args:
        model_type: Type of model to train
        dataset_path: Path to processed dataset
        model_name: Name for the model (auto-generated if None)
        batch_size: Batch size for training
        epochs: Number of training epochs
        lr: Learning rate
        weight_decay: Weight decay for optimizer
        clip_grad_norm: Gradient clipping norm (None to disable)
        use_warmup: Use learning rate warmup
        warmup_epochs: Number of warmup epochs
        two_phase_training: Use two-phase training for ArcFace
        phase1_epochs: Number of epochs for phase 1 (frozen backbone)
        easy_margin: Use easy margin for ArcFace
        **kwargs: Additional model-specific parameters
    
    Returns:
        Dictionary with training results
    """
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    logger.info(f"Using device: {device}")
    
    # Setup data transforms
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    
    # Load datasets
    if model_type == 'siamese':
        train_dataset = SiameseDataset(str(dataset_path / "train"), transform=transform)
        val_dataset = SiameseDataset(str(dataset_path / "val"), transform=transform, test_mode=True)
    else:
        train_dataset = datasets.ImageFolder(dataset_path / "train", transform=transform)
        val_dataset = datasets.ImageFolder(dataset_path / "val", transform=transform)
    
    train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True, num_workers=2)
    val_loader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False, num_workers=2)
    
    num_classes = len(train_dataset.classes) if hasattr(train_dataset, 'classes') else 2
    
    # Initialize model
    if model_type == 'arcface':
        model = ArcFaceNet(
            num_classes=num_classes,
            dropout_rate=kwargs.get('dropout_rate', 0.2),
            s=kwargs.get('s', 32.0),
            m=kwargs.get('m', 0.5),
            easy_margin=easy_margin
        )
    else:
        model = get_model(model_type, num_classes=num_classes)
    
    model = model.to(device)
    
    # Setup loss and optimizer
    if model_type == 'arcface':
        criterion = nn.CrossEntropyLoss(label_smoothing=kwargs.get('label_smoothing', 0.05))
        optimizer = optim.AdamW(
            model.parameters(),
            lr=lr,
            weight_decay=weight_decay,
            amsgrad=kwargs.get('use_amsgrad', True)
        )
    else:
        criterion = get_criterion(model_type, **kwargs)
        optimizer = optim.AdamW(model.parameters(), lr=lr, weight_decay=weight_decay)
    
    # Setup scheduler
    scheduler = None
    scheduler_type = kwargs.get('scheduler', 'cosine')
    
    if model_type == 'arcface' and use_warmup:
        steps_per_epoch = len(train_loader)
        scheduler = get_warmup_scheduler(
            optimizer=optimizer,
            warmup_epochs=warmup_epochs,
            total_epochs=epochs,
            steps_per_epoch=steps_per_epoch
        )
        logger.info(f"Using warm-up scheduler for ArcFace with {warmup_epochs} epochs of warm-up")
    elif scheduler_type == 'cosine':
        scheduler = optim.lr_scheduler.CosineAnnealingLR(
            optimizer, T_max=epochs, eta_min=lr / 100
        )
    elif scheduler_type == 'reduce_lr':
        scheduler = optim.lr_scheduler.ReduceLROnPlateau(
            optimizer, mode='min', factor=0.5, patience=5
        )
    
    # Two-phase training setup for ArcFace
    if model_type == 'arcface' and two_phase_training and hasattr(model, 'freeze_backbone'):
        model.freeze_backbone()
        logger.info("Initialized two-phase training: backbone frozen for initial training phase")
    
    # Create model checkpoint directory
    if model_name is None:
        model_name = f"{model_type}_{int(time.time())}"
    model_checkpoint_dir = CHECKPOINTS_DIR / model_name
    model_checkpoint_dir.mkdir(parents=True, exist_ok=True)
    
    # Training metrics
    train_losses = []
    val_losses = []
    val_accuracies = []
    train_accuracies = []
    best_val_acc = 0.0
    
    # Core training loop
    for epoch in range(epochs):
        # Check for phase transition
        if two_phase_training and epoch == phase1_epochs and model.phase == 1:
            logger.info(f"Transitioning ArcFace model to phase 2 (full fine-tuning)")
            model.unfreeze_backbone()
            # Reduce learning rate for fine-tuning phase
            for param_group in optimizer.param_groups:
                param_group['lr'] = param_group['lr'] * 0.5
        
        # Training phase
        model.train()
        train_loss = 0.0
        train_correct = 0
        train_total = 0
        start_time = time.time()
        
        for batch_idx, batch in enumerate(train_loader):
            if model_type == 'siamese':
                img1, img2, target = batch
                img1, img2, target = img1.to(device), img2.to(device), target.to(device)
                optimizer.zero_grad()
                out1, out2 = model(img1, img2)
                loss = criterion(out1, out2, target)
            else:
                data, target = batch
                data, target = data.to(device), target.to(device)
                optimizer.zero_grad()
                
                # Handle ArcFace differently
                if model_type == 'arcface':
                    output = model(data, target)  # ArcFace needs labels during forward pass
                    model.current_epoch = epoch
                else:
                    output = model(data)
                
                loss = criterion(output, target)
            
            # Backpropagation with gradient clipping
            loss.backward()
            if clip_grad_norm is not None:
                torch.nn.utils.clip_grad_norm_(model.parameters(), clip_grad_norm)
            optimizer.step()
            
            train_loss += loss.item()
            
            # Calculate training accuracy
            if model_type == 'siamese':
                dist = F.pairwise_distance(out1, out2)
                pred = (dist < 0.5).float()
                train_correct += int(pred.eq(target.view_as(pred)).sum().item())
            else:
                _, predicted = output.max(1)
                train_correct += int(predicted.eq(target).sum().item())
            train_total += target.size(0)
        
        # Validation phase
        model.eval()
        val_loss = 0.0
        correct = 0
        total = 0
        
        with torch.no_grad():
            for batch in val_loader:
                # Model-specific validation handling
                if model_type == 'siamese':
                    img1, img2, target = batch
                    img1, img2, target = img1.to(device), img2.to(device), target.to(device)
                    out1, out2 = model(img1, img2)
                    dist = F.pairwise_distance(out1, out2)
                    pred = (dist < 0.5).float()
                    correct += int(pred.eq(target.view_as(pred)).sum().item())
                else:
                    data, target = batch
                    data, target = data.to(device), target.to(device)
                    
                    if model_type == 'arcface':
                        embeddings = model.get_embedding(data)
                        normalized_embeddings = F.normalize(embeddings, p=2, dim=1)
                        class_centers = F.normalize(model.arcface.weight, p=2, dim=1)
                        scale_factor = model.arcface.s
                        output = torch.matmul(normalized_embeddings, class_centers.t()) * scale_factor
                    else:
                        output = model(data)
                    
                    val_loss += criterion(output, target).item()
                    _, pred = output.max(1)
                    correct += int(pred.eq(target).sum().item())
                total += target.size(0)
        
        # Calculate metrics
        train_loss_avg = train_loss / len(train_loader)
        train_acc = train_correct / train_total if train_total > 0 else 0.0
        val_loss_avg = val_loss / len(val_loader) if model_type != 'siamese' else 0.0
        accuracy = correct / total
        
        train_losses.append(train_loss_avg)
        val_losses.append(val_loss_avg)
        val_accuracies.append(accuracy)
        train_accuracies.append(train_acc)
        
        # Save best model
        if accuracy > best_val_acc:
            best_val_acc = accuracy
            torch.save(model.state_dict(), model_checkpoint_dir / 'best_model.pth')
        
        # Update scheduler
        if scheduler is not None:
            if isinstance(scheduler, optim.lr_scheduler.ReduceLROnPlateau):
                scheduler.step(val_loss_avg)
            else:
                scheduler.step()
        
        # Log progress
        epoch_time = time.time() - start_time
        logger.info(f"Epoch {epoch+1}/{epochs} - "
                   f"Train Loss: {train_loss_avg:.4f}, Train Acc: {train_acc:.4f}, "
                   f"Val Loss: {val_loss_avg:.4f}, Val Acc: {accuracy:.4f}, "
                   f"Time: {epoch_time:.2f}s")
    
    # Save learning curves
    plot_learning_curves(train_losses, val_losses, val_accuracies, 
                        str(CHECKPOINTS_DIR), model_name, train_accuracies)
    
    logger.info(f"Training completed. Best validation accuracy: {best_val_acc:.4f}")
    
    return {
        'model_name': model_name,
        'best_val_acc': best_val_acc,
        'final_train_loss': train_losses[-1],
        'final_val_loss': val_losses[-1],
        'checkpoint_dir': str(model_checkpoint_dir)
    }

