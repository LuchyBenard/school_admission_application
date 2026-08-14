# CampusApply — School Admission Application System

## Project Overview
CampusApply is a cross-platform mobile application built with Flutter that
digitalises the school admission process for students and institutions across
Nigeria and worldwide. Students can browse schools, submit applications, upload
documents, make payments, and track admission status all from their phone.

## Tech Stack
- **Framework:** Flutter (Dart)
- **Backend:** Google Firebase (Auth, Firestore, Messaging)
  Document images are stored as compressed base64 in a Firestore
  subcollection (NO Firebase Storage — requires the Blaze plan).
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


## Key Routes
/ → SplashScreen

/onboarding → OnboardingScreen

/login → LoginScreen

/register → SignupScreen

/dashboard → DashboardScreen (student home)

/school-detail → SchoolDetailScreen (args: SchoolModel)

/application-form → ApplicationFormScreen (args: SchoolModel)

/document-upload → DocumentUploadScreen (args: applicationId String)

/payment → PaymentScreen (args: applicationId String)

/application-detail → ApplicationDetailScreen (args: ApplicationModel)

/notifications → NotificationsScreen

/admin-login → AdminLoginScreen

/admin-dashboard → AdminDashboardScreen

/admin-applicants → ApplicantListScreen

/admin-applicant-detail → ApplicantDetailScreen (args: ApplicationModel)


## Key Routes
/ → SplashScreen

/onboarding → OnboardingScreen

/login → LoginScreen

/register → SignupScreen

/dashboard → DashboardScreen (student home)

/school-detail → SchoolDetailScreen (args: SchoolModel)

/application-form → ApplicationFormScreen (args: SchoolModel)

/document-upload → DocumentUploadScreen (args: applicationId String)

/payment → PaymentScreen (args: applicationId String)

/application-detail → ApplicationDetailScreen (args: ApplicationModel)

/notifications → NotificationsScreen

/admin-login → AdminLoginScreen

/admin-dashboard → AdminDashboardScreen

/admin-applicants → ApplicantListScreen

/admin-applicant-detail → ApplicantDetailScreen (args: ApplicationModel)


## Firebase Collections
users/ # uid, fullName, email, phone, role (student/admin)

schools/ # name, country, state, website, isFeatured, imageUrl

applications/ # userId, schoolName, status, jambScore, documents[]
  applications/{id}/documents/ # one doc per image: docKey, data (base64), userId

notifications/ # userId, title, message, type, isRead, createdAt


## Application Flow
School Detail → Apply Now

↓

ApplicationFormScreen (3 steps: personal, academic, programme)

↓ returns applicationId

DocumentUploadScreen (WAEC, JAMB, passport, birth cert → Firestore documents subcollection as base64)

↓ passes applicationId

PaymentScreen (placeholder — ₦5,000 fee)

↓

Dashboard

## Admin Flow
AdminLoginScreen → checks role = 'admin' in Firestore

↓

AdminDashboardScreen → stats overview

↓

ApplicantListScreen → search + filter

↓

ApplicantDetailScreen → Accept / Reject / Request Docs / Under Review

↓

writes to applications/{id} + creates notification for student

## Role Detection
- On splash screen, after Firebase Auth confirms a logged-in user,
  the app reads `users/{uid}.role` from Firestore
- role = 'admin' → navigate to /admin-dashboard
- role = 'student' → navigate to /dashboard
- No user → check GetStorage for onboarding flag → /onboarding or /login

## Schools API
- Provider: Hipolabs (https://universities.hipolabs.com/search)
- No API key required
- Called with `?country=Nigeria` etc
- Results merged with Firestore featured schools
- URL must use HTTPS

## State Management Rules
- Use `context.read<Provider>()` inside methods/callbacks (no rebuild)
- Use `context.watch<Provider>()` inside build() (triggers rebuild)
- Use `Consumer<Provider>` to rebuild only a small part of the UI
- StatefulWidget is used when screen has local UI state
  (controllers, animations, local booleans)
- Provider handles shared/business logic state only

## Coding Conventions
- All colors from AppColors — never hardcode hex values
- All text styles from AppTextStyles — never hardcode TextStyle inline
- All sizing via ScreenUtil (.w .h .r .sp)
- Feature folders own their screens and their widgets subfolder
- Shared widgets go in core/widgets/
- Services only talk to Firebase/APIs — no UI logic
- Providers call services and hold state — no widgets
- Models have fromFirestore(), fromApi(), toMap() methods

## Known Placeholders
- Payment: currently simulates success after 2s delay
  Real integration: PayStack or FlutterWave
- Document upload: uses image_picker (gallery only, max 1024px @
  quality 70), stored as base64 in a Firestore subcollection
  Camera support can be added via ImageSource. Camera
- Firebase Cloud Messaging: installed but push notification
  triggers not yet implemented in Cloud Functions
- Fingerprint login: local_auth + flutter_secure_storage
  On login, checking "Enable fingerprint sign-in" saves the email +
  password to secure storage; the login screen then shows a
  fingerprint button that authenticates and signs in automatically

## Firebase Setup Required
1. Enable Email/Password in Firebase Auth
2. Create Firestore database in test mode
3. Add google-services.json to android/app/
4. Add GoogleService-Info.plist to ios/Runner/
5. To create admin: set role field to 'admin'
   in Firestore users collection for that user's document
   (No Firebase Storage needed — documents are base64 in Firestore)

## Running the Project
```bash
flutter pub get
flutterfire configure   # if firebase_options.dart is missing
flutter run
```

## Common Issues
- Firestore compound query (where + orderBy) requires composite index
  Fix: remove orderBy and sort list manually in Dart
- HTTP URLs blocked on Android: use HTTPS for all API calls
- Gradle build timeout: download Gradle zip manually and place in
  ~/.gradle/wrapper/dists/gradle-X.X-all/[random-folder]/
- ADB Wi-Fi: run `adb tcpip 5555` then `adb connect [phone-ip]:5555`