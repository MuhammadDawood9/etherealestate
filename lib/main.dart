import 'dart:ui';
import 'dart:io'; // Added for Platform checking
import 'package:flutter/foundation.dart'; // Added for kIsWeb checking
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/constants/app_routes.dart';
import 'core/services/notification_service.dart';
import 'features/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/search/search_home_screen.dart';
import 'features/search/interactive_map_screen.dart';
import 'features/property/property_feed_screen.dart';
import 'features/profile/my_collection_screen.dart';
import 'features/profile/account_settings_screen.dart';
import 'features/profile/agent_profile_screen.dart';
import 'features/admin/admin_shell.dart';
import 'features/property/property_details_screen.dart';
import 'features/seller/seller_dashboard_screen.dart';
import 'core/utils/fade_scale_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('dotenv load error: $e');
  }
  
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // --- UPDATED ERROR HANDLING ---
  FlutterError.onError = (errorDetails) {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    } else {
      FlutterError.dumpErrorToConsole(errorDetails);
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    } else {
      debugPrint('Unhandled Error: $error');
    }
    return true;
  };
  // ------------------------------

  ErrorWidget.builder = (FlutterErrorDetails details) => Material(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Something went wrong.\nPlease restart the app.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    ),
  );

  NotificationService().initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ethereal Estate',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4C54B6),
          surface: const Color(0xFFF8F9FA),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        AppRoutes.login:      (context) => const LoginScreen(),
        AppRoutes.signup:     (context) => const SignupScreen(),
        AppRoutes.feed:       (context) => PropertyFeedScreen(),
        AppRoutes.search:     (context) => const SearchHomeScreen(),
        AppRoutes.map:        (context) => const InteractiveMapScreen(),
        AppRoutes.collection: (context) => const MyCollectionScreen(),
        AppRoutes.profile:    (context) => const AccountSettingsScreen(),
        AppRoutes.agent:      (context) => const AgentProfileScreen(),
        AppRoutes.admin:      (context) => const AdminShell(),
        '/seller':            (context) => const SellerDashboardScreen(),
      },
      // Handles deep links: /property/<propertyId>
      onGenerateRoute: (settings) {
        final name = settings.name ?? '';
        if (name.startsWith('${AppRoutes.propertyDetail}/')) {
          final id = name.substring('${AppRoutes.propertyDetail}/'.length);
          if (id.isNotEmpty) {
            return FadeScaleRoute(
              page: PropertyDetailsScreen(propertyId: id),
            );
          }
        }
        return null;
      },
    );
  }
}