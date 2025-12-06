"""Data preprocessing for face recognition."""
import cv2
import numpy as np
from PIL import Image
from pathlib import Path
from typing import Tuple, Optional, Dict
from tqdm import tqdm
import torch
from facenet_pytorch import MTCNN
import albumentations as A
from torchvision import datasets


class PreprocessingConfig:
    """Configuration for preprocessing pipeline."""
    
    def __init__(self,
                 name: str,
                 use_mtcnn: bool = True,
                 face_margin: float = 0.4,
                 final_size: Tuple[int, int] = (224, 224),
                 augmentation: bool = True):
        """Initialize preprocessing configuration."""
        self.name = name
        self.use_mtcnn = use_mtcnn
        self.face_margin = face_margin
        self.final_size = final_size
        self.min_face_size = 20
        self.thresholds = [0.6, 0.7, 0.7]
        self.augmentation = augmentation
        # Augmentation parameters
        self.aug_rotation_range = 20
        self.aug_brightness_range = 0.2
        self.aug_contrast_range = 0.2
        self.aug_scale_range = 0.1
        self.horizontal_flip = True

    def to_dict(self) -> Dict:
        """Convert config to dictionary for saving."""
        return self.__dict__

    @classmethod
    def from_dict(cls, config_dict: Dict) -> 'PreprocessingConfig':
        """Create config from dictionary."""
        constructor_params = {
            'name': config_dict['name'],
            'use_mtcnn': config_dict['use_mtcnn'],
            'face_margin': config_dict['face_margin'],
            'final_size': config_dict['final_size'],
            'augmentation': config_dict['augmentation']
        }
        
        config = cls(**constructor_params)
        
        # Set additional attributes
        for key, value in config_dict.items():
            if key not in constructor_params:
                setattr(config, key, value)
                
        return config


def align_face(image: np.ndarray, landmarks: np.ndarray) -> np.ndarray:
    """Align face based on eye landmarks."""
    left_eye = landmarks[0]
    right_eye = landmarks[1]
    
    # Calculate angle to rotate image
    dY = right_eye[1] - left_eye[1]
    dX = right_eye[0] - left_eye[0]
    angle = np.degrees(np.arctan2(dY, dX))
    
    # Get the center point between the eyes
    eye_center = ((left_eye[0] + right_eye[0]) // 2,
                  (left_eye[1] + right_eye[1]) // 2)
    
    # Rotate the image
    M = cv2.getRotationMatrix2D(eye_center, angle, 1.0)
    aligned = cv2.warpAffine(image, M, (image.shape[1], image.shape[0]))
    
    return aligned


def get_face_bbox_with_margin(bbox: np.ndarray, margin: float, 
                              img_shape: Tuple[int, int]) -> np.ndarray:
    """Get face bounding box with margin."""
    x1, y1, x2, y2 = bbox
    
    width = x2 - x1
    height = y2 - y1
    
    margin_x = int(width * margin)
    margin_y = int(height * margin)
    
    x1 = max(0, x1 - margin_x)
    y1 = max(0, y1 - margin_y)
    x2 = min(img_shape[1], x2 + margin_x)
    y2 = min(img_shape[0], y2 + margin_y)
    
    return np.array([x1, y1, x2, y2])


def preprocess_image(image_path: str, config: PreprocessingConfig) -> Optional[Image.Image]:
    """Preprocess a single image according to configuration."""
    try:
        # Read image
        image = cv2.imread(str(image_path))
        if image is None:
            return None
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        
        if config.use_mtcnn:
            mtcnn = MTCNN(
                image_size=config.final_size[0],
                margin=config.face_margin,
                min_face_size=config.min_face_size,
                thresholds=config.thresholds,
                device=torch.device('cuda' if torch.cuda.is_available() else 'cpu')
            )
            
            boxes, probs, landmarks = mtcnn.detect(image, landmarks=True)
            
            if boxes is None or len(boxes) == 0:
                return None
            
            # Use the face with highest probability
            box = boxes[0]
            landmark = landmarks[0]
            
            # Get face bbox with margin
            bbox = get_face_bbox_with_margin(box, config.face_margin, image.shape)
            
            # Align face using landmarks
            aligned_face = align_face(image, landmark)
            
            # Crop to face region
            face = aligned_face[int(bbox[1]):int(bbox[3]), 
                              int(bbox[0]):int(bbox[2])]
        else:
            face = image
        
        # Resize
        face = cv2.resize(face, config.final_size)
        
        # Convert to PIL Image
        face_pil = Image.fromarray(face)
        
        if config.augmentation:
            # Define augmentation pipeline
            transform = A.Compose([
                A.Rotate(limit=config.aug_rotation_range, p=0.5),
                A.RandomBrightnessContrast(
                    brightness_limit=config.aug_brightness_range,
                    contrast_limit=config.aug_contrast_range,
                    p=0.5
                ),
                A.RandomScale(scale_limit=config.aug_scale_range, p=0.5),
                A.HorizontalFlip(p=0.5 if config.horizontal_flip else 0),
            ])
            
            # Apply augmentations
            augmented = transform(image=np.array(face_pil))
            face_pil = Image.fromarray(augmented['image'])
        
        return face_pil
    
    except Exception as e:
        return None


def process_raw_data(raw_data_dir, output_dir, config=None, test_mode=False, 
                     max_samples_per_class=None):
    """Process raw image data for face recognition."""
    raw_data_dir = Path(raw_data_dir)
    output_dir = Path(output_dir)
    
    # Map folder names to expected dataset names
    dataset_mapping = {
        "dataset1": "dataset1",  # 36 celebrities, 49 images each
        "dataset2": "dataset2"    # 18 celebrities, 100 images each
    }
    
    # Set up preprocessing config if not provided
    if config is None:
        config = PreprocessingConfig(
            name="default",
            use_mtcnn=True,
            face_margin=0.4,
            final_size=(224, 224),
            augmentation=True
        )
    
    # Create MTCNN detector if needed
    mtcnn = None
    if config.use_mtcnn:
        device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        mtcnn = MTCNN(
            image_size=config.final_size[0],
            margin=config.face_margin,
            min_face_size=config.min_face_size,
            thresholds=config.thresholds,
            device=device
        )
    
    # Create output directories
    output_dir.mkdir(parents=True, exist_ok=True)
    train_dir = output_dir / "train"
    val_dir = output_dir / "val"
    test_dir = output_dir / "test"
    
    for d in [train_dir, val_dir, test_dir]:
        d.mkdir(exist_ok=True)
    
    # Process each dataset
    for source_name, target_name in dataset_mapping.items():
        source_dir = raw_data_dir / source_name
        if not source_dir.exists():
            continue
        
        # Get all person directories
        person_dirs = [d for d in source_dir.iterdir() if d.is_dir()]
        
        # Process each person's directory
        for person_dir in tqdm(person_dirs, desc=f"Processing {source_name}"):
            person_name = person_dir.name
            
            # Create person directories in train/val/test
            train_person_dir = train_dir / person_name
            val_person_dir = val_dir / person_name
            test_person_dir = test_dir / person_name
            
            for d in [train_person_dir, val_person_dir, test_person_dir]:
                d.mkdir(exist_ok=True)
            
            # Get all image files for this person
            image_files = list(person_dir.glob("*.jpg")) + \
                         list(person_dir.glob("*.png")) + \
                         list(person_dir.glob("*.jpeg"))
            
            # Limit the number of images if max_samples_per_class is set
            if max_samples_per_class is not None:
                image_files = image_files[:max_samples_per_class]
            
            # Split into train/val/test
            train_ratio, val_ratio = 0.7, 0.15
            
            train_size = int(len(image_files) * train_ratio)
            val_size = int(len(image_files) * val_ratio)
            
            train_files = image_files[:train_size]
            val_files = image_files[train_size:train_size + val_size]
            test_files = image_files[train_size + val_size:]
            
            # Process and save images
            for img_path in train_files:
                processed_img = preprocess_image(str(img_path), config)
                if processed_img is not None:
                    save_path = train_person_dir / f"{img_path.stem}.jpg"
                    processed_img.save(str(save_path))
            
            for img_path in val_files:
                processed_img = preprocess_image(str(img_path), config)
                if processed_img is not None:
                    save_path = val_person_dir / f"{img_path.stem}.jpg"
                    processed_img.save(str(save_path))
            
            for img_path in test_files:
                processed_img = preprocess_image(str(img_path), config)
                if processed_img is not None:
                    save_path = test_person_dir / f"{img_path.stem}.jpg"
                    processed_img.save(str(save_path))
            
            # Apply augmentation to training set if enabled and there are few images
            if config.augmentation and len(train_files) < 20:
                # Get existing processed images
                processed_train_files = list(train_person_dir.glob("*.jpg"))
                
                # Apply augmentation
                transform = A.Compose([
                    A.Rotate(limit=config.aug_rotation_range, p=0.7),
                    A.RandomBrightnessContrast(
                        brightness_limit=config.aug_brightness_range,
                        contrast_limit=config.aug_contrast_range,
                        p=0.7
                    ),
                    A.RandomScale(scale_limit=config.aug_scale_range, p=0.5),
                    A.HorizontalFlip(p=0.5 if config.horizontal_flip else 0),
                ])
                
                for idx, img_path in enumerate(processed_train_files):
                    # Only augment a subset of images
                    if idx >= min(10, len(processed_train_files)):
                        break
                    
                    # Load image
                    img = Image.open(img_path)
                    img_array = np.array(img)
                    
                    # Create 5 augmented versions
                    for aug_idx in range(5):
                        augmented = transform(image=img_array)
                        aug_img = Image.fromarray(augmented['image'])
                        
                        # Save augmented image
                        aug_path = train_person_dir / f"{img_path.stem}_aug{aug_idx}{img_path.suffix}"
                        aug_img.save(str(aug_path))


def get_preprocessing_config() -> PreprocessingConfig:
    """Get default preprocessing configuration."""
    return PreprocessingConfig(
        name="default",
        use_mtcnn=True,
        face_margin=0.4,
        final_size=(224, 224),
        augmentation=True
    )

