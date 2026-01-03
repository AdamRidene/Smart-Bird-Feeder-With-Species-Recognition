from ultralytics import YOLO
import time
import cv2 as cv
import sys
import os
import socket
import threading
from numba import njit
from supabase import create_client
import datetime
@njit(cache=True)
def get_cropped_image_coords(box,frame_shape):
    x_min, y_min, x_max, y_max = box[0], box[1], box[2], box[3]
    x_min_int = int(x_min)
    y_min_int = int(y_min)
    x_max_int = int(x_max)
    y_max_int = int(y_max)
    h, w, _ = frame_shape
    x_min_int = max(0, x_min_int)
    y_min_int = max(0, y_min_int)
    x_max_int = min(w, x_max_int)
    y_max_int = min(h, y_max_int)
    
    return x_min_int, y_min_int, x_max_int, y_max_int

def get_ip_from_hostname(hostname):
    """Resolves hostname.local to an IP address."""
    print(f"Looking for {hostname}...")
    try:
        ip = socket.gethostbyname(hostname)
        print(f"Found {hostname} at {ip}")
        return ip
    except socket.gaierror:
        print(f"Error: Could not resolve {hostname}")
        return None


def upload_worker(supabase_client, bucket_name, file_bytes, filename):
    """
    Background function to upload image.
    This runs in a separate thread so it doesn't stop the video.
    """
    try:
        print(f"Uploading {filename} in background...")
        supabase_client.storage.from_(bucket_name).upload(
            path=filename,
            file=file_bytes,
            file_options={"content-type": "image/jpeg"}
        )
        print(f"Upload success: {filename}")
    except Exception as e:
        print(f"Upload failed: {e}")





ESP_HOSTNAME = "espeye.local"
PORT = 81
STREAM_PATH = "/stream"
BUCKET_NAME = "birds"
INACTIVITY_LIMIT = 30


url=""
key=""
supabase=create_client(url,key)


last_upload_time = 0
upload_cooldown_seconds = 25

ip = get_ip_from_hostname(ESP_HOSTNAME)
if not ip:
    print("ESP-EYE not found via mDNS.")
    manual_ip = input("Enter ESP-EYE IP manually (or press Enter to use Webcam): ")
    if manual_ip:
        stream_url = f"http://{manual_ip}:{PORT}{STREAM_PATH}"
    else:
        stream_url = 0 
else:
    stream_url = f"http://{ip}:{PORT}{STREAM_PATH}"



try:
    buckets = supabase.storage.list_buckets()
    print("Available buckets:", [bucket.name for bucket in buckets])
    bird_bucket = supabase.storage.from_("birds")
    print(bird_bucket)
except Exception as e:
    print(f"Error connecting to Supabase or listing buckets: {e}")
    sys.exit()


if not os.path.exists("best.pt"):
    print("Error: best.pt model file not found!")
    sys.exit()


model = YOLO("best.pt")
ncnn_model_path = "best_ncnn_model"
if not os.path.exists(ncnn_model_path):
    print("Exporting model to NCNN format...")
    model.export(format="ncnn")
    print("Export complete!")
else:
    print("NCNN model already exists, skipping export...")



ncnn_model = YOLO(ncnn_model_path,task="detect")
cap = cv.VideoCapture(stream_url)
if not cap.isOpened():
    print("Error: Could not open camera 0, trying camera 1...")
    cap = cv.VideoCapture(1)
    if not cap.isOpened():
        print("Error: Could not open any video capture device.")
        sys.exit()
cap.set(cv.CAP_PROP_FRAME_WIDTH, 640)
cap.set(cv.CAP_PROP_FRAME_HEIGHT, 480)
cap.set(cv.CAP_PROP_FPS, 30)
print("Starting detection... Press 'q' to quit")


last_detection_time = time.time()

try:
    while True:
        ret, frame = cap.read()
        if not ret:
            print("Error: Failed to grab frame or end of stream.")
            break
        results = ncnn_model.predict(
            frame,
            verbose=False,
            conf=0.65,  
            iou=0.45 
        )
        result = results[0]
        original_frame=frame.copy();
        # Annotate frame
        annotated_frame = result.plot()
        if result.boxes:
                last_detection_time = time.time()
                print(f"Detected {len(result.boxes)} objects") 
                print(result.boxes.data)
                current_time = time.time()
                if current_time - last_upload_time > upload_cooldown_seconds:
                    print("Cooldown Ready. Processing detection...")
                    boxes_coords = result.boxes.xyxy.cpu().numpy()
                    classes_ids = result.boxes.cls.cpu().numpy()
                    for box, cls_id in zip(boxes_coords, classes_ids):
                        x_min, y_min, x_max, y_max = get_cropped_image_coords(box,original_frame.shape)
                        if x_max > x_min and y_max > y_min:
                            cropped_image = original_frame[y_min:y_max, x_min:x_max]
                            success_crop, encoded_cropped_image = cv.imencode(".jpg", cropped_image)
                            if success_crop:
                                bird_name = result.names[int(cls_id)]
                                print("Image rognée encodée en mémoire, prête pour l'upload.")
                                timestamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
                                filename = f"{bird_name}.jpg"
                                file_bytes = encoded_cropped_image.tobytes()
                                t = threading.Thread(
                                target=upload_worker, 
                                args=(supabase, BUCKET_NAME, file_bytes, filename)
                                )
                                t.start()
                                last_upload_time = current_time
                                break
        if time.time() - last_detection_time > INACTIVITY_LIMIT:
            print(f"No activity for {INACTIVITY_LIMIT} seconds. Exiting to save power...")
            break       
        cv.imshow("NCNN Model Detection", annotated_frame)
        key = cv.waitKey(1) & 0xFF
        if key == ord('q') or key == 27:
            break
except KeyboardInterrupt:
    print("\nInterrupted by user")
finally:
    print("Releasing resources...")
    cap.release()
    cv.destroyAllWindows()