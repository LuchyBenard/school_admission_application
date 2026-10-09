# CampusApply — School Admission Application System

CampusApply is a professional, cross-platform mobile application built with Flutter that digitalizes and simplifies the school admission process for students and institutions. It provides a seamless experience for browsing schools, submitting applications, managing documents, and tracking admission status.

---

## 🚀 Project Overview

The system is designed to serve two main user roles:
- **Students:** Can search for schools worldwide, apply to multiple institutions, upload required documents (WAEC, JAMB, etc.), and monitor their application progress in real-time.
- **Admins:** Can manage applications, review student documents, and update admission statuses (Accept, Reject, Under Review, Request More Docs).

---

## ✨ Key Features

### For Students
- **Smart Dashboard:** Overview of application statistics (Applied, Under Review, Accepted, Rejected).
- **Global School Search:** Browse thousands of schools worldwide via multiple fallback data sources — including a bundled offline list of 115 Nigerian universities that always works.
- **Multi-Step Application Form:** User-friendly wizard for personal, academic, and programme details.
- **Secure Document Upload:** Integrated image picking; images are compressed and stored as base64 in a Firestore subcollection (no paid Firebase Storage needed).
- **Notification System:** Real-time in-app updates plus push notification triggers via Firebase Cloud Functions.
- **Profile Management:** Complete control over personal information and account settings.
- **Multi-language Support:** Fully localized in English, Spanish, French, Hausa, Igbo, and Yoruba with system locale detection and manual language selection in Settings.

### For Administrators
- **Admin Portal:** Secure login restricted to authorized administrative users.
- **Applicant Management:** Centralized list of all applications with advanced filtering (by status, name, or course).
- **Review System:** Detailed view of applicant data and one-click status updates with optional admin messages.
- **Batch School Upload:** Import schools in bulk from a CSV file (with validation, preview, and duplicate detection).

---

## 🛠 Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Google Firebase
  - **Authentication:** Email/Password based secure login.
  - **Firestore:** Real-time database for user profiles, applications, documents, and notifications.
  - **Cloud Functions:** Push notification trigger that fires when an admin updates an application.
  - **Cloud Messaging:** Device push notification infrastructure.
- **State Management:** Provider
- **Networking:** Dio (global school listings via jsDelivr CDN mirror, GitHub raw mirror, and Hipolabs API)
- **Local Storage:** GetStorage (Session, onboarding, and school list caching)
- **Internationalization:** `flutter_localizations` with `intl` package — ARB files for 6 languages
- **UI/UX Enhancements:** 
  - `flutter_screenutil` for responsive design.
  - `skeleton_loader` for smooth data loading transitions.
  - `oktoast` for interactive user feedback.

---

## 📁 Project Structure

```text
lib/
├── core/             # Constants, themes, and shared widgets
├── features/         # Feature-based folders (Auth, Dashboard, Schools, Admin, etc.)
├── l10n/             # Localization files (ARB + generated Dart)
├── models/           # Data models and Firebase factories
├── providers/        # Business logic and state management
├── services/         # Firebase and API communication logic
└── main.dart         # Entry point and route configuration

functions/            # Firebase Cloud Functions (push notification trigger)
assets/data/          # Bundled offline Nigerian school list
```

## 🔌 School Data Sources (resilience chain)
The school list never appears empty. Data loads from the first available source:
1. **Device cache** (GetStorage) — shown instantly while newer data loads.
2. **jsDelivr CDN mirror** — cached copy of the Hipo university dataset (fast, reliable).
3. **GitHub raw mirror** — same dataset, second mirror.
4. **Hipolabs API** — original source, used as a last resort.
5. **Firestore** — schools auto-seeded from API results on first successful load.
6. **Bundled asset** — `assets/data/nigerian_schools.json` (115 real Nigerian universities), guaranteed offline fallback.

---

## 🌍 Internationalization (i18n)
CampusApply supports **6 languages** out of the box:

| Language | Code | File |
|----------|------|------|
| English | `en` | `lib/l10n/app_en.arb` |
| Spanish | `es` | `lib/l10n/app_es.arb` |
| French | `fr` | `lib/l10n/app_fr.arb` |
| Hausa | `ha` | `lib/l10n/app_ha.arb` |
| Igbo | `ig` | `lib/l10n/app_ig.arb` |
| Yoruba | `yo` | `lib/l10n/app_yo.arb` |

### How it works
- **Auto-detection:** App uses system locale on first launch via `flutter_localizations`.
- **Manual override:** Users can change language in Settings → Language (persisted via GetStorage).
- **Generation:** Run `flutter gen-l10n` after editing ARB files to regenerate `lib/l10n/generated/app_localizations.dart`.
- **Usage:** Access strings via `AppLocalizations.of(context).keyName` — no hardcoded strings in UI.

### Adding a new language
1. Copy `lib/l10n/app_en.arb` to `lib/l10n/app_<code>.arb`
2. Translate all values
3. Add locale to `supportedLocales` in `main.dart` (auto-handled by `AppLocalizations.supportedLocales`)
4. Run `flutter gen-l10n`

---

## ⚙️ Getting Started

### Prerequisites
- Flutter SDK (latest version recommended)
- Android Studio or VS Code
- A Firebase Project

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/school_admission_application.git
   ```
2. Navigate to the project folder:
   ```bash
   cd school_admission_application
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Configure Firebase:
   - Place your `google-services.json` in `android/app/`.
   - Place your `GoogleService-Info.plist` in `ios/Runner/`.
   - Or run `flutterfire configure`.

### Running the App
```bash
flutter run
```

---

## 🔒 Firebase Setup Required
1. Enable **Email/Password** in Firebase Auth.
2. Create a **Cloud Firestore** database.
3. To create an admin user:
   - Register a normal account.
   - Manually set the `role` field to `'admin'` in the `users` collection within the Firebase Console.
4. **Deploy the push notification Cloud Function** (only if you want device push notifications):
   ```bash
   cd functions
   npm install
   firebase login
   firebase deploy --only functions
   ```

---

## 📝 Roadmap
- [x] Base architecture and Firebase integration.
- [x] Student dashboard and application tracking.
- [x] Admin portal and applicant review system.
- [x] Global school search with multi-source fallback + offline bundled list.
- [x] Push notification triggers via Cloud Functions (built; deploy with `firebase deploy`).
- [x] Admin batch school upload (CSV).
- [ ] Real-time PayStack/Flutterwave payment integration.

---

## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License
This project is for educational/demonstration purposes.
