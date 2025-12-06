"""Streamlit app for live face recognition demo."""
try:
    import streamlit as st
    import cv2
    import numpy as np
    from PIL import Image
    import torch
    from pathlib import Path
    
    from .face_models import get_model
    from .base_config import CHECKPOINTS_DIR, PROC_DATA_DIR
    from .testing import predict_image
except ImportError as e:
    print(f"Required dependencies not installed: {e}")
    print("Please install: streamlit, opencv-python")


def main():
    """Main function for Streamlit app."""
    try:
        st.title("Face Recognition Demo")
        st.write("Upload an image or use webcam for face recognition")
        
        # Model selection
        model_type = st.sidebar.selectbox(
            "Select Model",
            ['baseline', 'cnn', 'attention', 'arcface', 'hybrid']
        )
        
        # Image input
        input_method = st.radio("Input Method", ["Upload Image", "Webcam"])
        
        if input_method == "Upload Image":
            uploaded_file = st.file_uploader("Choose an image...", type=['jpg', 'jpeg', 'png'])
            if uploaded_file is not None:
                image = Image.open(uploaded_file)
                st.image(image, caption='Uploaded Image', use_container_width=True)
                
                if st.button("Predict"):
                    # Save uploaded image temporarily
                    temp_path = Path("temp_image.jpg")
                    image.save(str(temp_path))
                    
                    try:
                        class_name, confidence = predict_image(
                            model_type=model_type,
                            image_path=str(temp_path)
                        )
                        st.success(f"Predicted: **{class_name}** (confidence: {confidence:.4f})")
                    except Exception as e:
                        st.error(f"Error during prediction: {e}")
                    finally:
                        if temp_path.exists():
                            temp_path.unlink()
        
        else:  # Webcam
            st.write("Webcam feature requires additional setup")
            st.info("Please use the upload image option for now")
    
    except ImportError:
        st.error("Streamlit or other dependencies not installed. Please install required packages.")
        st.code("pip install streamlit opencv-python")


if __name__ == '__main__':
    main()

