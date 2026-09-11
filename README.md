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
- **Global School Search:** Integration with external APIs to browse thousands of schools worldwide.
- **Multi-Step Application Form:** User-friendly wizard for personal, academic, and programme details.
- **Secure Document Upload:** Integrated image picking and Firebase storage for essential credentials.
- **Notification System:** Real-time updates on application status changes.
- **Profile Management:** Complete control over personal information and account settings.

### For Administrators
- **Admin Portal:** Secure login restricted to authorized administrative users.
- **Applicant Management:** Centralized list of all applications with advanced filtering (by status, name, or course).
- **Review System:** Detailed view of applicant data and one-click status updates with optional admin messages.

---

## 🛠 Tech Stack

- **Frontend:** Flutter (Dart)
- **Backend:** Google Firebase
  - **Authentication:** Email/Password based secure login.
  - **Firestore:** Real-time database for user profiles, applications, and notifications.
  - **Cloud Messaging:** Infrastructure for push notifications.
- **State Management:** Provider
- **Networking:** Dio (API integration for global school listings)
- **Local Storage:** GetStorage (Session and onboarding management)
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
├── models/           # Data models and Firebase factories
├── providers/        # Business logic and state management
├── services/         # Firebase and API communication logic
└── main.dart         # Entry point and route configuration
```

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

---

## 📝 Roadmap
- [x] Base architecture and Firebase integration.
- [x] Student dashboard and application tracking.
- [x] Admin portal and applicant review system.
- [x] Global school search integration.
- [ ] Real-time PayStack/Flutterwave payment integration.
- [ ] Push notification triggers via Cloud Functions.
- [ ] Admin batch school upload (CSV).

---

## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License
This project is for educational/demonstration purposes.
