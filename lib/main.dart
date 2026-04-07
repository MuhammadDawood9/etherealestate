import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure you have configured Firebase using FlutterFire CLI 
  // and have the firebase_options.dart file if you want to run this.
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // For now, initializing without options assuming standard config is present
  // or will be added by the user.
  await Firebase.initializeApp(); 

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ethereal Estate',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4C54B6),
          background: const Color(0xFFF8F9FA),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
