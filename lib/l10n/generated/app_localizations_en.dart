// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'CampusApply';

  @override
  String get appTagline => 'Your Admission, Simplified';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRetry => 'Try Again';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonDone => 'Done';

  @override
  String get commonSubmit => 'Submit';

  @override
  String get navHome => 'Home';

  @override
  String get navSchools => 'Schools';

  @override
  String get navApplications => 'Applications';

  @override
  String get navProfile => 'Profile';

  @override
  String get onboardingTitleFindSchool => 'Find Your Perfect School';

  @override
  String get onboardingSubtitleFindSchool =>
      'Explore thousands of universities and institutions across Nigeria and worldwide all in one place.';

  @override
  String get onboardingTitleApplyTrack => 'Apply & Track With Ease';

  @override
  String get onboardingSubtitleApplyTrack =>
      'Submit applications, upload documents, pay fees and get real-time updates on your admission status.';

  @override
  String get onboardingTitleGetStarted => 'Get Started';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get loginTitle => 'Welcome Back';

  @override
  String get loginSubtitle => 'Sign in to continue your admission journey';

  @override
  String get loginEmailLabel => 'Email address';

  @override
  String get loginEmailHint => 'Enter your email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => 'Enter your password';

  @override
  String get loginSignIn => 'Sign In';

  @override
  String get loginSigningIn => 'Signing in...';

  @override
  String get loginForgotPassword => 'Forgot Password?';

  @override
  String get loginCreateAccount => 'Create Account';

  @override
  String get loginAdminPortal => 'Admin Portal';

  @override
  String get loginFingerprintSignIn => 'Sign in with fingerprint';

  @override
  String get loginEnableFingerprint => 'Enable fingerprint sign-in';

  @override
  String get loginFingerprintNotRecognised =>
      'Fingerprint not recognised. Try again or sign in manually.';

  @override
  String get loginNoSavedCredentials =>
      'No saved credentials found. Sign in manually once first.';

  @override
  String get loginErrorEmailRequired => 'Please enter your email';

  @override
  String get loginErrorPasswordRequired => 'Please enter your password';

  @override
  String get loginErrorPasswordTooShort =>
      'Password must be at least 8 characters';

  @override
  String get signupTitle => 'Create Account';

  @override
  String get signupSubtitle =>
      'Join thousands of students applying to their dream schools.';

  @override
  String get signupFullNameLabel => 'Full Name';

  @override
  String get signupFullNameHint => 'Enter your full name';

  @override
  String get signupEmailLabel => 'Email Address';

  @override
  String get signupEmailHint => 'Enter your email';

  @override
  String get signupPhoneLabel => 'Phone Number';

  @override
  String get signupPhoneHint => 'Enter your digits. e.g 08012345678';

  @override
  String get signupPasswordLabel => 'Password';

  @override
  String get signupPasswordHint => 'Create a password';

  @override
  String get signupConfirmPasswordLabel => 'Confirm Password';

  @override
  String get signupConfirmPasswordHint => 'Confirm your password';

  @override
  String get signupButton => 'Register';

  @override
  String get signupSignInLink => 'Sign In';

  @override
  String get signupTermsPrefix => 'I agree to the ';

  @override
  String get signupTermsAndConditions => 'Terms of Service';

  @override
  String get signupPrivacyPolicy => 'Private Policy';

  @override
  String get signupTermsSeparator => 'and ';

  @override
  String get signupErrorNameRequired => 'Please enter your first and last name';

  @override
  String get signupErrorEmailRequired => 'please enter your email';

  @override
  String get signupErrorEmailInvalid => 'Please enter a valid email address';

  @override
  String get signupErrorPhoneRequired => 'please enter your phone number';

  @override
  String get signupErrorPhoneInvalid => 'Please enter a valid phone number';

  @override
  String get signupErrorPasswordRequired => 'please create a password';

  @override
  String get signupErrorPasswordTooShort =>
      'Password must be at least 8 characters';

  @override
  String get signupErrorPasswordMismatch => 'Password do not match';

  @override
  String get signupErrorConfirmPasswordRequired =>
      'please confirm your  password';

  @override
  String get signupErrorTermsRequired =>
      'Please accept the terms and condition to continue.';

  @override
  String get forgotPasswordTitle => 'Forgot Password?';

  @override
  String get forgotPasswordDescription =>
      'Enter your email and we\'ll send you a link to reset your password.';

  @override
  String get forgotPasswordEmailLabel => 'Email Address';

  @override
  String get forgotPasswordEmailHint => 'Enter your email';

  @override
  String get forgotPasswordButton => 'Send OTP';

  @override
  String get forgotPasswordRememberPassword => 'Remember your password? ';

  @override
  String get forgotPasswordSignIn => 'Sign In';

  @override
  String get forgotPasswordErrorEmailRequired => 'Please enter your email';

  @override
  String get forgotPasswordErrorEmailInvalid =>
      'Please enter a valid email address';

  @override
  String get otpTitle => 'Enter OTP';

  @override
  String otpDescription(String email) {
    return 'We sent a 6-digit OTP to $email';
  }

  @override
  String get otpVerifyButton => 'Verify Code';

  @override
  String get otpResendButton => 'Resend OTP';

  @override
  String get otpErrorRequired => 'Please enter the complete 6-digit  OTP';

  @override
  String get otpErrorPasswordRequired => 'Please enter a new password';

  @override
  String get otpErrorPasswordTooShort =>
      'Password must be at least 6 characters';

  @override
  String get otpErrorPasswordMismatch => 'Passwords do not match';

  @override
  String get otpErrorConfirmPasswordRequired => 'Please confirm your password';

  @override
  String get otpNewPasswordLabel => 'New Password';

  @override
  String get otpNewPasswordHint => 'Enter new password';

  @override
  String get otpConfirmPasswordLabel => 'Confirm Password';

  @override
  String get otpConfirmPasswordHint => 'Confirm new password';

  @override
  String get otpResetPasswordButton => 'Reset Password';

  @override
  String get emailVerifyTitle => 'Verify your email';

  @override
  String emailVerifySentTo(String email) {
    return 'We sent a verification email to $email';
  }

  @override
  String get emailVerifyPasteHint => 'Paste verification code';

  @override
  String get emailVerifyDescription =>
      'In the email, copy the code from the verification link and paste it below.';

  @override
  String get emailVerifySuccessNote =>
      'Once verified, you will be taken to your dashboard automatically.';

  @override
  String get emailVerifyWithCode => 'Verify with code';

  @override
  String get emailVerifyResend => 'Resend Email';

  @override
  String get emailVerifySignOut => 'Sign out';

  @override
  String get emailVerifySentToaster =>
      'Verification email sent. Check your inbox.';

  @override
  String get emailVerifySuccess => 'Email verified. Welcome aboard!';

  @override
  String get emailVerifySendFailed =>
      'Could not send verification email. Please wait a minute and retry.';

  @override
  String get emailVerifyCodeRequired => 'Please enter the verification code';

  @override
  String get emailVerifyCodeInvalid => 'Invalid or expired verification code.';

  @override
  String get emailVerifyInbox => 'your inbox';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String get homeSearchTitle => 'Find and apply to your dream school';

  @override
  String get homeFindSchools => 'Find Schools';

  @override
  String get homeQuickActions => 'Quick Actions';

  @override
  String get homeStatsTotalApplied => 'Total Applied';

  @override
  String get homeStatsUnderReview => 'Under Review';

  @override
  String get homeStatsAccepted => 'Accepted';

  @override
  String get homeStatsRejected => 'Rejected';

  @override
  String get homeMyApplications => 'My Applications';

  @override
  String get homeMyDocuments => 'My Documents';

  @override
  String get homeSavedSchools => 'Saved Schools';

  @override
  String get homeFeaturedSchools => 'Featured Schools';

  @override
  String get homeNoApplicationsYet =>
      'You have no application yet. Apply to a school first.';

  @override
  String get homeNoSavedSchools =>
      'No saved schools yet. Tap the heart on any school to save it here.';

  @override
  String get homeRemovedFromFavorites => 'Removed from favorites';

  @override
  String get homeRoleStudent => 'Student';

  @override
  String get schoolsTitle => 'Find Schools';

  @override
  String get schoolsSearchHint => 'Search Schools...';

  @override
  String get schoolsListSubtitle => 'Browse thousands of school worldwide';

  @override
  String get schoolsEmptyTitle => 'No schools found';

  @override
  String get schoolsEmptyMessage =>
      'Try searching with a different name or country';

  @override
  String get schoolsLoadFailed => 'Failed to load schools';

  @override
  String get schoolsOffline => 'Check your internet connection and try again';

  @override
  String get schoolsFeaturedBadge => 'Featured';

  @override
  String get schoolsWebsiteAction => 'Website';

  @override
  String get schoolsCouldNotOpenWebsite => 'Could not open website';

  @override
  String get schoolsInvalidWebsiteUrl => 'Invalid website URL';

  @override
  String get schoolDetailAbout => 'About';

  @override
  String get schoolDetailLocation => 'Location';

  @override
  String get schoolDetailCountry => 'Country';

  @override
  String get schoolDetailWebsite => 'Website';

  @override
  String get schoolDetailVisitWebsite => 'Visit Website';

  @override
  String get schoolDetailStatus => 'Status';

  @override
  String get schoolDetailDeadline => 'Deadline';

  @override
  String get schoolDetailApplicationFee => 'Application Fee';

  @override
  String get schoolDetailApplicationsClosed => 'Applications Closed';

  @override
  String get schoolDetailApplyNow => 'Apply Now';

  @override
  String get schoolDetailAdmissionRequirements => 'Admission Requirements';

  @override
  String get requirementsTitle => 'Admission Requirements';

  @override
  String get requirementsProgrammesHeading => 'Programmes and cut-off scores';

  @override
  String get requirementsRequirementsHeading => 'Requirements';

  @override
  String get requirementsEmptyTitle => 'No requirements published yet';

  @override
  String get requirementsEmptyNote =>
      'Check the school website or contact the admission office for the latest requirements.';

  @override
  String get requirementsNoCutOff => 'No cut-off published';

  @override
  String get requirementsLoadFailed => 'Failed to load requirements';

  @override
  String get applicationFormTitle => 'Application Form';

  @override
  String get applicationFormStepPersonal => 'Personal Details';

  @override
  String get applicationFormStepPersonalSubtitle => 'Tell us about yourself';

  @override
  String get applicationFormStepAcademic => 'Academic Details';

  @override
  String get applicationFormStepAcademicSubtitle =>
      'Tell us about your educational background';

  @override
  String get applicationFormStepProgramme => 'Programme Selection';

  @override
  String get applicationFormStepProgrammeSubtitle =>
      'Select your programme of study';

  @override
  String get applicationFormFullName => 'Full Name';

  @override
  String get applicationFormFullNameHint => 'Enter your full name';

  @override
  String get applicationFormDateOfBirth => 'Date of Birth';

  @override
  String get applicationFormDateOfBirthHint => 'Select your date of birth';

  @override
  String get applicationFormGender => 'Gender';

  @override
  String get applicationFormGenderHint => 'Select gender';

  @override
  String get applicationFormGenderMale => 'Male';

  @override
  String get applicationFormGenderFemale => 'Female';

  @override
  String get applicationFormGenderPreferNotToSay => 'Prefer not to say';

  @override
  String get applicationFormNationality => 'Nationality';

  @override
  String get applicationFormNationalityHint => 'e.g Nigerian';

  @override
  String get applicationFormQualification => 'Highest Qualification';

  @override
  String get applicationFormQualificationHint => 'Select qualification';

  @override
  String get applicationFormQualificationOLevel => 'WAEC/SSCE';

  @override
  String get applicationFormQualificationNeco => 'NECO';

  @override
  String get applicationFormQualificationALevels => 'A-Levels';

  @override
  String get applicationFormQualificationOnd => 'OND';

  @override
  String get applicationFormQualificationHnd => 'HND';

  @override
  String get applicationFormGrade => 'Grade';

  @override
  String get applicationFormGradeHint => 'e.g 2023';

  @override
  String get applicationFormGraduationYear => 'Graduation Year';

  @override
  String get applicationFormGraduationYearHint => 'e.g 2023';

  @override
  String get applicationFormJambScore => 'JAMB Score';

  @override
  String get applicationFormJambYear => 'JAMB Year';

  @override
  String get applicationFormCourseOfStudy => 'Course of Study';

  @override
  String get applicationFormCourseOfStudyHint => 'e.g Computer Science';

  @override
  String get applicationFormEntryLevel => 'Entry Level';

  @override
  String get applicationFormEntryLevelHint => 'Select entry level';

  @override
  String get applicationFormEntryLevelUndergraduate =>
      'Undergraduate (100 level)';

  @override
  String get applicationFormEntryLevelDirect => 'Direct Entry (200 level)';

  @override
  String get applicationFormEntryLevelPostgraduate => 'Postgraduate';

  @override
  String get applicationFormEntryLevelMasters => 'Masters';

  @override
  String get applicationFormEntryLevelPhd => 'PhD';

  @override
  String get applicationFormSession => 'Session';

  @override
  String get applicationFormSessionHint => 'e.g 2023/2024';

  @override
  String get applicationFormSubmitButton => 'Submit Application';

  @override
  String get applicationFormSaved =>
      'Application saved! Please upload your documents.';

  @override
  String get applicationFormSubmitFailed =>
      'Failed to submit application. Please try again.';

  @override
  String get applicationFormErrorNameRequired => 'Please enter your full name';

  @override
  String get applicationFormErrorDobRequired =>
      'Please select your date of birth';

  @override
  String get applicationFormErrorGenderRequired => 'Please select your gender';

  @override
  String get applicationFormErrorNationalityRequired =>
      'Please enter your nationality';

  @override
  String get applicationFormErrorQualificationRequired =>
      'Please select your qualification';

  @override
  String get applicationFormErrorGradeRequired =>
      'Please enter your grade or result';

  @override
  String get applicationFormErrorGraduationYearRequired =>
      'Please enter your graduation year';

  @override
  String get applicationFormErrorYearInvalid => 'Please enter a valid year';

  @override
  String get applicationFormErrorJambScoreRequired =>
      'Please enter your JAMB score';

  @override
  String get applicationFormErrorJambScoreInvalid =>
      'Please enter a valid JAMB score (0-400)';

  @override
  String get applicationFormErrorJambYearRequired =>
      'Please enter your JAMB year';

  @override
  String get applicationFormErrorCourseRequired =>
      'Please enter your course of study';

  @override
  String get applicationFormErrorEntryLevelRequired =>
      'Please select your entry level';

  @override
  String get applicationFormErrorSessionRequired => 'Please enter your session';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusUnderReview => 'Under Review';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get statusWithdrawn => 'Withdrawn';

  @override
  String get statusDocsNeeded => 'Docs Needed';

  @override
  String get statusMoreDocumentsRequired => 'More Documents Required';

  @override
  String get statusListTitle => 'My Applications';

  @override
  String get statusListSubtitle => 'Track all your admission applications';

  @override
  String get statusFilterAll => 'All';

  @override
  String get statusEmptyTitle => 'No Applications yet';

  @override
  String get statusBrowseSchools => 'Browse Schools';

  @override
  String get statusLoadFailed => 'Failed to load applications';

  @override
  String get applicationDetailTitle => 'Application Details';

  @override
  String get applicationDetailSchoolInfo => 'School Information';

  @override
  String get applicationDetailPersonalInfo => 'Personal Details';

  @override
  String get applicationDetailAcademicInfo => 'Academic Details';

  @override
  String get applicationDetailProgrammeInfo => 'Programme Details';

  @override
  String get applicationDetailSubmissionInfo => 'Submission Information';

  @override
  String get applicationDetailRowSchool => 'School';

  @override
  String get applicationDetailRowCountry => 'Country';

  @override
  String get applicationDetailRowFullName => 'Full Name';

  @override
  String get applicationDetailRowDateOfBirth => 'Date of Birth';

  @override
  String get applicationDetailRowGender => 'Gender';

  @override
  String get applicationDetailRowNationality => 'Nationality';

  @override
  String get applicationDetailRowQualification => 'Qualification';

  @override
  String get applicationDetailRowGrade => 'Grade/Result';

  @override
  String get applicationDetailRowGraduationYear => 'Graduation Year';

  @override
  String get applicationDetailRowCourseOfStudy => 'Course of Study';

  @override
  String get applicationDetailRowEntryLevel => 'Entry Level';

  @override
  String get applicationDetailRowSession => 'Session';

  @override
  String get applicationDetailRowDateSubmitted => 'Date Submitted';

  @override
  String get applicationDetailRowStatus => 'Status';

  @override
  String get applicationDetailSubmittedRecently => 'Recently';

  @override
  String get applicationDetailCardSubmittedRecently => 'Submitted recently';

  @override
  String get applicationDetailWithdraw => 'Withdraw Application';

  @override
  String get applicationDetailReapply => 'Re-apply';

  @override
  String get applicationDetailDelete => 'Delete Application';

  @override
  String get applicationDetailWithdrawConfirmTitle => 'Withdraw Application';

  @override
  String applicationDetailWithdrawConfirmBody(String school) {
    return 'Are you sure you want to withdraw your application to $school? You can re-apply later.';
  }

  @override
  String get applicationDetailDeleteConfirmTitle => 'Delete Application';

  @override
  String applicationDetailDeleteConfirmBody(String school) {
    return 'Are you sure you want to delete your application to $school? This cannot be undone.';
  }

  @override
  String get applicationDetailWithdrawAction => 'Withdraw';

  @override
  String get applicationDetailWithdrawn => 'Application withdrawn';

  @override
  String get applicationDetailWithdrawFailed =>
      'Failed to withdraw application';

  @override
  String get applicationDetailDeleted => 'Application deleted';

  @override
  String get applicationDetailDeleteFailed => 'Failed to delete application';

  @override
  String get documentUploadTitle => 'Document Upload';

  @override
  String get documentUploadRequiredHeading => 'Required Documents';

  @override
  String get documentUploadUploadAll => 'Upload all 4 documents to proceed';

  @override
  String get documentUploadFormatNote =>
      'All documents must be clear and readable. Accepted formats: JPG, PNG.';

  @override
  String get documentUploadProceedToPayment => 'Proceed to Payment';

  @override
  String get documentUploadChooseSource => 'Choose Source';

  @override
  String get documentUploadChooseFromGallery => 'Choose from Gallery';

  @override
  String get documentUploadTakePhoto => 'Take a Photo';

  @override
  String get documentUploadReplace => 'Replace';

  @override
  String get documentUploadUpload => 'Upload';

  @override
  String get documentUploadAllDone => 'All Done';

  @override
  String get documentUploadRequiredAll => 'Required: all 4';

  @override
  String get documentUploadWaecTitle => 'WAEC/NECO Result';

  @override
  String get documentUploadWaecSubtitle => 'Upload your O-level result';

  @override
  String get documentUploadJambTitle => 'JAMB Result';

  @override
  String get documentUploadJambSubtitle => 'Upload your JAMB result slip';

  @override
  String get documentUploadPassportTitle => 'Passport Photo';

  @override
  String get documentUploadPassportSubtitle =>
      'Upload a recent passport-sized photo';

  @override
  String get documentUploadBirthCertTitle => 'Birth Certificate';

  @override
  String get documentUploadBirthCertSubtitle => 'Upload your birth certificate';

  @override
  String get documentUploadPickFailed =>
      'Failed to pick file. Please try again.';

  @override
  String get documentUploadFailed => 'Upload failed. Please try again.';

  @override
  String get documentUploadNoActiveApplication =>
      'No active application found. Start a new application first.';

  @override
  String get documentUploadIncomplete =>
      'Please upload all required documents before proceeding.';

  @override
  String get documentUploadSomethingWrong =>
      'Something went wrong. Please try again.';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get paymentOrderSummary => 'Order Summary';

  @override
  String get paymentApplicationFee => 'Application Fee';

  @override
  String get paymentTotal => 'Total';

  @override
  String get paymentMethodHeading => 'Payment Method';

  @override
  String get paymentPaystackSubtitle => 'Pay with card, bank transfer or USSD';

  @override
  String get paymentFlutterwaveSubtitle =>
      'Pay with card, bank or mobile money';

  @override
  String get paymentDemoNotice =>
      'This is a demo payment. No real money will be charged. Payment gateway integration coming soon.';

  @override
  String get paymentBiometricReason =>
      'Confirm your fingerprint to complete payment';

  @override
  String get paymentBiometricCancelled => 'Biometric authentication cancelled.';

  @override
  String get paymentSuccessTitle => 'Payment Successful!';

  @override
  String get paymentSuccessBody =>
      'Your application has been submitted successfully. You will be notified of any updates.';

  @override
  String get paymentGoToDashboard => 'Go to Dashboard';

  @override
  String get paymentFailed => 'Payment failed. Please try again.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsClear => 'Clear';

  @override
  String get notificationsClearTitle => 'Clear All';

  @override
  String get notificationsClearBody =>
      'Are you sure you want to delete all notifications? This cannot be undone.';

  @override
  String get notificationsClearConfirm => 'Clear All';

  @override
  String get notificationsEmptyTitle => 'No notifications yet';

  @override
  String get notificationsEmptyBody =>
      'You will be notified when there are updates on your applications';

  @override
  String get notificationsTimeJustNow => 'Just now';

  @override
  String notificationsTimeMinutes(int count) {
    return '${count}m ago';
  }

  @override
  String notificationsTimeHours(int count) {
    return '${count}h ago';
  }

  @override
  String notificationsTimeDays(int count) {
    return '${count}d ago';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System default';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsChangePassword => 'Change Password';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsLogoutTitle => 'Logout';

  @override
  String get settingsLogoutBody =>
      'Are you sure you want to log out of your account?';

  @override
  String get settingsConfirmPasswordTitle => 'Confirm password';

  @override
  String get settingsProfileSection => 'Personal Information';

  @override
  String get settingsSaveChanges => 'Save Changes';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileFullName => 'Full Name';

  @override
  String get profileEmailAddress => 'Email Address';

  @override
  String get profilePhoneNumber => 'Phone Number';

  @override
  String get profileStateOfOrigin => 'State of Origin';

  @override
  String get profileFingerprint => 'Fingerprint sign-in';

  @override
  String get profileFingerprintOn => 'Enabled — sign in without your password';

  @override
  String get profileFingerprintOff => 'Use your fingerprint to sign in faster';

  @override
  String get profileFingerprintUnavailable =>
      'Biometrics are not available on this device';

  @override
  String get profileFingerprintEmailMissing =>
      'Could not determine your account email';

  @override
  String get profileFingerprintWrongPassword =>
      'Incorrect password. Please try again.';

  @override
  String get profileFingerprintEnabledToast => 'Fingerprint sign-in enabled';

  @override
  String get profileFingerprintDisabledToast => 'Fingerprint sign-in disabled';

  @override
  String get profileEnterPassword => 'Enter your password';

  @override
  String get profileEnable => 'Enable';

  @override
  String get profilePhotoUpdateFailed =>
      'Failed to update photo. Please try again.';

  @override
  String get profilePhotoPickFailed =>
      'Failed to pick photo. Please try again.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';
}
