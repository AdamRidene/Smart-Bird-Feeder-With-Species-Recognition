#!/bin/bash


VENV_PYTHON="/home/domm/smart_bird_feeder/packages/bin/python"


AI_DIR="/home/domm/smart_bird_feeder/ai_model/bird_object_detection"

echo ">>> Smart Bird Feeder System Started"


cd "$AI_DIR" || { echo "Error: Could not find directory $AI_DIR"; exit 1; }

while true; do
    echo "------------------------------------------"
    echo ">>> [Mode 1] Listening for Motion..."
    
    
    "$VENV_PYTHON" usb_reader.py
    
    echo ">>> Motion Triggered! Switching to AI Vision..."
    
    
    "$VENV_PYTHON" inference_after_getting_video_stream.py
    
    echo ">>> AI finished. Restarting listener..."
done

