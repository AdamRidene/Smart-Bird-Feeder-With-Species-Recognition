import serial
import time
import sys


# The ESP32 with the PIR sensor
PIR_PORT = '/dev/ttyUSB0' 
# The ESP-EYE Camera
EYE_PORT = '/dev/ttyUSB1' 

def wake_up_camera():
    try:
        # Open connection to ESP-EYE
        with serial.Serial(EYE_PORT, 115200, timeout=1) as ser_eye:
            print(f"Sending START command to ESP-EYE on {EYE_PORT}...")
            ser_eye.write(b"START\n")
            time.sleep(1) 
    except Exception as e:
        print(f"Failed to wake camera: {e}")

try:
    ser_pir = serial.Serial(PIR_PORT, 115200, timeout=1)
    ser_pir.reset_input_buffer()
    print("Listening for motion on ESP32...")
except Exception as e:
    print(f"Error connecting to PIR ESP32: {e}")
    sys.exit(1)

while True:
    try:
        if ser_pir.in_waiting > 0:
            line = ser_pir.readline().decode('utf-8', errors='ignore').strip()
            
            if "Motion detected" in line:
                print(">>> Motion Detected!")
                
                # 1. Wake up the ESP-EYE
                wake_up_camera()
                
                
                sys.exit(0) 
                
    except KeyboardInterrupt:
        break