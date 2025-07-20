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
