import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_text_styles.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'package:get_storage/get_storage.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'providers/auth_provider.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'providers/school_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return OKToast(
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => AuthProvider()),
              ChangeNotifierProvider(create: (_) => SchoolProvider()),
            ],
            child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'School Admission',
                theme: ThemeData(
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: AppColors.primary,
                    primary: AppColors.primary,
                    surface: AppColors.surface,
                    error: AppColors.error,
                  ),

                  // Fonts
                  fontFamily: 'Inter',

                  // App theme
                  appBarTheme: AppBarTheme(
                    backgroundColor: AppColors.background,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    centerTitle: true,
                    titleTextStyle: AppTextStyles.h2,
                  ),

                  // Button theme
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  // Input field theme
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: AppColors.surface,
                    hintStyle: AppTextStyles.hint,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.error),
                    ),
                  ),

                  // Scaffold background
                  scaffoldBackgroundColor: AppColors.background,

                  // Divider theme
                  dividerTheme: DividerThemeData(
                    color: AppColors.divider,
                    thickness: 1,
                  ),
                ),
                // app routing
                initialRoute: '/',
                routes: {
                  '/': (context) => SplashScreen(),
                  '/onboarding': (context) => OnboardingScreen(),
                  '/login': (context) => LoginScreen(),
                  '/register': (context) => SignupScreen(),
                  '/dashboard': (context) => DashboardScreen(),
                },
            ),
          ),
        );
      },
    );
  }
}
