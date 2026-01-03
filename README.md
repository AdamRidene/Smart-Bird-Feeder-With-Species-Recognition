# Smart-Bird-Feeder-With-Species-Recognition

This project is developed during Labs of the subject IoT Architecture By:

Adam Ridene

Rayen Landolsi

Under-graduated students,

Embedded system and IoT Bachelors

Under the supervision of:

Hanen KARAMTI,

Computer Science, Assistant Professor,

Higher Institute of Multimedia Arts of Manouba (ISAMM),

University of Manouba Tunisia

Project title:
Smart Bird Feeder with Species Recognition

`Description`:

The Smart Bird Feeder is an intelligent, IoT-based environmental monitoring system designed for "Smart Agriculture". It combines a connected bird feeder with embedded artificial intelligence to detect, identify, and collect data on local bird populations. The system captures images or videos upon detecting motion, uses computer vision to identify the species, and sends real-time notifications to a mobile application. All observations are logged into a personal digital "ornithological book" for the user to consult.


Problem statement and objectives:

`Problem Statement`: 

The project addresses the challenge of designing an intelligent, autonomous system capable of identifying bird species at a feeder while:
* Collecting reliable, connected data.
* Minimizing overall hardware and operational costs.
* Operating independently in an outdoor environment.
`Objectives`:

### 1. Automated Monitoring
Design an IoT system that monitors a feeder and identifies species via artificial vision.

### 2. Presence Detection
Define a connected object that uses motion (**PIR**), infrared, and camera sensors to detect visitors effectively.

### 3. Cloud Integration
Use cloud technologies  for:
* Remote data storage.
* Real-time visualization.
* Mobile synchronization.

Requirements (both hardware and software) 

### 1. Hardware Requirements
* **Microcontroller:** ESP32
* **Sensors:** * HC-SR501 PIR Motion Sensor (Motion detection).
    * Ultrasonic sensor.
* **Storage:** Micro SD Card (Local backup).
* **Edge Computing Device**: Raspberry Pi.
* **Video Streaming**: ESP-EYE.


### 2. Software & Platforms
* **Firmware:** Arduino IDE .
* **Cloud:** Supabase(Authentification , Storage).
* **AI/ML:** YOLO Model (optimized using NCNN) , Google Colab for Model Training.
* **Mobile App:** Dart Language (Flutter as a Framework)
* **Scripts Automation**: Shell 

### 3. Datasets
* **Bird Species Dataset:** Dataset extracted from Roboflow.

Instructions for equipment installation:
