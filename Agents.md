# CampusApply — School Admission Application System

## Project Overview
CampusApply is a cross-platform mobile application built with Flutter that
digitalises the school admission process for students and institutions across
Nigeria and worldwide. Students can browse schools, submit applications, upload
documents, make payments, and track admission status all from their phone.

## Tech Stack
- **Framework:** Flutter (Dart)
- **Backend:** Google Firebase (Auth, Firestore, Storage, Messaging)
- **State Management:** Provider
- **HTTP Client:** Dio (for Hipolabs Schools API)
- **Local Storage:** GetStorage
- **Navigation:** Named routes (MaterialApp routes map)

## Project Structure

lib/
├── main.dart # App entry point, Firebase init, routes
├── firebase_options.dart # Auto-generated Firebase config
│
├── core/
│ └── constants/
│ ├── app_colors.dart # Indigo-blue color palette
│ ├── app_text_styles.dart # Typography (PlusJakartaSans, Inter, DMSans)
│ └── app_routes.dart # Route name constants
│
├── models/
│ ├── user_model.dart
│ ├── school_model.dart # fromApi() and fromFirestore() factories
│ ├── application_model.dart # Includes jambScore and jambYear fields
│ └── notification_model.dart
│
├── services/
│ ├── auth_service.dart # Firebase Auth + Firestore user ops
│ └── school_api_service.dart # Hipolabs API + Firestore school ops
│
├── providers/
│ ├── auth_provider.dart # Auth state, login, register, logout
│ ├── school_provider.dart # School listing, search, country filter
│ ├── application_provider.dart # Submit, load, track applications
│ └── notification_provider.dart # Load, read, delete notifications
│
└── features/
├── splash/
├── onboarding/
├── auth/ # login, signup, forgot_password, otp
├── dashboard/ # Bottom nav shell (4 tabs)
├── home/ # Tab 1 — greeting, carousel, stats
├── schools/ # Tab 2 — listing, detail, card widget
├── application/ # Tab 3 — form, status, detail, upload, payment
├── profile/ # Tab 4 — view/edit profile, logout
├── notifications/ # Notification list screen
└── admin/ # Admin login, dashboard, applicant list/detail