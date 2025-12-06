"""Testing and evaluation functions for face recognition models."""
import torch
import torch.nn.functional as F
from torch.utils.data import DataLoader
from torchvision import datasets, transforms
from pathlib import Path
import time
import numpy as np
from PIL import Image
from typing import Optional, Tuple
from tqdm import tqdm
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
from sklearn.metrics import roc_auc_score, roc_curve, auc, precision_recall_curve, average_precision_score

from .face_models import get_model, ArcFaceNet
from .data_utils import SiameseDataset
from .base_config import CHECKPOINTS_DIR, PROC_DATA_DIR


def evaluate_model(model_type: str, model_name: Optional[str] = None, 
                  auto_dataset: bool = False, dataset_path: Optional[Path] = None):
    """Evaluate a trained model with comprehensive metrics."""
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    
    # Get model name if not provided
    if model_name is None:
        model_dirs = list(CHECKPOINTS_DIR.glob(f'{model_type}_*'))
        if not model_dirs:
            raise ValueError(f"No trained models found for type: {model_type}")
        model_name = sorted(model_dirs)[-1].name
    
    model_checkpoint_dir = CHECKPOINTS_DIR / model_name
    
    # Select dataset
    if dataset_path is None:
        processed_dirs = [d for d in PROC_DATA_DIR.iterdir() 
                         if d.is_dir() and (d / "test").exists()]
        if not processed_dirs:
            raise ValueError("No processed datasets found")
        selected_data_dir = processed_dirs[0]
    else:
        selected_data_dir = dataset_path
    
    # Setup transform
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    
    # Load test dataset
    if model_type == 'siamese':
        test_dataset = SiameseDataset(str(selected_data_dir / "test"), 
                                     transform=transform, test_mode=True)
    else:
        test_dataset = datasets.ImageFolder(selected_data_dir / "test", transform=transform)
    
    test_loader = DataLoader(test_dataset, batch_size=32, num_workers=0, pin_memory=True)
    
    # Load model
    num_classes = len(test_dataset.classes) if model_type != 'siamese' else 2
    model = get_model(model_type, num_classes).to(device)
    
    # Load model weights
    best_model_path = model_checkpoint_dir / 'best_model.pth'
    model.load_state_dict(torch.load(best_model_path, map_location=device))
    model.eval()
    
    # Evaluation metrics
    all_predictions = []
    all_targets = []
    all_probs = []
    inference_times = []
    total_loss = 0.0
    
    criterion = torch.nn.CrossEntropyLoss() if model_type != 'siamese' else None
    
    # Evaluation loop
    with torch.no_grad():
        for batch in tqdm(test_loader, desc='Evaluating'):
            if model_type == 'siamese':
                img1, img2, labels = batch
                img1, img2 = img1.to(device), img2.to(device)
                
                # Measure inference time
                start_time = time.time()
                out1, out2 = model(img1, img2)
                dist = F.pairwise_distance(out1, out2)
                pred = (dist < 0.5).float()
                inference_times.append(time.time() - start_time)
                
                all_predictions.extend(pred.cpu().numpy())
                all_targets.extend(labels.numpy())
                all_probs.extend(dist.cpu().numpy()[:, None])
                
            else:
                images, labels = batch
                images = images.to(device)
                labels = labels.to(device)
                
                # Measure inference time
                start_time = time.time()
                
                # Handle different model architectures
                if model_type == 'arcface':
                    embeddings = model(images)
                    outputs = F.linear(
                        F.normalize(embeddings),
                        F.normalize(model.arcface.weight)
                    ) * model.arcface.s
                else:
                    outputs = model(images)
                
                inference_times.append(time.time() - start_time)
                
                loss = criterion(outputs, labels)
                total_loss += loss.item()
                
                probs = F.softmax(outputs, dim=1)
                _, predicted = torch.max(outputs, 1)
                
                all_predictions.extend(predicted.cpu().numpy())
                all_targets.extend(labels.cpu().numpy())
                all_probs.extend(probs.cpu().numpy())
    
    # Calculate metrics
    accuracy = accuracy_score(all_targets, all_predictions)
    precision = precision_score(all_targets, all_probs, average='weighted', zero_division=0)
    recall = recall_score(all_targets, all_probs, average='weighted', zero_division=0)
    f1 = f1_score(all_targets, all_probs, average='weighted', zero_division=0)
    
    # Calculate ROC AUC
    if model_type == 'siamese':
        fpr, tpr, _ = roc_curve(all_targets, -np.array(all_probs).ravel())
        roc_auc = auc(fpr, tpr)
        precision_curve, recall_curve, _ = precision_recall_curve(all_targets, -np.array(all_probs).ravel())
        pr_auc = average_precision_score(all_targets, -np.array(all_probs).ravel())
    else:
        try:
            roc_auc = roc_auc_score(all_targets, all_probs, multi_class='ovr', average='weighted')
            pr_auc = average_precision_score(all_targets, all_probs, average='weighted')
        except:
            roc_auc = 0.0
            pr_auc = 0.0
    
    # Calculate average inference time
    avg_inference_time = np.mean(inference_times)
    
    # Print metrics
    print("\n" + "="*50)
    print("Evaluation Metrics:")
    print("="*50)
    print(f"Accuracy: {accuracy:.4f}")
    print(f"Precision: {precision:.4f}")
    print(f"Recall: {recall:.4f}")
    print(f"F1 Score: {f1:.4f}")
    print(f"ROC AUC: {roc_auc:.4f}")
    print(f"PR AUC: {pr_auc:.4f}")
    print(f"Average Inference Time: {avg_inference_time*1000:.2f} ms")
    if model_type != 'siamese':
        print(f"Test Loss: {total_loss/len(test_loader):.4f}")
    print("="*50)
    
    return {
        'accuracy': accuracy,
        'precision': precision,
        'recall': recall,
        'f1': f1,
        'roc_auc': roc_auc,
        'pr_auc': pr_auc,
        'avg_inference_time': avg_inference_time
    }


def predict_image(model_type: str, image_path: str, 
                 model_name: Optional[str] = None) -> Tuple[str, float]:
    """Make a prediction for a single image.
    
    Args:
        model_type: Type of model to use
        image_path: Path to image file
        model_name: Name of the model (auto-selected if None)
    
    Returns:
        Tuple of (predicted_class, confidence)
    """
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    
    # Find a processed dataset to get class names
    processed_dirs = [d for d in PROC_DATA_DIR.iterdir() 
                     if d.is_dir() and (d / "train").exists()]
    if not processed_dirs:
        raise ValueError("No processed datasets found")
    
    dataset = datasets.ImageFolder(processed_dirs[0] / "train")
    classes = dataset.classes
    
    # Setup transform
    transform = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])
    
    # Load and preprocess image
    image = Image.open(image_path).convert('RGB')
    image_tensor = transform(image).unsqueeze(0).to(device)
    
    # Get model name if not provided
    if model_name is None:
        model_dirs = list(CHECKPOINTS_DIR.glob(f'{model_type}_*'))
        if not model_dirs:
            raise ValueError(f"No trained models found for type: {model_type}")
        model_name = sorted(model_dirs)[-1].name
    
    model_checkpoint_dir = CHECKPOINTS_DIR / model_name
    
    # Load model
    model = get_model(model_type, num_classes=len(classes)).to(device)
    model.load_state_dict(torch.load(model_checkpoint_dir / 'best_model.pth', 
                                    map_location=device))
    model.eval()
    
    # Make prediction
    with torch.no_grad():
        if model_type == 'arcface':
            embeddings = model(image_tensor)
            outputs = F.linear(
                F.normalize(embeddings),
                F.normalize(model.arcface.weight)
            ) * model.arcface.s
        else:
            outputs = model(image_tensor)
        
        probs = F.softmax(outputs, dim=1)
        prob, pred_idx = torch.max(probs, 1)
    
    return classes[pred_idx.item()], prob.item()

