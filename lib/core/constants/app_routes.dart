/// Named route strings used by `MaterialApp.routes`.
///
/// Screens with runtime arguments read them from
/// `ModalRoute.of(context)!.settings.arguments`:
///  - `/school-detail`, `/admission-requirements`, `/application-form`
///    -> `SchoolModel`
///  - `/application-detail`, `/admin-applicant-detail` -> `ApplicationModel`
///  - `/document-upload`, `/payment` -> `applicationId` (String)
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otpVerification = '/otp-verification';
  static const String emailVerification = '/email-verification';

  // Student app
  static const String dashboard = '/dashboard';
  static const String schoolDetail = '/school-detail';
  static const String admissionRequirements = '/admission-requirements';
  static const String applicationForm = '/application-form';
  static const String applicationDetail = '/application-detail';
  static const String applicationStatus = '/application-status';
  static const String documentUpload = '/document-upload';
  static const String payment = '/payment';
  static const String notifications = '/notifications';

  // Admin
  static const String adminLogin = '/admin-login';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminApplicants = '/admin-applicants';
  static const String adminApplicantDetail = '/admin-applicant-detail';
  static const String adminBatchUpload = '/admin-batch-upload';
  static const String adminRequirements = '/admin-requirements';
}

/// Routes the user is on *before* they are inside the app (splash, onboarding,
/// login, email verification, ...). A deep link waits while one of these is
/// on screen instead of pushing on top of it.
const Set<String> kPreAuthRoutes = <String>{
  AppRoutes.splash,
  AppRoutes.onboarding,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.forgotPassword,
  AppRoutes.otpVerification,
  AppRoutes.emailVerification,
  AppRoutes.adminLogin,
};
