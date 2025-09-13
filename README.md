# 🔔 Smart Doorbell System

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-ESP32-green.svg)](https://www.espressif.com/en/products/socs/esp32)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore-orange.svg)](https://firebase.google.com)

> **An intelligent IoT-enabled doorbell system that revolutionizes home security through real-time visitor monitoring, cloud-based image storage, and instant mobile notifications.**

---

## 📖 Table of Contents

- [🎯 Project Overview](#-project-overview)
- [✨ Key Features](#-key-features)
- [🏗️ System Architecture](#️-system-architecture)
- [🛠️ Technology Stack](#️-technology-stack)
- [📋 Prerequisites](#-prerequisites)
- [🚀 Installation Guide](#-installation-guide)
- [💡 Usage Instructions](#-usage-instructions)
- [📱 Mobile Application](#-mobile-application)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)


---

## 🎯 Project Overview

The Smart Doorbell System represents a cutting-edge approach to residential security monitoring. This comprehensive IoT solution seamlessly integrates hardware sensors, cloud infrastructure, and mobile applications to provide homeowners with real-time visitor awareness and historical activity tracking.

**Core Functionality:**  
When a visitor activates the doorbell mechanism, the system executes a sophisticated workflow:  
- Image capture via ESP32-CAM  
- Secure cloud storage through Cloudinary  
- Database logging in Firebase Firestore  
- Instant push notification delivery to registered mobile devices

---

## ✨ Key Features

- **🎥 Advanced Image Capture**
  - High-resolution visitor photography using ESP32-CAM module
  - Automatic triggering upon doorbell activation
  - Optimized image processing for various lighting conditions

- **☁️ Cloud Infrastructure**
  - Secure image storage via Cloudinary CDN
  - Real-time database synchronization with Firebase Firestore
  - Scalable architecture supporting multiple device registrations

- **📲 Instant Notifications**
  - Firebase Cloud Messaging (FCM) integration
  - Cross-platform push notifications (iOS & Android)
  - Real-time visitor alerts with contextual information

- **📱 Mobile Application**
  - Native Flutter application (DoorSnap)
  - Comprehensive visitor history and analytics
  - Intuitive user interface with responsive design
  - Offline capability with data synchronization

- **🔒 Security & Privacy**
  - Encrypted data transmission
  - Secure API key management
  - GDPR-compliant data handling practices

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


**Data Flow Architecture**

- **Hardware Layer:** ESP32-CAM module handles sensor input and image acquisition
- **Cloud Storage Layer:** Cloudinary manages image hosting and CDN distribution
- **Database Layer:** Firebase Firestore maintains visitor logs and device metadata
- **Notification Layer:** Python service orchestrates real-time messaging via FCM
- **Application Layer:** Flutter mobile application provides user interface and experience

---

## 🛠️ Technology Stack

- **Hardware Components**
  - ESP32-CAM: Microcontroller with integrated camera & Wi-Fi
  - Push Button: Visitor activation mechanism
  - Power Supply: Stable voltage regulation

- **Backend Services**
  - Firebase Firestore: NoSQL visitor event logging
  - Firebase Cloud Messaging: Push notifications
  - Cloudinary API: Image storage & CDN
  - Python Runtime: Notification orchestration

- **Mobile Development**
  - Flutter Framework & Dart Language
  - Firebase SDK integration

- **Development Tools**
  - Arduino IDE: ESP32 firmware development
  - Replit: Python hosting
  - Git: Version control

---

## 📋 Prerequisites

**Hardware Requirements**
- ESP32-CAM development board
- Micro-USB cable
- Stable Wi-Fi network
- 5V power supply

**Software Requirements**
- Arduino IDE (v1.8.19+)
- Flutter SDK (v3.0.0+)
- Python 3.8+
- Git

**Cloud Service Accounts**
- Firebase project (Firestore & FCM)
- Cloudinary account
- Replit account

---

## 🚀 Installation Guide

**Step 1: Repository Setup**

git clone https://github.com/nyxparadox/smart-doorbell-system.git\
cd smart-doorbell-system


**Step 2: Hardware Configuration**

// Configure Wi-Fi credentials in ESP32 code\
const char* ssid = "YOUR_WIFI_NETWORK";\
const char* password = "YOUR_WIFI_PASSWORD";

- Connect ESP32-CAM via USB, open Arduino IDE, load `/esp32/doorbell_camera.ino`
- Install libraries: ESP32Cam, WiFi, HTTPClient
- Upload firmware to ESP32-CAM

**Step 3: Firebase Project Setup**
- Go to [Firebase Console](https://console.firebase.google.com/)
- Enable Firestore and set up visitors collection:

```
visitors/
├── deviceId (string)
├── imageUrl (string)
├── timestamp (timestamp)
└── location (string, optional)

```

- Enable Cloud Messaging, download config files

**Step 4: Cloudinary Configuration**
- [Cloudinary Sign Up](https://cloudinary.com/)
- Add ESP32 Cloudinary parameters:

const String cloudinaryCloudName = "your_cloud_name";\
const String cloudinaryApiKey = "your_api_key";\
const String cloudinaryApiSecret = "your_api_secret";


**Step 5: Server Deployment**
- Create Replit project, upload `/server/notification_service.py`
- Install dependencies:
pip install firebase-admin requests python-dotenv

- Configure environment variables & start service

**Step 6: Mobile App Setup**\
```
cd flutter_app/doorsnap\
flutter pub get
```

Add firebase_options.dart to lib\
```
flutter run
```


---

## 💡 Usage Instructions

**Initial Setup**
- Power on ESP32-CAM
- Verify Wi-Fi via serial monitor
- Launch DoorSnap app, complete registration

**Daily Operation**
- Guest presses doorbell
- System captures photograph
- Push notification received
- View activity & history in DoorSnap




## 🤝 Contributing

We welcome contributions!  
**Development Workflow**
1. Fork the repo
2. Create a branch: `git checkout -b feature/amazing-feature`
3. Commit with messages: `git commit -m 'Add amazing feature'`
4. Push: `git push origin feature/amazing-feature`
5. Submit Pull Request

**Code Standards**
- Follow style guides (PEP 8, Effective Dart)
- Document features clearly
- Add unit tests
- Ensure backward compatibility

**Issue Reporting**
- Use GitHub Issues
- Include description, reproduction steps, expected/actual, and environment details

---

## 📄 License

This project is licensed under the MIT License \

MIT License

Copyright (c) 2025 Smart Doorbell System Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files...



