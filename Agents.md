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


## Firebase Collections
users/ # uid, fullName, email, phone, role (student/admin)
  users/{uid}.photo # base64-encoded profile photo (optional)

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
- Primary: Hipolabs (https://universities.hipolabs.com/search)
- Fallback: GitHub mirror of the same dataset
  (https://raw.githubusercontent.com/Hipo/university-domains-list/master/world_universities_and_domains.json)
- No API key required
- Hipolabs called with `?country=Nigeria` etc; mirror downloads
  full world list and filters in Dart
- Results merged with Firestore featured schools
- On first successful load, API results are seeded into the
  Firestore `schools/` collection so future loads work even when
  both Hipolabs and the mirror are unreachable
- URL must use HTTPS

## School Batch Upload (Planned)
Admins can upload a batch list of schools to populate the
Firestore `schools/` collection without relying on the Hipolabs
API or the mirror.

### CSV Format
The file must be a UTF-8 CSV with a header row. Required columns:

| Column       | Required | Description                        | Example              |
|------------- |----------|------------------------------------|----------------------|
| name         | yes      | School name                        | University of Lagos  |
| country      | yes      | Full country name                  | Nigeria              |
| state        | no       | State / province                   | Lagos                |
| website      | no       | Primary website URL (HTTPS)        | https://unilag.edu.ng|
| isFeatured   | no       | `true` or `false` (default false)  | true                 |
| description  | no       | Short description                  | Premier university...|
| imageUrl     | no       | URL to school logo/photo           | https://...          |
| applicationFee | no     | Application fee as string          | ₦5,000               |
| deadline     | no       | Application deadline               | 2026-09-30           |

Example CSV:
```
name,country,state,website,isFeatured,description
University of Lagos,Nigeria,Lagos,https://unilag.edu.ng,true,Premier university in Nigeria
Ahmadu Bello University,Nigeria,Zaria,https://abu.edu.ng,false,Federal university
```

### Upload Flow
AdminDashboardScreen → Upload Schools button

↓

BatchUploadScreen
  - Pick CSV file from device (file_picker)
  - Show preview table (first 10 rows + total count)
  - Validate each row (name + country required)
  - Show validation errors before import

↓ (confirm)

Import to Firestore `schools/` collection
  - Batched writes (max 400 per batch) to respect Firestore limits
  - Duplicate detection by name + country (skip if exists)
  - Show progress indicator (row N of M)
  - On success: show count imported + skipped + errors
  - Store imported schools in GetStorage cache so they appear
    immediately in the student-facing school list

### Validation Rules
1. `name` is required and must be non-empty
2. `country` is required and must be non-empty
3. `website` must start with https:// if provided
4. Rows with duplicate `name + country` are skipped (not an error)
5. Total rows capped at 5000 per import

### Error Handling
- File not CSV → show "Please select a CSV file"
- Missing required columns → list which columns are missing
- Empty file → show "File contains no data"
- Firestore write failure → show which rows failed, allow retry
- Partial success → show imported/skipped/failed counts

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
- Firebase Cloud Messaging: installed but push notification
  triggers not yet implemented in Cloud Functions
- School Batch Upload: documented but screen not yet built
  (see School Batch Upload section above)

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