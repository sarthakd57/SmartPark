import cv2
from roboflow import Roboflow
import json
from dotenv import load_dotenv
import os

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '..', '.env'))
# Roboflow details from your link
API_KEY = os.getenv('ROBOFLOW_KEY')  # Get this from your Roboflow account (https://app.roboflow.com/settings/api)
WORKSPACE = "muhammad-syihab-bdynf"
PROJECT = "parking-space-ipm1b"
VERSION = 1  # Assuming version 1; check the model page for the latest version

rf = Roboflow(api_key=API_KEY)
project = rf.workspace(WORKSPACE).project(PROJECT)
model = project.version(VERSION).model

def detect_parking_spots(image_path, lot_id):
    # Run inference on image
    result = model.predict(image_path).json()
    
    # Extract detections (adjust 'class' based on your model's labels, e.g., 'occupied', 'car', or 'parking_space')
    # Assuming the model detects 'occupied' for taken spots; check Roboflow for exact class names
    detections = []
    for prediction in result['predictions']:
        if prediction['class'] in ['occupied', 'car']:  # Adjust as needed
            detections.append({
                'x1': prediction['x'],
                'y1': prediction['y'],
                'x2': prediction['x'] + prediction['width'],
                'y2': prediction['y'] + prediction['height'],
                'confidence': prediction['confidence']
            })
    
    # Count occupied spots and update availability
    occupied_count = len(detections)
    # Add logic to update DB (e.g., call updateAvailability(lot_id, occupied_count))
    return {'detections': detections, 'occupied_count': occupied_count}