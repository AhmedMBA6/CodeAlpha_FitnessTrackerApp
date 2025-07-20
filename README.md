# 💪 FitSync – Intelligent Fitness Tracker App

**FitSync** is a cleanly architected, offline-first, cross-platform **fitness tracker app** built using Flutter. It empowers users to log activities, set and track customized fitness goals, and analyze progress over time using beautiful charts and summaries.

This app was developed as part of the **CodeAlpha App Development Internship**, showcasing a scalable real-world architecture, smart design, and extensible roadmap.

---

## 🚀 Overview

FitSync helps users:
- Track workouts, calories, durations, and tags
- Link activities to goals with many-to-many flexibility
- Visualize weekly progress in charts and summaries
- Authenticate securely via Firebase
- Store data offline via SQLite
- Prepare for future enhancements like **AI**, **GPS route tracking**, and **cloud syncing**

---

## ✨ Features

### 🔐 Authentication
- Firebase email/password login & logout
- Secure and persistent auth state

### 🏃 Activity Logging
- Create and edit workout logs
- Add duration, calories, type, notes, and tags
- Live timer support (pause/resume/finish)
- Offline-first storage with SQLite

### 🎯 Goal Management
- Set custom goals (e.g., burn 500 cal, train trapezius)
- Link goals to one or more activities
- Track completion progress in real-time
- Use smart goal templates for quick setup

### 📊 Interactive Dashboard
- View weekly and daily summaries
- Pie chart for activity type contribution
- Line chart for workout duration trends
- Completion rings for goal progress
- Smart filters and date range controls

### 💾 Local Data Persistence
- Fast, reliable SQLite storage
- Works offline; no data loss between sessions

### 🌐 Ready for International Use
- App supports English, Spanish, French (expandable)


---

## 🧱 Folder Structure

```bash
lib/
├── core/                   # Global services, DB, theme, utils
├── features/
│   ├── auth/               # Firebase login logic
│   ├── activity_log/       # Logging, tracking, linking
│   ├── activity_goals/     # Goal creation, tracking, progress
│   ├── dashboard/          # Charts, summaries, filters
│   ├── home/               # Overview & quick actions
│   └── user_profile/       # Profile editing
├── shared/                 # Common widgets, inputs, UI
└── main.dart               # App entry point
```

---

🧠 Built With Clean Architecture
Cubit/Bloc for reactive state management

Repository Pattern for database abstraction

Modular Feature Folders: Each screen self-contained

Custom SQLHelper class for managing database operations

---

🔮 Future Enhancements
FitSync is designed to scale. Here’s what’s coming next:

🗺️ GPS Route Tracking
View your walking, running, or cycling path on a live map with direction overlays

🧠 AI Goal Intelligence
Use machine learning to auto-classify exercises and suggest relevant goals

📊 Goal Insights & Trends
View personalized stats like most logged time of day, most targeted muscle groups

☁️ Cloud Sync
Sync across devices using Firebase Firestore or Supabase

🧪 Unit + Widget Testing
Test coverage expansion across form logic, sync behavior, and DB layer

📱 iOS + Android Publishing
App Store/Play Store readiness with CI/CD 
---

🧪 Local Setup Instructions
Prerequisites
Flutter SDK

Firebase project with email/password authentication enabled

FlutterFire CLI configured (for Android/iOS)
---


# Clone the repo
git clone https://github.com/yourusername/fitsync.git
cd fitsync

# Install dependencies
fvm flutter pub get

# Run the app
fvm flutter run
---

🖼️ Screenshots
<div align="center">
  <img src="https://github.com/user-attachments/assets/96212ce6-5b9f-454f-9262-b9bc9b7776a3" width="200"/>
  <img src="https://github.com/user-attachments/assets/dfd3d5a3-d2af-46fa-bbda-75375a12812c" width="200"/>
  <img src="https://github.com/user-attachments/assets/8c001d30-9ce1-4b97-b662-926a4f7be55b" width="200"/>
  <img src="https://github.com/user-attachments/assets/10adc111-b849-42dc-a914-b980afb46f99" width="200"/>
  <img src="https://github.com/user-attachments/assets/17b73cf7-d1f5-42c6-a111-0340d15ca6d1" width="200"/>
  <img src="https://github.com/user-attachments/assets/3c05a002-2644-4b43-9b40-3d9a64e24853" width="200"/>
  <img src="https://github.com/user-attachments/assets/5e45234f-13c1-46ce-8614-a1eb7c29c14f" width="200"/>
  <img src="https://github.com/user-attachments/assets/96936be0-5a15-48f5-a616-1ea41d618834" width="200"/>
  <img src="https://github.com/user-attachments/assets/8118e12d-2872-4d35-a2d1-7d24589024f8" width="200"/>
  <img src="https://github.com/user-attachments/assets/8c127143-412a-45cf-9e6c-e7761ce247ae" width="200"/>
  <img src="https://github.com/user-attachments/assets/27dc2b11-6a5f-4b67-91c4-040fd930ec04" width="200"/>
> 



📬 Contributing
Pull requests are welcome! Please:

Open an issue first to discuss large changes

Keep features modular and testable

Follow naming conventions and folder structure

---

🙌 Credits
Developed by Ahmed Bauiomy

Part of the CodeAlpha Internship 2025

Logo designed via vector-based tool with violet & green tones

---

*This README is up to date with the latest features and branding for FitSync.*
