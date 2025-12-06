"""Interactive command-line interface for face recognition system."""
from pathlib import Path
from .base_config import RAW_DATA_DIR, PROC_DATA_DIR, CHECKPOINTS_DIR
from .data_prep import get_preprocessing_config, process_raw_data
from .training import train_model
from .testing import evaluate_model, predict_image
from .hyperparameter_tuning import run_hyperparameter_tuning


def interactive_menu():
    """Interactive menu interface."""
    print("="*60)
    print("Face Recognition System - Interactive Menu")
    print("="*60)
    
    while True:
        print("\nOptions:")
        print("1. Preprocess data")
        print("2. Train model")
        print("3. Evaluate model")
        print("4. Predict on image")
        print("5. Run hyperparameter tuning")
        print("6. Run cross-validation")
        print("7. Exit")
        
        choice = input("\nEnter your choice (1-7): ").strip()
        
        if choice == '1':
            print("\nPreprocessing data...")
            config = get_preprocessing_config()
            test_mode = input("Run in test mode? (y/n): ").lower() == 'y'
            process_raw_data(RAW_DATA_DIR, PROC_DATA_DIR, config=config, test_mode=test_mode)
            print("Preprocessing completed!")
        
        elif choice == '2':
            print("\nTraining model...")
            model_type = input("Model type (baseline/cnn/siamese/attention/arcface/hybrid): ").strip()
            dataset_path = input(f"Dataset path (default: {PROC_DATA_DIR}): ").strip()
            dataset_path = Path(dataset_path) if dataset_path else PROC_DATA_DIR
            
            if not dataset_path.exists():
                print(f"Dataset path does not exist: {dataset_path}")
                continue
            
            batch_size = int(input("Batch size (default: 32): ").strip() or "32")
            epochs = int(input("Epochs (default: 50): ").strip() or "50")
            lr = float(input("Learning rate (default: 0.001): ").strip() or "0.001")
            
            result = train_model(
                model_type=model_type,
                dataset_path=dataset_path,
                batch_size=batch_size,
                epochs=epochs,
                lr=lr
            )
            print(f"Training completed! Model saved to: {result['checkpoint_dir']}")
        
        elif choice == '3':
            print("\nEvaluating model...")
            model_type = input("Model type: ").strip()
            model_name = input("Model name (leave empty for latest): ").strip() or None
            dataset_path = input(f"Dataset path (default: {PROC_DATA_DIR}): ").strip()
            dataset_path = Path(dataset_path) if dataset_path else PROC_DATA_DIR
            
            metrics = evaluate_model(
                model_type=model_type,
                model_name=model_name,
                dataset_path=dataset_path
            )
            print(f"\nEvaluation Results:")
            print(f"Accuracy: {metrics['accuracy']:.4f}")
            print(f"F1 Score: {metrics['f1']:.4f}")
        
        elif choice == '4':
            print("\nPredicting on image...")
            model_type = input("Model type: ").strip()
            image_path = input("Image path: ").strip()
            
            if not Path(image_path).exists():
                print(f"Image not found: {image_path}")
                continue
            
            class_name, confidence = predict_image(
                model_type=model_type,
                image_path=image_path
            )
            print(f"\nPrediction: {class_name} (confidence: {confidence:.4f})")
        
        elif choice == '5':
            print("\nHyperparameter tuning...")
            print("This feature requires additional configuration.")
            print("Please configure hyperparameter_tuning.py directly.")
        
        elif choice == '6':
            print("\nCross-validation...")
            print("This feature requires additional configuration.")
            print("Please configure cross_validation.py directly.")
        
        elif choice == '7':
            print("Exiting...")
            break
        
        else:
            print("Invalid choice. Please try again.")
    
    return 0

