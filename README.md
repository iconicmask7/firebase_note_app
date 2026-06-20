# Flutter Developer Assessment - Note Application

A top-tier, production-ready Flutter application demonstrating an industrial-standard approach to authentication, state management, and offline-first data synchronization. This application was built to fulfill the requirements of the Flutter Developer Assessment.

## 🎯 Project Overview

This Note-taking app allows users to securely register, log in, and manage their notes. It features a complete offline-first architecture, ensuring users can create, read, update, and delete notes without an internet connection, with automatic background synchronization to the cloud upon reconnection. The application boasts a premium, high-fidelity UI with smooth micro-animations, dynamic Light/Dark mode theming, and haptic feedback.

---

## 🛠️ Technical Stack & Architecture

### **Architecture: Clean Architecture + MVVM**
The codebase is strictly separated into distinct layers to ensure scalability, testability, and maintainability:
- **Presentation Layer:** Contains UI components (Widgets/Screens) and ViewModels.
- **Domain Layer:** Contains core business logic, Entities, and Repository Interfaces.
- **Data Layer:** Contains Remote/Local Data Sources, Models, and Repository Implementations.

### **Core Technologies Used**
- **Framework:** Flutter 3.x (Null Safety)
- **Target Platform:** Android (Optimized and Built for APK distribution)
- **State Management:** Riverpod (`flutter_riverpod`, `riverpod_generator`) - chosen for its compile-time safety and robust dependency injection.
- **Routing:** GoRouter - for declarative, deep-linkable, and secure routing (including Auth guards and Splash Screen).
- **Backend Service:** Firebase Authentication & Cloud Firestore
- **Networking/API:** Dio - utilized for fetching the dynamic "Quote of the Day" with advanced interceptors and error handling.
- **Local Database (Offline-First):** Hive - for fast, synchronous key-value caching.
- **Secure Storage:** Flutter Secure Storage - for AES-encrypted storage of sensitive authentication tokens.

---

## ✨ Key Features

1. **Robust Authentication Flow**
   - Secure Email & Password Registration/Login.
   - **Google Sign-In** integration.
   - Secure token persistence to keep the user logged in across sessions.
   - Dynamic password strength indicator during registration.

2. **Advanced Offline Support**
   - Native Firestore offline persistence explicitly enabled with unlimited cache.
   - Hive acts as a secondary local cache.
   - Seamless CRUD (Create, Read, Update, Delete) operations work flawlessly without internet, syncing instantly when back online.

3. **Premium UI/UX Design**
   - **Dynamic Theming:** Instant switching between Light, Dark, and System themes using `SharedPreferences`.
   - **Animations:** Staggered entrance animations, hero transitions, spring-loaded buttons, and animated FABs.
   - **Haptic Feedback:** Strategic physical feedback on taps and interactions to simulate a premium tactile feel.
   - Custom bottom-sheet confirmation dialogs to prevent accidental logouts and deletions.

4. **API Integration**
   - Live "Quote of the Day" fetched securely via `Dio` from a remote REST API on the dashboard.

---

## 🚀 Setup & Configuration Instructions

### 1. Prerequisites
- Flutter SDK (`>=3.0.0`)
- Android Studio & Android Toolchain (for keystore configuration)
- A Firebase Account

### 2. Firebase Configuration
To run this project with your own Firebase database, you must supply your own `google-services.json` file.

1. Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project.
2. Go to **Build > Authentication** and enable **Email/Password** and **Google Sign-in**.
3. Go to **Build > Firestore Database**, create a new database in **Test Mode** (or Production Mode with the rules below).
4. **Important Security Rules:**
   ```text
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       match /notes/{noteId} {
         allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
       }
     }
   }
   ```
5. Register an Android app in the Firebase console with the package name: `com.example.note_app`.
6. Add your debug/release `SHA-1` and `SHA-256` keys to the Firebase project settings (Crucial for Google Sign-In).
7. Download the `google-services.json` file and place it in the `android/app/` directory of this repository.

### 3. Keystore Configuration (Android)
The app is configured to sign the release build automatically using a `.jks` file.
1. Place your `upload-keystore.jks` in the `android/app/` directory.
2. Create an `android/key.properties` file with the following content:
   ```properties
   storePassword=your_store_password
   keyPassword=your_key_password
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

### 4. Running the Application
1. Clone the repository.
2. Run `flutter pub get` to install all dependencies.
3. Run `dart run build_runner build -d` to generate the Riverpod providers and JSON serialization files.
4. Connect an Android device or emulator.
5. Run `flutter run` for debug mode, or `flutter run --release` for a production build.

---

## 📦 Building the Final Release APK

To build the optimized, obfuscated release APK for Android submission:
```bash
flutter build apk --release
```
The final generated APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`
