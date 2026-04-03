// lib/main.dart
// Description: App entry point — Firebase initialization and MaterialApp with GoRouter + Material 3 theme.

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'router.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_US', null);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    runApp(const FirebaseErrorApp());
    return;
  }

  runApp(const AttendanceApp());
}

// ─── Main App ─────────────────────────────────────────────────────────────────
class AttendanceApp extends StatelessWidget {
  const AttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Presence by Ilyass',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: AppTheme.lightTheme,
    );
  }
}

// ─── Firebase Error Screen ────────────────────────────────────────────────────
class FirebaseErrorApp extends StatelessWidget {
  const FirebaseErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF1A237E),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 80, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  'Firebase Not Configured',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please update firebase_options.dart with your project credentials to continue using Presence.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'flutterfire configure',
                    style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
