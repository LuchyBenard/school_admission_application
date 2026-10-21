# CampusApply — School Admission Application System

CampusApply is a professional, cross-platform mobile application built with Flutter that digitalizes and simplifies the school admission process for students and institutions. It provides a seamless experience for browsing schools, submitting applications, managing documents, tracking admission status, and managing institutions offline and online.

---

## 🚀 Project Overview

The system is designed to serve two main user roles:
- **Students:** Can search for schools worldwide, bookmark favorite institutions, apply to multiple institutions with offline resilience, upload required documents (WAEC, JAMB, etc.), and monitor application progress in real-time.
- **Admins:** Can manage applications, review student documents, update admission statuses (Accept, Reject, Under Review, Request More Docs), and bulk-import schools via CSV.

---

## ✨ Key Features

### For Students
- **Branded Welcome & Smart Routing:** A full-screen, image-backed landing screen introduces the app. First-time / signed-out visitors can **Begin Application** or **Sign In**, while returning signed-in users are automatically routed to their dashboard, admin portal, or email verification.
- **Smart Dashboard:** Live application overview metrics (Applied, Under Review, Accepted, Rejected) with real-time updates.
- **Biometric Authentication:** Quick, secure biometric fingerprint and Face ID login powered by `local_auth` and encrypted with `flutter_secure_storage`.
- **Offline-First Resilience & Sync:** Built-in network connectivity detection (`connectivity_plus`) and background write queue (`OfflineQueueService`). Submissions and document uploads made while offline or on unstable networks are safely persisted locally via `GetStorage` and automatically replayed once reconnected.
- **Offline Sync Banner:** Interactive, responsive status banner (`OfflineSyncBanner`) displaying connection state, pending upload counts, sync progress, and a manual "Sync Now" trigger.
- **Saved / Favorite Schools:** One-tap school bookmarking with real-time Firestore synchronization and a dedicated quick-access carousel on the Home dashboard.
- **Application Deadline Countdowns:** Dynamic countdown timer chips (`DeadlineChip`) updating every second to display remaining application windows and auto-closing when deadlines pass.
- **Global School Search:** Browse thousands of institutions worldwide with a 6-tier resilience chain — including a bundled offline dataset of 115 Nigerian universities.
- **Country-Scoped Listings:** School results are filtered to the selected country, so globally featured or Firestore-seeded schools never leak into another country's list.
- **Region-Aware Admission Requirements:** For schools without admin-configured requirements, the app presents region-specific baseline templates (e.g. Nigeria JAMB/UTME cut-offs, UK UCAS/IELTS, US GPA/SAT, Ghana WASSCE, EU language requirements) instead of one generic list.
- **Multi-Step Application Wizard:** Intuitive 3-step application flow covering personal information, academic credentials (including JAMB scores/years), and programme selections.
- **Secure Document Upload:** Integrated photo/document picking with automatic compression and base64 Firestore storage (eliminating reliance on paid Firebase Storage Blaze plans).
- **Dual Theme Support:** High-contrast Material 3 Light and Dark modes built from a unified `AppPalette`, with automatic system detection or manual user preference.
- **Multi-Language Support (i18n):** Localized in 6 languages — English, Spanish, French, Hausa, Igbo, and Yorùbá — with instant in-app switching.
- **Real-Time Notifications:** In-app notification center plus push notification deep linking via Firebase Cloud Messaging and Cloud Functions.
- **Profile & Settings Management:** Control personal details, profile picture (stored as compressed base64), biometric login toggles, language, and theme preferences.

### For Administrators
- **Secure Admin Portal:** Role-gated login with email/password and biometric sign-in, restricted to users with `role: 'admin'` in Firestore.
- **Applicant Management:** Centralized dashboard with multi-criteria filtering (status, applicant name, programme).
- **Document & Application Review:** In-depth review screen for applicant documents, academic scores, and instantaneous status transitions with optional student feedback notes.
- **Batch School Upload (CSV):** High-speed batch import supporting up to 5,000 schools per CSV file with duplicate prevention, format validation, and batch Firestore writes.
- **Programme Requirements Manager:** Configure cut-off marks and custom entry requirements per school and degree level.

---

## 🛠 Tech Stack

- **Frontend:** Flutter (Dart 3.x)
- **Backend Services:** Google Firebase
  - **Firebase Authentication:** Secure email/password login and session management.
  - **Cloud Firestore:** Real-time NoSQL database for user profiles, school directories, applications, documents (base64 subcollections), favorites, and notifications.
  - **Cloud Functions:** Serverless triggers dispatching push notifications on application status updates.
  - **Firebase Cloud Messaging (FCM):** Push delivery and deep linking to specific application records.
- **State Management:** Provider (MultiProvider & ChangeNotifier architecture)
- **Local Caching & Storage:**
  - `GetStorage`: Fast key-value persistence for theme, language, session flags, offline school cache, and offline write queues.
  - `flutter_secure_storage`: Hardware-backed encrypted storage for biometric credentials.
- **Security & Biometrics:** `local_auth` for biometric fingerprint / face identification.
- **Networking & Connectivity:**
  - `dio`: High-performance HTTP client for university dataset mirrors.
  - `connectivity_plus`: Network connectivity monitoring.
- **Internationalization:** `flutter_localizations` & `intl` with 6 ARB translation catalogs.
- **UI & Interaction:**
  - `flutter_screenutil`: Pixel-perfect responsive screen adaptation.
  - `oktoast`: Non-intrusive interactive toast notifications.
  - `carousel_slider`: Dynamic promotional and featured school banners.
  - `country_flags`: Global country flag badges for international schools.
  - `file_picker` & `csv`: CSV parsing and file selection for administrative bulk operations.
  - `skeleton_loader`: Polished loading states during network fetches.

---

## 📁 Project Structure

```text
lib/
├── core/
│   ├── constants/            # AppColors, AppTextStyles, AppRoutes, AppStrings
│   ├── navigation/           # App navigation keys and route observers
│   ├── theme/                # AppTheme (Light & Dark), AppPalette
│   ├── utils/                # Helpers, formatting, and input validators
│   └── widgets/              # OfflineSyncBanner, DeadlineChip, CustomButton, CustomTextField
├── features/
│   ├── admin/                # Admin login, dashboard, applicant review, CSV batch upload
│   ├── applications/         # Multi-step application wizard, document upload, payment, status
│   ├── auth/                 # Login, signup, password reset, OTP & email verification
│   ├── dashboard/            # Bottom navigation shell
│   ├── home/                 # Greeting, featured schools, stats, and saved schools section
│   ├── notifications/        # Notification list and reading screen
│   ├── onboarding/           # Walkthrough onboarding carousel
│   ├── profile/              # Profile editing, biometrics toggle, theme & language settings
│   ├── schools/              # Global school search, filtering, detail, and requirements
│   └── splash/               # Branded landing screen, session verification, and role routing
├── l10n/
│   ├── app_*.arb             # Localization catalogs (en, es, fr, ha, ig, yo)
│   └── generated/            # Auto-generated localization classes
├── models/                   # UserModel, SchoolModel, ApplicationModel, PushPayload, etc.
├── providers/                # 10 State management providers (Auth, School, Application, Favorites, etc.)
├── services/                 # Firebase, Biometric, OfflineQueue, Storage, and School API services
└── main.dart                 # App bootstrap, Firebase & FCM initialization, provider tree

functions/                    # Firebase Cloud Functions (status update push notifications)
assets/
├── data/                     # Offline fallback Nigerian universities dataset (115 schools)
├── fonts/                    # PlusJakartaSans, Inter, DMSans typography
└── images/                   # App assets, logos, and placeholders
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
- **Global widget localization fallback:** Flutter's built-in Material/Cupertino localizations do not ship Hausa, Yorùbá, or Igbo. `main.dart` wraps the global delegates (`_FallbackMaterialLocalizationsDelegate` / `_FallbackCupertinoLocalizationsDelegate`) so these languages still resolve — app strings use the selected language, while built-in widget labels fall back to English instead of crashing with "No MaterialLocalizations found".
- **Missing translations:** Any key not yet translated in a catalog automatically falls back to the English template value.
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

## 📝 Roadmap & Current Status
- [x] Clean architecture and Provider state management (10 providers)
- [x] Biometric authentication (Fingerprint & Face ID) via `local_auth`
- [x] Offline write queue & auto-sync banner with manual retry (`connectivity_plus`)
- [x] Saved / Favorite schools system with real-time Firestore synchronization
- [x] Dynamic application deadline countdown chips (`DeadlineChip`)
- [x] Student dashboard and live application tracking
- [x] Document compression and base64 Firestore storage (zero Blaze dependency)
- [x] Global school search with 6-tier resilience chain + bundled offline list
- [x] Admin portal and applicant review system
- [x] Admin batch school upload via CSV
- [x] Material 3 Light and Dark theme system with instant toggle
- [x] Full localization across 6 languages (en, ha, yo, ig, fr, es)
- [x] Push notification triggers via Cloud Functions & FCM deep linking
- [x] Branded landing screen with smart first-timer vs returning-user routing
- [x] Country-scoped school listings and region-aware admission requirement templates
- [x] Safe language switching for Hausa / Yorùbá / Igbo (Material localizations fallback)
- [ ] Real-time PayStack/Flutterwave payment gateway integration

---

## ✅ Code Quality & Architecture Status
- **`dart analyze lib`**: ✅ Clean analysis across all feature directories, services, and core utilities.
- **`flutter gen-l10n`**: ✅ Generates successfully for all 6 locales (English, Hausa, Yorùbá, Igbo, French, Spanish).
- **Localization coverage**: UI strings are sourced from ARB catalogs; keys not yet translated in a given locale fall back to English rather than failing.
- **Language safety**: Hausa, Yorùbá and Igbo switch without crashing thanks to the global Material/Cupertino localization fallback delegates.
- **Settings persistence**: Appearance (Light/Dark/System) and Language preference persisted offline via `GetStorage`.
- **Biometric security**: Credentials stored in hardware-backed keystore/keychain via `FlutterSecureStorage`.
- **Data resilience**: Zero blank screens guaranteed by multi-mirror fallbacks and local storage queues.

---

## 🛠 Development Commands
```bash
# Install dependencies
flutter pub get

# Generate localizations after editing ARB files
flutter gen-l10n

# Static analysis
flutter analyze

# Run the app
flutter run

# Build release APK
flutter build apk --release
```

---

## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License
This project is for educational/demonstration purposes.
