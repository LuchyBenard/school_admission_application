import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ha.dart';
import 'app_localizations_ig.dart';
import 'app_localizations_yo.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ha'),
    Locale('ig'),
    Locale('yo'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'CampusApply'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your Admission, Simplified'**
  String get appTagline;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get commonRetry;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get commonSubmit;

  /// No description provided for @commonOr.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get commonOr;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSchools.
  ///
  /// In en, this message translates to:
  /// **'Schools'**
  String get navSchools;

  /// No description provided for @navApplications.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get navApplications;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @onboardingTitleFindSchool.
  ///
  /// In en, this message translates to:
  /// **'Find Your Perfect School'**
  String get onboardingTitleFindSchool;

  /// No description provided for @onboardingSubtitleFindSchool.
  ///
  /// In en, this message translates to:
  /// **'Explore thousands of universities and institutions across Nigeria and worldwide all in one place.'**
  String get onboardingSubtitleFindSchool;

  /// No description provided for @onboardingTitleApplyTrack.
  ///
  /// In en, this message translates to:
  /// **'Apply & Track With Ease'**
  String get onboardingTitleApplyTrack;

  /// No description provided for @onboardingSubtitleApplyTrack.
  ///
  /// In en, this message translates to:
  /// **'Submit applications, upload documents, pay fees and get real-time updates on your admission status.'**
  String get onboardingSubtitleApplyTrack;

  /// No description provided for @onboardingTitleGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingTitleGetStarted;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue your admission journey'**
  String get loginSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get loginPasswordHint;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginSignIn;

  /// No description provided for @loginSigningIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get loginSigningIn;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPassword;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get loginCreateAccount;

  /// No description provided for @loginAdminPortal.
  ///
  /// In en, this message translates to:
  /// **'Admin Portal'**
  String get loginAdminPortal;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginFingerprintSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with fingerprint'**
  String get loginFingerprintSignIn;

  /// No description provided for @loginEnableFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Enable fingerprint sign-in'**
  String get loginEnableFingerprint;

  /// No description provided for @loginFingerprintNotRecognised.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint not recognised. Try again or sign in manually.'**
  String get loginFingerprintNotRecognised;

  /// No description provided for @loginNoSavedCredentials.
  ///
  /// In en, this message translates to:
  /// **'No saved credentials found. Sign in manually once first.'**
  String get loginNoSavedCredentials;

  /// No description provided for @loginErrorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get loginErrorEmailRequired;

  /// No description provided for @loginErrorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get loginErrorPasswordRequired;

  /// No description provided for @loginErrorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get loginErrorPasswordTooShort;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join thousands of students applying to their dream schools.'**
  String get signupSubtitle;

  /// No description provided for @signupFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get signupFullNameLabel;

  /// No description provided for @signupFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get signupFullNameHint;

  /// No description provided for @signupEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get signupEmailLabel;

  /// No description provided for @signupEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get signupEmailHint;

  /// No description provided for @signupPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get signupPhoneLabel;

  /// No description provided for @signupPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your digits. e.g 08012345678'**
  String get signupPhoneHint;

  /// No description provided for @signupPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get signupPasswordLabel;

  /// No description provided for @signupPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get signupPasswordHint;

  /// No description provided for @signupConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get signupConfirmPasswordLabel;

  /// No description provided for @signupConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get signupConfirmPasswordHint;

  /// No description provided for @signupButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get signupButton;

  /// No description provided for @signupSignInLink.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signupSignInLink;

  /// No description provided for @signupTermsPrefix.
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get signupTermsPrefix;

  /// No description provided for @signupTermsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get signupTermsAndConditions;

  /// No description provided for @signupPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Private Policy'**
  String get signupPrivacyPolicy;

  /// No description provided for @signupTermsSeparator.
  ///
  /// In en, this message translates to:
  /// **'and '**
  String get signupTermsSeparator;

  /// No description provided for @signupErrorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your first and last name'**
  String get signupErrorNameRequired;

  /// No description provided for @signupErrorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'please enter your email'**
  String get signupErrorEmailRequired;

  /// No description provided for @signupErrorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get signupErrorEmailInvalid;

  /// No description provided for @signupErrorPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'please enter your phone number'**
  String get signupErrorPhoneRequired;

  /// No description provided for @signupErrorPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get signupErrorPhoneInvalid;

  /// No description provided for @signupErrorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'please create a password'**
  String get signupErrorPasswordRequired;

  /// No description provided for @signupErrorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get signupErrorPasswordTooShort;

  /// No description provided for @signupErrorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Password do not match'**
  String get signupErrorPasswordMismatch;

  /// No description provided for @signupErrorConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'please confirm your  password'**
  String get signupErrorConfirmPasswordRequired;

  /// No description provided for @signupErrorTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms and condition to continue.'**
  String get signupErrorTermsRequired;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password.'**
  String get forgotPasswordDescription;

  /// No description provided for @forgotPasswordEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get forgotPasswordEmailLabel;

  /// No description provided for @forgotPasswordEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get forgotPasswordEmailHint;

  /// No description provided for @forgotPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get forgotPasswordButton;

  /// No description provided for @forgotPasswordRememberPassword.
  ///
  /// In en, this message translates to:
  /// **'Remember your password? '**
  String get forgotPasswordRememberPassword;

  /// No description provided for @forgotPasswordSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get forgotPasswordSignIn;

  /// No description provided for @forgotPasswordErrorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get forgotPasswordErrorEmailRequired;

  /// No description provided for @forgotPasswordErrorEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get forgotPasswordErrorEmailInvalid;

  /// No description provided for @otpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get otpTitle;

  /// No description provided for @otpDescription.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit OTP to {email}'**
  String otpDescription(String email);

  /// No description provided for @otpVerifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get otpVerifyButton;

  /// No description provided for @otpResendButton.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get otpResendButton;

  /// No description provided for @otpErrorRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the complete 6-digit  OTP'**
  String get otpErrorRequired;

  /// No description provided for @otpErrorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get otpErrorPasswordRequired;

  /// No description provided for @otpErrorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get otpErrorPasswordTooShort;

  /// No description provided for @otpErrorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get otpErrorPasswordMismatch;

  /// No description provided for @otpErrorConfirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get otpErrorConfirmPasswordRequired;

  /// No description provided for @otpNewPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get otpNewPasswordLabel;

  /// No description provided for @otpNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get otpNewPasswordHint;

  /// No description provided for @otpConfirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get otpConfirmPasswordLabel;

  /// No description provided for @otpConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get otpConfirmPasswordHint;

  /// No description provided for @otpResetPasswordButton.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get otpResetPasswordButton;

  /// No description provided for @emailVerifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get emailVerifyTitle;

  /// No description provided for @emailVerifySentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a verification email to {email}'**
  String emailVerifySentTo(String email);

  /// No description provided for @emailVerifyPasteHint.
  ///
  /// In en, this message translates to:
  /// **'Paste verification code'**
  String get emailVerifyPasteHint;

  /// No description provided for @emailVerifyDescription.
  ///
  /// In en, this message translates to:
  /// **'In the email, copy the code from the verification link and paste it below.'**
  String get emailVerifyDescription;

  /// No description provided for @emailVerifySuccessNote.
  ///
  /// In en, this message translates to:
  /// **'Once verified, you will be taken to your dashboard automatically.'**
  String get emailVerifySuccessNote;

  /// No description provided for @emailVerifyWithCode.
  ///
  /// In en, this message translates to:
  /// **'Verify with code'**
  String get emailVerifyWithCode;

  /// No description provided for @emailVerifyResend.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get emailVerifyResend;

  /// No description provided for @emailVerifySignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get emailVerifySignOut;

  /// No description provided for @emailVerifySentToaster.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent. Check your inbox.'**
  String get emailVerifySentToaster;

  /// No description provided for @emailVerifySuccess.
  ///
  /// In en, this message translates to:
  /// **'Email verified. Welcome aboard!'**
  String get emailVerifySuccess;

  /// No description provided for @emailVerifySendFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send verification email. Please wait a minute and retry.'**
  String get emailVerifySendFailed;

  /// No description provided for @emailVerifyCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code'**
  String get emailVerifyCodeRequired;

  /// No description provided for @emailVerifyCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired verification code.'**
  String get emailVerifyCodeInvalid;

  /// No description provided for @emailVerifyInbox.
  ///
  /// In en, this message translates to:
  /// **'your inbox'**
  String get emailVerifyInbox;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Find and apply to your dream school'**
  String get homeSearchTitle;

  /// No description provided for @homeFindSchools.
  ///
  /// In en, this message translates to:
  /// **'Find Schools'**
  String get homeFindSchools;

  /// No description provided for @homeQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get homeQuickActions;

  /// No description provided for @homeStatsTotalApplied.
  ///
  /// In en, this message translates to:
  /// **'Total Applied'**
  String get homeStatsTotalApplied;

  /// No description provided for @homeStatsUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get homeStatsUnderReview;

  /// No description provided for @homeStatsAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get homeStatsAccepted;

  /// No description provided for @homeStatsRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get homeStatsRejected;

  /// No description provided for @homeMyApplications.
  ///
  /// In en, this message translates to:
  /// **'My Applications'**
  String get homeMyApplications;

  /// No description provided for @homeMyDocuments.
  ///
  /// In en, this message translates to:
  /// **'My Documents'**
  String get homeMyDocuments;

  /// No description provided for @homeSavedSchools.
  ///
  /// In en, this message translates to:
  /// **'Saved Schools'**
  String get homeSavedSchools;

  /// No description provided for @homeFeaturedSchools.
  ///
  /// In en, this message translates to:
  /// **'Featured Schools'**
  String get homeFeaturedSchools;

  /// No description provided for @homeNoApplicationsYet.
  ///
  /// In en, this message translates to:
  /// **'You have no application yet. Apply to a school first.'**
  String get homeNoApplicationsYet;

  /// No description provided for @homeNoSavedSchools.
  ///
  /// In en, this message translates to:
  /// **'No saved schools yet. Tap the heart on any school to save it here.'**
  String get homeNoSavedSchools;

  /// No description provided for @homeRemovedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get homeRemovedFromFavorites;

  /// No description provided for @homeRoleStudent.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get homeRoleStudent;

  /// No description provided for @schoolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Find Schools'**
  String get schoolsTitle;

  /// No description provided for @schoolsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search Schools...'**
  String get schoolsSearchHint;

  /// No description provided for @schoolsListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse thousands of school worldwide'**
  String get schoolsListSubtitle;

  /// No description provided for @schoolsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No schools found'**
  String get schoolsEmptyTitle;

  /// No description provided for @schoolsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try searching with a different name or country'**
  String get schoolsEmptyMessage;

  /// No description provided for @schoolsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load schools'**
  String get schoolsLoadFailed;

  /// No description provided for @schoolsOffline.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again'**
  String get schoolsOffline;

  /// No description provided for @schoolsFeaturedBadge.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get schoolsFeaturedBadge;

  /// No description provided for @schoolsWebsiteAction.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get schoolsWebsiteAction;

  /// No description provided for @schoolsCouldNotOpenWebsite.
  ///
  /// In en, this message translates to:
  /// **'Could not open website'**
  String get schoolsCouldNotOpenWebsite;

  /// No description provided for @schoolsInvalidWebsiteUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid website URL'**
  String get schoolsInvalidWebsiteUrl;

  /// No description provided for @schoolDetailAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get schoolDetailAbout;

  /// No description provided for @schoolDetailLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get schoolDetailLocation;

  /// No description provided for @schoolDetailCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get schoolDetailCountry;

  /// No description provided for @schoolDetailWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get schoolDetailWebsite;

  /// No description provided for @schoolDetailVisitWebsite.
  ///
  /// In en, this message translates to:
  /// **'Visit Website'**
  String get schoolDetailVisitWebsite;

  /// No description provided for @schoolDetailStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get schoolDetailStatus;

  /// No description provided for @schoolDetailDeadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get schoolDetailDeadline;

  /// No description provided for @schoolDetailApplicationFee.
  ///
  /// In en, this message translates to:
  /// **'Application Fee'**
  String get schoolDetailApplicationFee;

  /// No description provided for @schoolDetailApplicationsClosed.
  ///
  /// In en, this message translates to:
  /// **'Applications Closed'**
  String get schoolDetailApplicationsClosed;

  /// No description provided for @schoolDetailApplyNow.
  ///
  /// In en, this message translates to:
  /// **'Apply Now'**
  String get schoolDetailApplyNow;

  /// No description provided for @schoolDetailAdmissionRequirements.
  ///
  /// In en, this message translates to:
  /// **'Admission Requirements'**
  String get schoolDetailAdmissionRequirements;

  /// No description provided for @requirementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Admission Requirements'**
  String get requirementsTitle;

  /// No description provided for @requirementsProgrammesHeading.
  ///
  /// In en, this message translates to:
  /// **'Programmes and cut-off scores'**
  String get requirementsProgrammesHeading;

  /// No description provided for @requirementsRequirementsHeading.
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get requirementsRequirementsHeading;

  /// No description provided for @requirementsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No requirements published yet'**
  String get requirementsEmptyTitle;

  /// No description provided for @requirementsEmptyNote.
  ///
  /// In en, this message translates to:
  /// **'Check the school website or contact the admission office for the latest requirements.'**
  String get requirementsEmptyNote;

  /// No description provided for @requirementsNoCutOff.
  ///
  /// In en, this message translates to:
  /// **'No cut-off published'**
  String get requirementsNoCutOff;

  /// No description provided for @requirementsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load requirements'**
  String get requirementsLoadFailed;

  /// No description provided for @applicationFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Form'**
  String get applicationFormTitle;

  /// No description provided for @applicationFormStepPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get applicationFormStepPersonal;

  /// No description provided for @applicationFormStepPersonalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get applicationFormStepPersonalSubtitle;

  /// No description provided for @applicationFormStepAcademic.
  ///
  /// In en, this message translates to:
  /// **'Academic Details'**
  String get applicationFormStepAcademic;

  /// No description provided for @applicationFormStepAcademicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your educational background'**
  String get applicationFormStepAcademicSubtitle;

  /// No description provided for @applicationFormStepProgramme.
  ///
  /// In en, this message translates to:
  /// **'Programme Selection'**
  String get applicationFormStepProgramme;

  /// No description provided for @applicationFormStepProgrammeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your programme of study'**
  String get applicationFormStepProgrammeSubtitle;

  /// No description provided for @applicationFormFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get applicationFormFullName;

  /// No description provided for @applicationFormFullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get applicationFormFullNameHint;

  /// No description provided for @applicationFormDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get applicationFormDateOfBirth;

  /// No description provided for @applicationFormDateOfBirthHint.
  ///
  /// In en, this message translates to:
  /// **'Select your date of birth'**
  String get applicationFormDateOfBirthHint;

  /// No description provided for @applicationFormGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get applicationFormGender;

  /// No description provided for @applicationFormGenderHint.
  ///
  /// In en, this message translates to:
  /// **'Select gender'**
  String get applicationFormGenderHint;

  /// No description provided for @applicationFormGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get applicationFormGenderMale;

  /// No description provided for @applicationFormGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get applicationFormGenderFemale;

  /// No description provided for @applicationFormGenderPreferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get applicationFormGenderPreferNotToSay;

  /// No description provided for @applicationFormNationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get applicationFormNationality;

  /// No description provided for @applicationFormNationalityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g Nigerian'**
  String get applicationFormNationalityHint;

  /// No description provided for @applicationFormQualification.
  ///
  /// In en, this message translates to:
  /// **'Highest Qualification'**
  String get applicationFormQualification;

  /// No description provided for @applicationFormQualificationHint.
  ///
  /// In en, this message translates to:
  /// **'Select qualification'**
  String get applicationFormQualificationHint;

  /// No description provided for @applicationFormQualificationOLevel.
  ///
  /// In en, this message translates to:
  /// **'WAEC/SSCE'**
  String get applicationFormQualificationOLevel;

  /// No description provided for @applicationFormQualificationNeco.
  ///
  /// In en, this message translates to:
  /// **'NECO'**
  String get applicationFormQualificationNeco;

  /// No description provided for @applicationFormQualificationALevels.
  ///
  /// In en, this message translates to:
  /// **'A-Levels'**
  String get applicationFormQualificationALevels;

  /// No description provided for @applicationFormQualificationOnd.
  ///
  /// In en, this message translates to:
  /// **'OND'**
  String get applicationFormQualificationOnd;

  /// No description provided for @applicationFormQualificationHnd.
  ///
  /// In en, this message translates to:
  /// **'HND'**
  String get applicationFormQualificationHnd;

  /// No description provided for @applicationFormGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get applicationFormGrade;

  /// No description provided for @applicationFormGradeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g 2023'**
  String get applicationFormGradeHint;

  /// No description provided for @applicationFormGraduationYear.
  ///
  /// In en, this message translates to:
  /// **'Graduation Year'**
  String get applicationFormGraduationYear;

  /// No description provided for @applicationFormGraduationYearHint.
  ///
  /// In en, this message translates to:
  /// **'e.g 2023'**
  String get applicationFormGraduationYearHint;

  /// No description provided for @applicationFormJambScore.
  ///
  /// In en, this message translates to:
  /// **'JAMB Score'**
  String get applicationFormJambScore;

  /// No description provided for @applicationFormJambYear.
  ///
  /// In en, this message translates to:
  /// **'JAMB Year'**
  String get applicationFormJambYear;

  /// No description provided for @applicationFormCourseOfStudy.
  ///
  /// In en, this message translates to:
  /// **'Course of Study'**
  String get applicationFormCourseOfStudy;

  /// No description provided for @applicationFormCourseOfStudyHint.
  ///
  /// In en, this message translates to:
  /// **'e.g Computer Science'**
  String get applicationFormCourseOfStudyHint;

  /// No description provided for @applicationFormEntryLevel.
  ///
  /// In en, this message translates to:
  /// **'Entry Level'**
  String get applicationFormEntryLevel;

  /// No description provided for @applicationFormEntryLevelHint.
  ///
  /// In en, this message translates to:
  /// **'Select entry level'**
  String get applicationFormEntryLevelHint;

  /// No description provided for @applicationFormEntryLevelUndergraduate.
  ///
  /// In en, this message translates to:
  /// **'Undergraduate (100 level)'**
  String get applicationFormEntryLevelUndergraduate;

  /// No description provided for @applicationFormEntryLevelDirect.
  ///
  /// In en, this message translates to:
  /// **'Direct Entry (200 level)'**
  String get applicationFormEntryLevelDirect;

  /// No description provided for @applicationFormEntryLevelPostgraduate.
  ///
  /// In en, this message translates to:
  /// **'Postgraduate'**
  String get applicationFormEntryLevelPostgraduate;

  /// No description provided for @applicationFormEntryLevelMasters.
  ///
  /// In en, this message translates to:
  /// **'Masters'**
  String get applicationFormEntryLevelMasters;

  /// No description provided for @applicationFormEntryLevelPhd.
  ///
  /// In en, this message translates to:
  /// **'PhD'**
  String get applicationFormEntryLevelPhd;

  /// No description provided for @applicationFormSession.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get applicationFormSession;

  /// No description provided for @applicationFormSessionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g 2023/2024'**
  String get applicationFormSessionHint;

  /// No description provided for @applicationFormSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Application'**
  String get applicationFormSubmitButton;

  /// No description provided for @applicationFormSaved.
  ///
  /// In en, this message translates to:
  /// **'Application saved! Please upload your documents.'**
  String get applicationFormSaved;

  /// No description provided for @applicationFormSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit application. Please try again.'**
  String get applicationFormSubmitFailed;

  /// No description provided for @applicationFormErrorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get applicationFormErrorNameRequired;

  /// No description provided for @applicationFormErrorDobRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select your date of birth'**
  String get applicationFormErrorDobRequired;

  /// No description provided for @applicationFormErrorGenderRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select your gender'**
  String get applicationFormErrorGenderRequired;

  /// No description provided for @applicationFormErrorNationalityRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your nationality'**
  String get applicationFormErrorNationalityRequired;

  /// No description provided for @applicationFormErrorQualificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select your qualification'**
  String get applicationFormErrorQualificationRequired;

  /// No description provided for @applicationFormErrorGradeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your grade or result'**
  String get applicationFormErrorGradeRequired;

  /// No description provided for @applicationFormErrorGraduationYearRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your graduation year'**
  String get applicationFormErrorGraduationYearRequired;

  /// No description provided for @applicationFormErrorYearInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid year'**
  String get applicationFormErrorYearInvalid;

  /// No description provided for @applicationFormErrorJambScoreRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your JAMB score'**
  String get applicationFormErrorJambScoreRequired;

  /// No description provided for @applicationFormErrorJambScoreInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid JAMB score (0-400)'**
  String get applicationFormErrorJambScoreInvalid;

  /// No description provided for @applicationFormErrorJambYearRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your JAMB year'**
  String get applicationFormErrorJambYearRequired;

  /// No description provided for @applicationFormErrorCourseRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your course of study'**
  String get applicationFormErrorCourseRequired;

  /// No description provided for @applicationFormErrorEntryLevelRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select your entry level'**
  String get applicationFormErrorEntryLevelRequired;

  /// No description provided for @applicationFormErrorSessionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your session'**
  String get applicationFormErrorSessionRequired;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get statusUnderReview;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @statusWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Withdrawn'**
  String get statusWithdrawn;

  /// No description provided for @statusDocsNeeded.
  ///
  /// In en, this message translates to:
  /// **'Docs Needed'**
  String get statusDocsNeeded;

  /// No description provided for @statusMoreDocumentsRequired.
  ///
  /// In en, this message translates to:
  /// **'More Documents Required'**
  String get statusMoreDocumentsRequired;

  /// No description provided for @statusListTitle.
  ///
  /// In en, this message translates to:
  /// **'My Applications'**
  String get statusListTitle;

  /// No description provided for @statusListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track all your admission applications'**
  String get statusListSubtitle;

  /// No description provided for @statusFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get statusFilterAll;

  /// No description provided for @statusEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Applications yet'**
  String get statusEmptyTitle;

  /// No description provided for @statusBrowseSchools.
  ///
  /// In en, this message translates to:
  /// **'Browse Schools'**
  String get statusBrowseSchools;

  /// No description provided for @statusLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load applications'**
  String get statusLoadFailed;

  /// No description provided for @applicationDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Application Details'**
  String get applicationDetailTitle;

  /// No description provided for @applicationDetailSchoolInfo.
  ///
  /// In en, this message translates to:
  /// **'School Information'**
  String get applicationDetailSchoolInfo;

  /// No description provided for @applicationDetailPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get applicationDetailPersonalInfo;

  /// No description provided for @applicationDetailAcademicInfo.
  ///
  /// In en, this message translates to:
  /// **'Academic Details'**
  String get applicationDetailAcademicInfo;

  /// No description provided for @applicationDetailProgrammeInfo.
  ///
  /// In en, this message translates to:
  /// **'Programme Details'**
  String get applicationDetailProgrammeInfo;

  /// No description provided for @applicationDetailSubmissionInfo.
  ///
  /// In en, this message translates to:
  /// **'Submission Information'**
  String get applicationDetailSubmissionInfo;

  /// No description provided for @applicationDetailRowSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get applicationDetailRowSchool;

  /// No description provided for @applicationDetailRowCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get applicationDetailRowCountry;

  /// No description provided for @applicationDetailRowFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get applicationDetailRowFullName;

  /// No description provided for @applicationDetailRowDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get applicationDetailRowDateOfBirth;

  /// No description provided for @applicationDetailRowGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get applicationDetailRowGender;

  /// No description provided for @applicationDetailRowNationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get applicationDetailRowNationality;

  /// No description provided for @applicationDetailRowQualification.
  ///
  /// In en, this message translates to:
  /// **'Qualification'**
  String get applicationDetailRowQualification;

  /// No description provided for @applicationDetailRowGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade/Result'**
  String get applicationDetailRowGrade;

  /// No description provided for @applicationDetailRowGraduationYear.
  ///
  /// In en, this message translates to:
  /// **'Graduation Year'**
  String get applicationDetailRowGraduationYear;

  /// No description provided for @applicationDetailRowCourseOfStudy.
  ///
  /// In en, this message translates to:
  /// **'Course of Study'**
  String get applicationDetailRowCourseOfStudy;

  /// No description provided for @applicationDetailRowEntryLevel.
  ///
  /// In en, this message translates to:
  /// **'Entry Level'**
  String get applicationDetailRowEntryLevel;

  /// No description provided for @applicationDetailRowSession.
  ///
  /// In en, this message translates to:
  /// **'Session'**
  String get applicationDetailRowSession;

  /// No description provided for @applicationDetailRowDateSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Date Submitted'**
  String get applicationDetailRowDateSubmitted;

  /// No description provided for @applicationDetailRowStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get applicationDetailRowStatus;

  /// No description provided for @applicationDetailSubmittedRecently.
  ///
  /// In en, this message translates to:
  /// **'Recently'**
  String get applicationDetailSubmittedRecently;

  /// No description provided for @applicationDetailCardSubmittedRecently.
  ///
  /// In en, this message translates to:
  /// **'Submitted recently'**
  String get applicationDetailCardSubmittedRecently;

  /// No description provided for @applicationDetailWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Application'**
  String get applicationDetailWithdraw;

  /// No description provided for @applicationDetailReapply.
  ///
  /// In en, this message translates to:
  /// **'Re-apply'**
  String get applicationDetailReapply;

  /// No description provided for @applicationDetailDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete Application'**
  String get applicationDetailDelete;

  /// No description provided for @applicationDetailWithdrawConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Application'**
  String get applicationDetailWithdrawConfirmTitle;

  /// No description provided for @applicationDetailWithdrawConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to withdraw your application to {school}? You can re-apply later.'**
  String applicationDetailWithdrawConfirmBody(String school);

  /// No description provided for @applicationDetailDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Application'**
  String get applicationDetailDeleteConfirmTitle;

  /// No description provided for @applicationDetailDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your application to {school}? This cannot be undone.'**
  String applicationDetailDeleteConfirmBody(String school);

  /// No description provided for @applicationDetailWithdrawAction.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get applicationDetailWithdrawAction;

  /// No description provided for @applicationDetailWithdrawn.
  ///
  /// In en, this message translates to:
  /// **'Application withdrawn'**
  String get applicationDetailWithdrawn;

  /// No description provided for @applicationDetailWithdrawFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to withdraw application'**
  String get applicationDetailWithdrawFailed;

  /// No description provided for @applicationDetailDeleted.
  ///
  /// In en, this message translates to:
  /// **'Application deleted'**
  String get applicationDetailDeleted;

  /// No description provided for @applicationDetailDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete application'**
  String get applicationDetailDeleteFailed;

  /// No description provided for @documentUploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Document Upload'**
  String get documentUploadTitle;

  /// No description provided for @documentUploadRequiredHeading.
  ///
  /// In en, this message translates to:
  /// **'Required Documents'**
  String get documentUploadRequiredHeading;

  /// No description provided for @documentUploadUploadAll.
  ///
  /// In en, this message translates to:
  /// **'Upload all 4 documents to proceed'**
  String get documentUploadUploadAll;

  /// No description provided for @documentUploadFormatNote.
  ///
  /// In en, this message translates to:
  /// **'All documents must be clear and readable. Accepted formats: JPG, PNG.'**
  String get documentUploadFormatNote;

  /// No description provided for @documentUploadProceedToPayment.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get documentUploadProceedToPayment;

  /// No description provided for @documentUploadChooseSource.
  ///
  /// In en, this message translates to:
  /// **'Choose Source'**
  String get documentUploadChooseSource;

  /// No description provided for @documentUploadChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get documentUploadChooseFromGallery;

  /// No description provided for @documentUploadTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get documentUploadTakePhoto;

  /// No description provided for @documentUploadReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get documentUploadReplace;

  /// No description provided for @documentUploadUpload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get documentUploadUpload;

  /// No description provided for @documentUploadAllDone.
  ///
  /// In en, this message translates to:
  /// **'All Done'**
  String get documentUploadAllDone;

  /// No description provided for @documentUploadRequiredAll.
  ///
  /// In en, this message translates to:
  /// **'Required: all 4'**
  String get documentUploadRequiredAll;

  /// No description provided for @documentUploadWaecTitle.
  ///
  /// In en, this message translates to:
  /// **'WAEC/NECO Result'**
  String get documentUploadWaecTitle;

  /// No description provided for @documentUploadWaecSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload your O-level result'**
  String get documentUploadWaecSubtitle;

  /// No description provided for @documentUploadJambTitle.
  ///
  /// In en, this message translates to:
  /// **'JAMB Result'**
  String get documentUploadJambTitle;

  /// No description provided for @documentUploadJambSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload your JAMB result slip'**
  String get documentUploadJambSubtitle;

  /// No description provided for @documentUploadPassportTitle.
  ///
  /// In en, this message translates to:
  /// **'Passport Photo'**
  String get documentUploadPassportTitle;

  /// No description provided for @documentUploadPassportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload a recent passport-sized photo'**
  String get documentUploadPassportSubtitle;

  /// No description provided for @documentUploadBirthCertTitle.
  ///
  /// In en, this message translates to:
  /// **'Birth Certificate'**
  String get documentUploadBirthCertTitle;

  /// No description provided for @documentUploadBirthCertSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload your birth certificate'**
  String get documentUploadBirthCertSubtitle;

  /// No description provided for @documentUploadPickFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick file. Please try again.'**
  String get documentUploadPickFailed;

  /// No description provided for @documentUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed. Please try again.'**
  String get documentUploadFailed;

  /// No description provided for @documentUploadNoActiveApplication.
  ///
  /// In en, this message translates to:
  /// **'No active application found. Start a new application first.'**
  String get documentUploadNoActiveApplication;

  /// No description provided for @documentUploadIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Please upload all required documents before proceeding.'**
  String get documentUploadIncomplete;

  /// No description provided for @documentUploadSomethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get documentUploadSomethingWrong;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentTitle;

  /// No description provided for @paymentOrderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get paymentOrderSummary;

  /// No description provided for @paymentApplicationFee.
  ///
  /// In en, this message translates to:
  /// **'Application Fee'**
  String get paymentApplicationFee;

  /// No description provided for @paymentTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get paymentTotal;

  /// No description provided for @paymentMethodHeading.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethodHeading;

  /// No description provided for @paymentPaystackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay with card, bank transfer or USSD'**
  String get paymentPaystackSubtitle;

  /// No description provided for @paymentFlutterwaveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay with card, bank or mobile money'**
  String get paymentFlutterwaveSubtitle;

  /// No description provided for @paymentDemoNotice.
  ///
  /// In en, this message translates to:
  /// **'This is a demo payment. No real money will be charged. Payment gateway integration coming soon.'**
  String get paymentDemoNotice;

  /// No description provided for @paymentBiometricReason.
  ///
  /// In en, this message translates to:
  /// **'Confirm your fingerprint to complete payment'**
  String get paymentBiometricReason;

  /// No description provided for @paymentBiometricCancelled.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication cancelled.'**
  String get paymentBiometricCancelled;

  /// No description provided for @paymentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessTitle;

  /// No description provided for @paymentSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'Your application has been submitted successfully. You will be notified of any updates.'**
  String get paymentSuccessBody;

  /// No description provided for @paymentGoToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Go to Dashboard'**
  String get paymentGoToDashboard;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed. Please try again.'**
  String get paymentFailed;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get notificationsClear;

  /// No description provided for @notificationsClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get notificationsClearTitle;

  /// No description provided for @notificationsClearBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all notifications? This cannot be undone.'**
  String get notificationsClearBody;

  /// No description provided for @notificationsClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get notificationsClearConfirm;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'You will be notified when there are updates on your applications'**
  String get notificationsEmptyBody;

  /// No description provided for @notificationsTimeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notificationsTimeJustNow;

  /// No description provided for @notificationsTimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String notificationsTimeMinutes(int count);

  /// No description provided for @notificationsTimeHours.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String notificationsTimeHours(int count);

  /// No description provided for @notificationsTimeDays.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String notificationsTimeDays(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePassword;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogoutTitle;

  /// No description provided for @settingsLogoutBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your account?'**
  String get settingsLogoutBody;

  /// No description provided for @settingsConfirmPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get settingsConfirmPasswordTitle;

  /// No description provided for @settingsProfileSection.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get settingsProfileSection;

  /// No description provided for @settingsSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get settingsSaveChanges;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get profileFullName;

  /// No description provided for @profileEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get profileEmailAddress;

  /// No description provided for @profilePhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profilePhoneNumber;

  /// No description provided for @profileStateOfOrigin.
  ///
  /// In en, this message translates to:
  /// **'State of Origin'**
  String get profileStateOfOrigin;

  /// No description provided for @profileFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint sign-in'**
  String get profileFingerprint;

  /// No description provided for @profileFingerprintOn.
  ///
  /// In en, this message translates to:
  /// **'Enabled — sign in without your password'**
  String get profileFingerprintOn;

  /// No description provided for @profileFingerprintOff.
  ///
  /// In en, this message translates to:
  /// **'Use your fingerprint to sign in faster'**
  String get profileFingerprintOff;

  /// No description provided for @profileFingerprintUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Biometrics are not available on this device'**
  String get profileFingerprintUnavailable;

  /// No description provided for @profileFingerprintEmailMissing.
  ///
  /// In en, this message translates to:
  /// **'Could not determine your account email'**
  String get profileFingerprintEmailMissing;

  /// No description provided for @profileFingerprintWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get profileFingerprintWrongPassword;

  /// No description provided for @profileFingerprintEnabledToast.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint sign-in enabled'**
  String get profileFingerprintEnabledToast;

  /// No description provided for @profileFingerprintDisabledToast.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint sign-in disabled'**
  String get profileFingerprintDisabledToast;

  /// No description provided for @profileEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get profileEnterPassword;

  /// No description provided for @profileEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get profileEnable;

  /// No description provided for @profilePhotoUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update photo. Please try again.'**
  String get profilePhotoUpdateFailed;

  /// No description provided for @profilePhotoPickFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick photo. Please try again.'**
  String get profilePhotoPickFailed;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'es',
    'fr',
    'ha',
    'ig',
    'yo',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ha':
      return AppLocalizationsHa();
    case 'ig':
      return AppLocalizationsIg();
    case 'yo':
      return AppLocalizationsYo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
