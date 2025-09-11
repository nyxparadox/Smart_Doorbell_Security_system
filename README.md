# Smart Doorbell System

A modern, IoT-powered smart doorbell that captures visitor photos, uploads them to the cloud, and delivers real-time notifications via a mobile app. Built using ESP32-CAM hardware, Firebase backend services, and a cross-platform Flutter app.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Technologies Used](#technologies-used)
- [Setup & Installation](#setup--installation)
- [Usage](#usage)
- [Contributing](#contributing)


---

## Overview

The Smart Doorbell System enhances home security by capturing images of visitors and delivering instant notifications to your mobile device. When a visitor presses the doorbell button, the ESP32-CAM module takes a photo, uploads it to Cloudinary for secure storage, and logs the event in Firebase Firestore. A Python script (hosted on Replit) monitors the database and sends push notifications via Firebase Cloud Messaging (FCM). The DoorSnap mobile app, built with Flutter, displays real-time visitor logs and images.

---

## Features

- **Real-Time Visitor Capture:** Photo taken instantly when the doorbell button is pressed.
- **Cloud Image Storage:** Securely uploads images to Cloudinary and provides shareable URLs.
- **Database Logging:** Stores visitor details (device ID, image URL, timestamp) in Firestore.
- **Push Notifications:** Delivers instant FCM notifications to registered mobile devices.
- **Mobile App Integration:** View visitor photos, timestamps, and logs in real-time (iOS & Android).
- **Scalability:** Easily integrates with smart home ecosystems.

---

## Architecture

1. **Visitor presses the doorbell.**
2. **ESP32-CAM captures a photo.**
3. **Image is uploaded to Cloudinary; shareable URL is generated.**
4. **Visitor event is logged in Firestore with deviceId, imageUrl, and timestamp.**
5. **A Python script (Replit) listens for new Firestore entries and sends push notifications via FCM.**
6. **DoorSnap mobile app receives notifications and updates UI with visitor details.**

![System Diagram](https://res.cloudinary.com/dytuvjwqu/image/upload/v1757610011/Smart_Doorbell_System_flow_chart_1_zkiszb.png)

---

## Technologies Used

- **Hardware:** ESP32-CAM (Wi-Fi enabled)
- **Backend:** Firebase Firestore, Firebase Cloud Messaging (FCM)
- **Cloud Storage:** Cloudinary API
- **Mobile App:** Flutter (iOS & Android)
- **Backend Script:** Python (Firebase Admin SDK) on Replit
- **Connectivity:** Wi-Fi router

---

## Setup & Installation

### Prerequisites

- ESP32-CAM board
- Firebase project (Firestore & FCM enabled)
- Cloudinary account with API credentials
- Replit account (for hosting Python script)
- Flutter SDK (for mobile app development)

### Steps

1. **Clone the Repository**
git clone https://github.com/nyxparadox/Smart_Doorbell_Security_system.git
cd smart-doorbell-system


2. **Hardware Setup**
- Connect ESP32-CAM to Wi-Fi.
- Program it with code from `/esp32` (handles button, camera, upload).

3. **Configure Firebase**
- Create a Firebase project.
- Enable Firestore (`visitors` collection) & FCM.
- Download service account credentials.
- Update configs in Python script & Flutter app.

4. **Configure Cloudinary**
- Obtain API keys from Cloudinary account.
- Add credentials to ESP32 code.

5. **Set up Server (Replit)**
- Upload `/server/notifier.py` to Replit.
- Install dependencies (`firebase-admin`, `requests`, etc.).
- Run script.

6. **Mobile App (Flutter)**
- In `/app`, run:
  ```
  flutter pub get
  ```
- Add Firebase config (`lib/firebase_options.dart`).
- Build & run:
  ```
  flutter run
  ```

Check subdirectory README files for more details.

---

## Usage

1. **Press the doorbell button.**
2. **Receive a real-time notification on your mobile device.**
3. **Open DoorSnap app to view visitor photo, timestamp, and history.**

---

## Contributing

- Fork the repository
- Create a new branch (`git checkout -b feature/YourFeature`)
- Commit changes (`git commit -m 'Add YourFeature'`)
- Push (`git push origin feature/YourFeature`)
- Open a Pull Request

All contributions and issues welcome! See `CONTRIBUTING.md` for guidelines.

---




