"""Data utilities for face recognition."""
import torch
from torch.utils.data import Dataset
from pathlib import Path
import random
from PIL import Image
import torchvision.transforms as transforms


class SiameseDataset(Dataset):
    """Siamese dataset for face verification."""
    
    def __init__(self, root_dir: str, transform=None, test_mode: bool = False):
        """Initialize Siamese dataset.
        
        Args:
            root_dir: Root directory containing class folders
            transform: Image transformations
            test_mode: If True, use fixed pairs for reproducibility
        """
        self.root_dir = Path(root_dir)
        self.transform = transform
        self.test_mode = test_mode
        
        # Get all class directories
        self.classes = sorted([d.name for d in self.root_dir.iterdir() if d.is_dir()])
        self.class_to_idx = {cls_name: idx for idx, cls_name in enumerate(self.classes)}
        
        # Build image paths dictionary
        self.images_by_class = {}
        for cls_name in self.classes:
            cls_dir = self.root_dir / cls_name
            images = list(cls_dir.glob("*.jpg")) + list(cls_dir.glob("*.png")) + \
                     list(cls_dir.glob("*.jpeg"))
            self.images_by_class[cls_name] = images
        
        # Generate pairs
        if test_mode:
            self.pairs = self._generate_fixed_pairs()
        else:
            self.pairs = self._generate_random_pairs()
    
    def _generate_fixed_pairs(self, num_pairs: int = 1000):
        """Generate fixed pairs for testing."""
        pairs = []
        random.seed(42)  # Fixed seed for reproducibility
        
        for _ in range(num_pairs):
            # Randomly decide if positive or negative pair
            is_same = random.random() < 0.5
            
            if is_same:
                # Positive pair: same class
                cls_name = random.choice(self.classes)
                images = self.images_by_class[cls_name]
                if len(images) < 2:
                    continue
                img1_path, img2_path = random.sample(images, 2)
                pairs.append((img1_path, img2_path, 1))
            else:
                # Negative pair: different classes
                if len(self.classes) < 2:
                    continue
                cls1, cls2 = random.sample(self.classes, 2)
                img1_path = random.choice(self.images_by_class[cls1])
                img2_path = random.choice(self.images_by_class[cls2])
                pairs.append((img1_path, img2_path, 0))
        
        return pairs
    
    def _generate_random_pairs(self):
        """Generate random pairs for training."""
        pairs = []
        
        # Generate positive pairs
        for cls_name, images in self.images_by_class.items():
            if len(images) < 2:
                continue
            # Create multiple positive pairs per class
            for _ in range(len(images)):
                img1_path, img2_path = random.sample(images, 2)
                pairs.append((img1_path, img2_path, 1))
        
        # Generate negative pairs (same number as positive)
        num_negative = len(pairs)
        for _ in range(num_negative):
            if len(self.classes) < 2:
                break
            cls1, cls2 = random.sample(self.classes, 2)
            img1_path = random.choice(self.images_by_class[cls1])
            img2_path = random.choice(self.images_by_class[cls2])
            pairs.append((img1_path, img2_path, 0))
        
        return pairs
    
    def __len__(self):
        return len(self.pairs)
    
    def __getitem__(self, idx):
        img1_path, img2_path, label = self.pairs[idx]
        
        img1 = Image.open(img1_path).convert('RGB')
        img2 = Image.open(img2_path).convert('RGB')
        
        if self.transform:
            img1 = self.transform(img1)
            img2 = self.transform(img2)
        
        return img1, img2, torch.tensor(label, dtype=torch.float32)

