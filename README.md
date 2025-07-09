# 🏃 CodeAlpha Fitness Tracker App

A modern Flutter-based fitness tracking app built during the **CodeAlpha Internship Program**.

This app helps users log their workouts, track calories, monitor activity progress, and view insights in a clean, user-friendly UI.

---

## 🔧 Core Features (Planned)

- 🔐 Firebase Authentication (Email/Password)
- 📝 Manual activity logging (steps, workout, calories, etc.)
- 📈 Dashboard with daily/weekly progress charts
- ⏱ Stopwatch and time tracking
- 🧍 User profile with personal info (age, weight, etc.)
- 📍 Optional route tracking with GPS
- 🔥 Calorie burn and speed calculation
- 📦 Local data storage with SQLite (Firebase optional sync)

---

## 📁 Project Structure

```bash
lib/
├── core/                   # Global services, constants, models
│
├── features/               # Feature-based architecture
│   ├── auth/               # Login, Signup, Auth cubit
│   │   ├── data/           
│   │   ├── logic/          
│   │   └── presentation/   
│   ├── user_profile/       # Personal info form (age, weight, etc.)
│   ├── activity_log/       # Add/edit workouts
│   ├── dashboard/          # Charts and progress summary
│   ├── stopwatch/          # Stopwatch timer logic and UI
│
├── shared/                 # Shared widgets and helpers
└── main.dart               # App entry point

🚀 Getting Started

fvm flutter pub get
fvm flutter run

```

📂 Repository Status
✅ Project initialized
🔜 Firebase Auth in progress
🔜 User profile & activity logging next

---
*This README will be updated as the project evolves.*
