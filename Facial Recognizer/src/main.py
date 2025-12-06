"""Main entry point for face recognition system."""
#!/usr/bin/env python3

import argparse
import sys
import torch
from pathlib import Path

from .base_config import CHECKPOINTS_DIR
from .data_prep import get_preprocessing_config, process_raw_data
from .training import train_model
from .testing import evaluate_model, predict_image
from .base_config import RAW_DATA_DIR, PROC_DATA_DIR


def main():
    """Main entry point for face recognition system."""
    parser = argparse.ArgumentParser(description='Face Recognition System')
    subparsers = parser.add_subparsers(dest='cmd', help='Command to run')
    
    # Define all subcommands
    subparsers.add_parser('interactive', help='Run the interactive menu interface')
    subparsers.add_parser('demo', help='Run live demo app')
    subparsers.add_parser('cv', help='Run cross-validation')
    subparsers.add_parser('hyperopt', help='Run hyperparameter tuning')
    
    # Preprocess command
    preproc = subparsers.add_parser('preprocess', help='Preprocess raw data')
    preproc.add_argument('--test', action='store_true', help='Run in test mode with limited data')
    
    # Train command
    train_p = subparsers.add_parser('train', help='Train a model')
    train_p.add_argument('--model-type', type=str, required=True,
                        choices=['baseline', 'cnn', 'siamese', 'attention', 'arcface', 'hybrid', 'ensemble'],
                        help='Type of model to train')
    train_p.add_argument('--model-name', type=str, help='Name for the trained model')
    train_p.add_argument('--dataset-path', type=str, help='Path to processed dataset')
    train_p.add_argument('--batch-size', type=int, default=32, help='Batch size for training')
    train_p.add_argument('--epochs', type=int, default=50, help='Number of epochs')
    train_p.add_argument('--lr', type=float, default=0.001, help='Learning rate')
    train_p.add_argument('--weight-decay', type=float, default=1e-4, help='Weight decay')
    
    # Evaluate command
    eval_p = subparsers.add_parser('evaluate', help='Evaluate a model')
    eval_p.add_argument('--model-type', type=str, required=True,
                       choices=['baseline', 'cnn', 'siamese', 'attention', 'arcface', 'hybrid', 'ensemble'],
                       help='Type of model to evaluate')
    eval_p.add_argument('--model-name', type=str, help='Name of the model to evaluate')
    eval_p.add_argument('--dataset-path', type=str, help='Path to processed dataset')
    
    # Predict command
    pred_p = subparsers.add_parser('predict', help='Predict on a single image')
    pred_p.add_argument('--model-type', type=str, required=True,
                       choices=['baseline', 'cnn', 'attention', 'arcface', 'hybrid', 'ensemble'],
                       help='Type of model to use (not siamese)')
    pred_p.add_argument('--model-name', type=str, help='Name of the model to use')
    pred_p.add_argument('--image-path', type=str, required=True, help='Path to the image to predict')
    
    # Utility commands
    subparsers.add_parser('check-gpu', help='Check GPU availability')
    subparsers.add_parser('list-models', help='List available trained models')
    
    args = parser.parse_args()
    
    # Show help if no command is provided
    if args.cmd is None:
        parser.print_help()
        return 1
    
    # Process commands
    if args.cmd == 'interactive':
        try:
            from .interactive import interactive_menu
            return interactive_menu()
        except ImportError:
            print("Interactive menu not available. Install required dependencies.")
            return 1
    
    elif args.cmd == 'demo':
        try:
            from .app import main as run_app
            return run_app()
        except ImportError:
            print("Demo app not available. Install required dependencies.")
            return 1
    
    elif args.cmd == 'cv':
        try:
            from .cross_validation import run_cross_validation
            run_cross_validation()
        except ImportError:
            print("Cross-validation not available. Install required dependencies.")
            return 1
    
    elif args.cmd == 'hyperopt':
        try:
            from .hyperparameter_tuning import run_hyperparameter_tuning
            # This would need additional arguments in a real implementation
            print("Hyperparameter tuning requires additional configuration.")
            print("Please use the interactive menu or configure directly.")
        except ImportError as e:
            print(f"Hyperparameter tuning not available: {e}")
            return 1
    
    elif args.cmd == 'preprocess':
        config = get_preprocessing_config()
        process_raw_data(RAW_DATA_DIR, PROC_DATA_DIR, config=config, test_mode=args.test)
        return 0
    
    elif args.cmd == 'train':
        dataset_path = Path(args.dataset_path) if args.dataset_path else PROC_DATA_DIR
        if not dataset_path.exists():
            print(f"Dataset path does not exist: {dataset_path}")
            return 1
        
        result = train_model(
            model_type=args.model_type,
            dataset_path=dataset_path,
            model_name=args.model_name,
            batch_size=args.batch_size,
            epochs=args.epochs,
            lr=args.lr,
            weight_decay=args.weight_decay
        )
        print(f"Training completed. Model saved to: {result['checkpoint_dir']}")
        return 0
    
    elif args.cmd == 'evaluate':
        dataset_path = Path(args.dataset_path) if args.dataset_path else PROC_DATA_DIR
        if not dataset_path.exists():
            print(f"Dataset path does not exist: {dataset_path}")
            return 1
        
        metrics = evaluate_model(
            model_type=args.model_type,
            model_name=args.model_name,
            dataset_path=dataset_path
        )
        print(f"Evaluation completed. Accuracy: {metrics['accuracy']:.4f}")
        return 0
    
    elif args.cmd == 'predict':
        if not Path(args.image_path).exists():
            print(f"Image path does not exist: {args.image_path}")
            return 1
        
        class_name, confidence = predict_image(
            model_type=args.model_type,
            image_path=args.image_path,
            model_name=args.model_name
        )
        print(f"Predicted class: {class_name} (confidence: {confidence:.4f})")
        return 0
    
    elif args.cmd == 'check-gpu':
        from .base_config import check_gpu
        check_gpu()
        return 0
    
    elif args.cmd == 'list-models':
        model_dirs = list(CHECKPOINTS_DIR.glob('*'))
        if not model_dirs:
            print("No trained models found.")
        else:
            print("Available models:")
            for model_dir in sorted(model_dirs):
                print(f"  - {model_dir.name}")
        return 0
    
    return 0


if __name__ == '__main__':
    sys.exit(main())

