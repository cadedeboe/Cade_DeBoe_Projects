"""Hyperparameter tuning using Optuna."""
import torch
import torch.nn as nn
import torch.optim as optim
import torch.nn.functional as F
from torch.utils.data import DataLoader
from torchvision import datasets, transforms
from pathlib import Path
from typing import Optional, Dict, Any
import optuna
from optuna.trial import TrialState

from .face_models import get_model, ArcFaceNet, ArcMarginProduct
from .data_utils import SiameseDataset
from .training import get_criterion, ContrastiveLoss


# Define model types and baseline hyperparameters
MODEL_TYPES = ["baseline", "cnn", "siamese", "attention", "arcface", "hybrid", "ensemble"]

# Best starting parameters based on extensive experimentation
TRIAL0_BASELINES = {
    "arcface": {
        "epochs": 100, "batch_size": 32, "learning_rate": 3e-4,
        "weight_decay": 1e-3, "dropout": 0.3, "scheduler": "cosine",
        "arcface_margin": 0.15, "arcface_scale": 14.0,
        "label_smoothing": 0.15, "use_lr_warmup": True,
        "warmup_epochs": 25, "use_gradient_clipping": True,
        "clip_grad_norm": 0.3, "optimizer": "AdamW",
        "use_amsgrad": True, "use_progressive_margin": True,
        "initial_margin_factor": 0.0, "easy_margin": True
    },
    "siamese": {
        "epochs": 45, "batch_size": 32, "learning_rate": 1e-4,
        "weight_decay": 2e-4, "dropout": 0.3, "scheduler": "cosine",
        "margin": 2.0, "pos_weight": 1.2, "neg_weight": 0.8
    }
}


class LearningRateFinder:
    """Learning rate finder for optimal learning rate discovery."""
    
    def __init__(self, model, criterion, optimizer, device, 
                 start_lr=1e-7, end_lr=1.0, num_iterations=50):
        self.model = model
        self.criterion = criterion
        self.optimizer = optimizer
        self.device = device
        self.start_lr = start_lr
        self.end_lr = end_lr
        self.num_iterations = num_iterations
        self.lrs = []
        self.losses = []
    
    def find_lr(self, train_loader):
        """Find optimal learning rate."""
        self.model.train()
        lr_mult = (self.end_lr / self.start_lr) ** (1.0 / self.num_iterations)
        
        for batch_idx, batch in enumerate(train_loader):
            if batch_idx >= self.num_iterations:
                break
            
            lr = self.start_lr * (lr_mult ** batch_idx)
            for param_group in self.optimizer.param_groups:
                param_group['lr'] = lr
            
            self.optimizer.zero_grad()
            
            if isinstance(batch, tuple) and len(batch) == 3:
                # Siamese network
                img1, img2, target = batch
                img1, img2, target = img1.to(self.device), img2.to(self.device), target.to(self.device)
                out1, out2 = self.model(img1, img2)
                loss = self.criterion(out1, out2, target)
            else:
                data, target = batch
                data, target = data.to(self.device), target.to(self.device)
                if isinstance(self.model, ArcFaceNet):
                    output = self.model(data, target)
                else:
                    output = self.model(data)
                loss = self.criterion(output, target)
            
            loss.backward()
            self.optimizer.step()
            
            self.lrs.append(lr)
            self.losses.append(loss.item())
    
    def _analyze_results(self):
        """Analyze results to find optimal learning rate."""
        if len(self.losses) < 2:
            return {"overall": {"suggested_learning_rate": 1e-3}}
        
        # Find the learning rate with steepest descent
        losses = torch.tensor(self.losses)
        grads = torch.diff(losses)
        min_grad_idx = torch.argmin(grads)
        
        suggested_lr = self.lrs[min_grad_idx] if min_grad_idx < len(self.lrs) else self.lrs[-1]
        
        return {"overall": {"suggested_learning_rate": suggested_lr}}


def create_optimizer(model: torch.nn.Module, params: dict) -> torch.optim.Optimizer:
    """Create optimizer based on parameters."""
    optimizer_type = params.get("optimizer", "AdamW")
    lr = params.get("learning_rate", 0.001)
    weight_decay = params.get("weight_decay", 0.0)
    use_amsgrad = params.get("use_amsgrad", False)
    
    if optimizer_type == "AdamW":
        return torch.optim.AdamW(
            model.parameters(), lr=lr, weight_decay=weight_decay, amsgrad=use_amsgrad
        )
    elif optimizer_type == "RAdam":
        if hasattr(torch.optim, "RAdam"):
            return torch.optim.RAdam(model.parameters(), lr=lr, weight_decay=weight_decay)
        else:
            return torch.optim.AdamW(model.parameters(), lr=lr, weight_decay=weight_decay)
    elif optimizer_type == "SGD_momentum":
        return torch.optim.SGD(model.parameters(), lr=lr, momentum=0.9, weight_decay=weight_decay)
    else:
        return torch.optim.Adam(model.parameters(), lr=lr, weight_decay=weight_decay)


def get_scheduler(optimizer, params: dict, epochs: int):
    """Create learning rate scheduler based on parameters."""
    scheduler_type = params.get("scheduler", "cosine")
    
    if scheduler_type == "cosine":
        return torch.optim.lr_scheduler.CosineAnnealingLR(
            optimizer, T_max=epochs, eta_min=params.get("learning_rate", 0.001) / 100
        )
    elif scheduler_type == "onecycle":
        return torch.optim.lr_scheduler.OneCycleLR(
            optimizer, max_lr=params.get("learning_rate", 0.001),
            epochs=epochs, steps_per_epoch=params.get("steps_per_epoch", 100), pct_start=0.2
        )
    elif scheduler_type == "plateau":
        return torch.optim.lr_scheduler.ReduceLROnPlateau(
            optimizer, mode='min', factor=params.get("scheduler_factor", 0.5),
            patience=params.get("scheduler_patience", 5)
        )
    else:
        return None


def find_optimal_lr_for_trial(model_type: str, dataset_path: Path, batch_size: int = 32, 
                              num_iterations: int = 50) -> float:
    """Find the optimal learning rate for a specific trial."""
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    
    # Setup data transforms
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    
    # Load dataset (simplified)
    if model_type == 'siamese':
        train_dataset = SiameseDataset(str(dataset_path / "train"), transform=transform)
        num_classes = 2
    else:
        train_dataset = datasets.ImageFolder(dataset_path / "train", transform=transform)
        num_classes = len(train_dataset.classes)
    
    train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
    
    # Initialize model and optimizer
    model = get_model(model_type, num_classes=num_classes).to(device)
    criterion = get_criterion(model_type)
    optimizer = torch.optim.Adam(model.parameters(), lr=1e-7)
    
    # Configure model-specific learning rate ranges
    start_lr = 1e-7
    if model_type == 'arcface':
        end_lr = 0.01
        num_iterations = 70 if num_iterations == 50 else num_iterations
    elif model_type == 'siamese':
        end_lr = 0.1
        num_iterations = 60 if num_iterations == 50 else num_iterations
    else:
        end_lr = 1.0
    
    # Run LR finder and return optimal learning rate
    lr_finder = LearningRateFinder(
        model=model, criterion=criterion, optimizer=optimizer, device=device,
        start_lr=start_lr, end_lr=end_lr, num_iterations=num_iterations
    )
    
    lr_finder.find_lr(train_loader)
    return lr_finder._analyze_results()["overall"]["suggested_learning_rate"]


def objective(trial: optuna.Trial, model_type: str, dataset_path: Path,
             use_trial0_baseline: bool, use_lr_finder: bool = False,
             optimizer_type: Optional[str] = None, epochs_per_trial: int = 10,
             use_early_stopping: bool = True) -> float:
    """Optuna objective function for a single trial."""
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    
    # Use baseline or sample hyperparameters
    if use_trial0_baseline and trial.number == 0 and model_type in TRIAL0_BASELINES:
        params = TRIAL0_BASELINES[model_type].copy()
    else:
        params = {}
    
    # Sample hyperparameters
    params['batch_size'] = trial.suggest_categorical('batch_size',
                           [16, 32, 64, 128, 256] if device.type == 'cuda' else [8, 16, 32, 64])
    
    # Use LR Finder if enabled, otherwise sample from distribution
    if use_lr_finder:
        try:
            optimal_lr = find_optimal_lr_for_trial(model_type, dataset_path, params['batch_size'])
            # Apply model-specific scaling factors
            if model_type == 'arcface':
                min_lr, max_lr = max(5e-5, optimal_lr/10), min(5e-4, optimal_lr/2)
            elif model_type == 'siamese':
                min_lr, max_lr = max(1e-5, optimal_lr/4), min(5e-4, optimal_lr*2)
            else:
                min_lr, max_lr = optimal_lr/3, optimal_lr*3
            params['learning_rate'] = trial.suggest_float('learning_rate', min_lr, max_lr, log=True)
        except Exception:
            params['learning_rate'] = trial.suggest_float('learning_rate', 1e-5, 1e-2, log=True)
    else:
        params['learning_rate'] = trial.suggest_float('learning_rate', 1e-5, 1e-2, log=True)
    
    # Sample other hyperparameters
    params['weight_decay'] = trial.suggest_float('weight_decay',
                            5e-4 if model_type == 'arcface' else 1e-5,
                            2e-2 if model_type == 'arcface' else 1e-3, log=True)
    
    params['optimizer'] = optimizer_type or trial.suggest_categorical('optimizer',
                         ['AdamW', 'RAdam', 'SGD_momentum'])
    params['scheduler'] = trial.suggest_categorical('scheduler', ['cosine', 'onecycle', 'plateau'])
    params['dropout'] = trial.suggest_float('dropout', 0.0, 0.5)
    
    # Model-specific parameters (ArcFace example)
    if model_type == 'arcface':
        params['arcface_margin'] = trial.suggest_float('arcface_margin', 0.1, 0.3)
        params['arcface_scale'] = trial.suggest_float('arcface_scale', 12.0, 18.0)
        params['easy_margin'] = True
        params['use_progressive_margin'] = True
        params['initial_margin_factor'] = 0.0
        params['use_gradient_clipping'] = True
        params['clip_grad_norm'] = trial.suggest_float('clip_grad_norm', 0.1, 1.0)
        params['use_amsgrad'] = True
        params['label_smoothing'] = trial.suggest_float('label_smoothing', 0.05, 0.15)
        params['use_lr_warmup'] = True
        params['warmup_epochs'] = trial.suggest_int('warmup_epochs', 5, 15)
    
    # Setup data and model
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    
    # Load datasets and prepare loaders
    if model_type == 'siamese':
        train_dataset = SiameseDataset(dataset_path / "train", transform=transform)
        val_dataset = SiameseDataset(dataset_path / "val", transform=transform, test_mode=True)
    else:
        train_dataset = datasets.ImageFolder(dataset_path / "train", transform=transform)
        val_dataset = datasets.ImageFolder(dataset_path / "val", transform=transform)
    
    num_classes = len(train_dataset.classes) if hasattr(train_dataset, 'classes') else 2
    
    train_loader = DataLoader(train_dataset, batch_size=params['batch_size'], shuffle=True)
    val_loader = DataLoader(val_dataset, batch_size=params['batch_size'], shuffle=False)
    
    # Initialize model with custom parameters for ArcFace
    if model_type == 'arcface':
        model = get_model(model_type, num_classes=num_classes)
        if 'arcface_margin' in params and 'arcface_scale' in params:
            new_arcface = ArcMarginProduct(
                in_feats=512,
                out_feats=num_classes,
                s=float(params['arcface_scale']),
                m=float(params['arcface_margin']),
                use_warm_up=params.get('use_lr_warmup', True)
            )
            new_arcface.use_warm_up = True
            new_arcface.warm_up_epochs = params.get('warmup_epochs', 10)
            new_arcface.margin_factor = params.get('initial_margin_factor', 0.0)
            new_arcface.scale_factor = 0.2
            model.arcface = new_arcface
    else:
        model = get_model(model_type, num_classes=num_classes)
    
    model = model.to(device)
    
    # Initialize training components
    optimizer = create_optimizer(model, params)
    criterion = nn.CrossEntropyLoss(label_smoothing=params['label_smoothing']) \
        if model_type == 'arcface' and 'label_smoothing' in params else get_criterion(model_type)
    scheduler = get_scheduler(optimizer, params, epochs=epochs_per_trial)
    
    # Training loop (simplified)
    best_val_acc = 0.0
    for epoch in range(epochs_per_trial):
        # Training phase
        model.train()
        train_loss, train_correct, train_total = 0.0, 0, 0
        
        for batch in train_loader:
            if model_type == 'siamese':
                img1, img2, targets = batch
                img1, img2, targets = img1.to(device), img2.to(device), targets.to(device)
                optimizer.zero_grad()
                out1, out2 = model(img1, img2)
                loss = criterion(out1, out2, targets)
                loss.backward()
                if params.get('use_gradient_clipping', False):
                    clip_value = params.get('clip_grad_norm', 0.5)
                    torch.nn.utils.clip_grad_norm_(model.parameters(), clip_value)
                optimizer.step()
                # Calculate accuracy for siamese
                dist = F.pairwise_distance(out1, out2)
                pred = (dist < 0.5).float()
                train_total += targets.size(0)
                train_correct += int(pred.eq(targets.view_as(pred)).sum().item())
                continue
            else:
                inputs, targets = batch
                inputs, targets = inputs.to(device), targets.to(device)
                optimizer.zero_grad()
                
                if model_type == 'arcface' and model.training:
                    outputs = model(inputs, labels=targets)
                    model.current_epoch = epoch
                else:
                    outputs = model(inputs)
                
                loss = criterion(outputs, targets)
                loss.backward()
                
                if model_type == 'arcface' and params.get('use_gradient_clipping', False):
                    clip_value = params.get('clip_grad_norm', 0.5)
                    torch.nn.utils.clip_grad_norm_(model.parameters(), clip_value)
                
                optimizer.step()
                
                _, predicted = outputs.max(1)
                train_total += targets.size(0)
                train_correct += predicted.eq(targets).sum().item()
        
        # Validation phase
        model.eval()
        val_loss, val_correct, val_total = 0.0, 0, 0
        
        with torch.no_grad():
            for batch in val_loader:
                if model_type == 'siamese':
                    img1, img2, targets = batch
                    img1, img2, targets = img1.to(device), img2.to(device), targets.to(device)
                    out1, out2 = model(img1, img2)
                    dist = F.pairwise_distance(out1, out2)
                    pred = (dist < 0.5).float()
                    val_total += targets.size(0)
                    val_correct += int(pred.eq(targets.view_as(pred)).sum().item())
                    continue
                else:
                    inputs, targets = batch
                    inputs, targets = inputs.to(device), targets.to(device)
                    
                    if model_type == 'arcface':
                        embeddings = model.get_embedding(inputs)
                        normalized_embeddings = F.normalize(embeddings, p=2, dim=1)
                        class_centers = F.normalize(model.arcface.weight, p=2, dim=1)
                        scale_factor = model.arcface.s
                        outputs = torch.matmul(normalized_embeddings, class_centers.t()) * scale_factor
                    else:
                        outputs = model(inputs)
                    
                    loss = criterion(outputs, targets)
                    
                    _, predicted = outputs.max(1)
                    val_total += targets.size(0)
                    val_correct += predicted.eq(targets).sum().item()
        
        val_acc = val_correct / val_total if val_total > 0 else 0.0
        
        # Early stopping logic
        if val_acc > best_val_acc:
            best_val_acc = val_acc
        
        # Update scheduler
        if scheduler is not None:
            if isinstance(scheduler, torch.optim.lr_scheduler.ReduceLROnPlateau):
                scheduler.step(val_loss)
            else:
                scheduler.step()
        
        # Update ArcFace parameters
        if model_type == 'arcface' and hasattr(model, 'arcface'):
            model.arcface.update_epoch(epoch)
        
        trial.report(val_acc, epoch)
        if trial.should_prune():
            raise optuna.TrialPruned()
    
    return best_val_acc


def run_hyperparameter_tuning(model_type: Optional[str] = None,
                             dataset_path: Optional[Path] = None,
                             n_trials: int = 20,
                             timeout: Optional[int] = None,
                             use_trial0_baseline: bool = True,
                             use_lr_finder: bool = False,
                             lr_finder_iterations: int = 50,
                             optimizer_type: Optional[str] = None,
                             arcface_params: Optional[Dict[str, Any]] = None,
                             epochs_per_trial: int = 10,
                             use_early_stopping: bool = True,
                             use_mixed_precision: bool = True) -> Optional[Dict[str, Any]]:
    """Run hyperparameter tuning process."""
    # Performance optimizations
    if torch.cuda.is_available():
        torch.backends.cudnn.benchmark = True
        if use_mixed_precision:
            torch.backends.cuda.matmul.allow_tf32 = True
            torch.backends.cudnn.allow_tf32 = True
    
    # Create Optuna study
    study_name = f"{model_type}_{dataset_path.name if dataset_path else 'default'}"
    storage_name = f"sqlite:///hyperopt_runs/{study_name}.db"
    
    # Create directory for hyperopt runs
    Path("hyperopt_runs").mkdir(exist_ok=True)
    
    try:
        study = optuna.create_study(
            study_name=study_name,
            storage=storage_name,
            load_if_exists=True,
            direction="maximize"
        )
    except:
        study = optuna.create_study(
            study_name=study_name,
            storage=storage_name,
            direction="maximize"
        )
    
    study.optimize(
        lambda trial: objective(
            trial, model_type, dataset_path, use_trial0_baseline, use_lr_finder,
            optimizer_type, epochs_per_trial, use_early_stopping
        ),
        n_trials=n_trials,
        timeout=timeout
    )
    
    # Return best parameters
    return {
        'model_type': model_type,
        'dataset': dataset_path.name if dataset_path else 'unknown',
        'n_trials': n_trials,
        'best_trial': study.best_trial.number,
        'best_accuracy': study.best_value,
        'best_params': study.best_params
    }

