// lib/router.dart
// Description: GoRouter configuration with auth-based redirect and all app routes.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/login_screen.dart';
import 'screens/teacher/teacher_home_screen.dart';
import 'screens/teacher/subject_qr_screen.dart';
import 'screens/student/student_home_screen.dart';
import 'screens/student/scanner_screen.dart';
import 'screens/student/confirmation_screen.dart';
import 'screens/responsable/responsable_home_screen.dart';
import 'screens/responsable/element_history_screen.dart';
import 'screens/responsable/create_user_screen.dart';
import 'screens/responsable/create_module_screen.dart';
import 'services/auth_service.dart';

final AuthService _authService = AuthService();

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  // ─── Auth redirect logic ──────────────────────────────────────────────────
  redirect: (BuildContext context, GoRouterState state) async {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    final isOnLoginPage = state.matchedLocation == '/login';

    if (!isLoggedIn && !isOnLoginPage) {
      return '/login';
    }

    if (isLoggedIn && isOnLoginPage) {
      // Fetch role and redirect accordingly
      final role = await _authService.getUserRole(user.uid);
      if (role == 'professeur') return '/teacher';
      if (role == 'etudiant') return '/student';
      if (role == 'responsable') return '/responsable';
    }

    return null; // no redirect needed
  },

  // ─── Route definitions ────────────────────────────────────────────────────
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: LoginScreen(),
      ),
    ),

    // Teacher routes
    GoRoute(
      path: '/teacher',
      name: 'teacher-home',
      pageBuilder: (context, state) => const MaterialPage(
        child: TeacherHomeScreen(),
      ),
      routes: [
        GoRoute(
          path: 'qr/:code',
          name: 'teacher-qr',
          pageBuilder: (context, state) {
            final code = Uri.decodeComponent(state.pathParameters['code'] ?? '');
            final args = state.extra as Map<String, dynamic>? ?? {};
            final nom = args['elementNom'] as String? ?? code;
            return MaterialPage(
              child: SubjectQrScreen(elementCode: code, elementNom: nom),
            );
          },
        ),
      ],
    ),

    // Student routes
    GoRoute(
      path: '/student',
      name: 'student-home',
      pageBuilder: (context, state) => const MaterialPage(
        child: StudentHomeScreen(),
      ),
      routes: [
        GoRoute(
          path: 'scan',
          name: 'scanner',
          pageBuilder: (context, state) => const MaterialPage(
            child: ScannerScreen(),
          ),
        ),
        GoRoute(
          path: 'confirm',
          name: 'confirmation',
          pageBuilder: (context, state) {
            // Extrait passe sous la forme { "elementNom": "XXX" }
            final args = state.extra as Map<String, dynamic>? ?? {};
            final elementNom = args['elementNom'] as String? ?? 'Inconnu';
            return MaterialPage(
              child: ConfirmationScreen(elementNom: elementNom),
            );
          },
        ),
      ],
    ),

    // Responsable routes
    GoRoute(
      path: '/responsable',
      name: 'responsable-home',
      pageBuilder: (context, state) => const MaterialPage(
        child: ResponsableHomeScreen(),
      ),
      routes: [
        GoRoute(
          path: 'history/:code',
          name: 'responsable-history',
          pageBuilder: (context, state) {
            final code = Uri.decodeComponent(state.pathParameters['code'] ?? '');
            final args = state.extra as Map<String, dynamic>? ?? {};
            final nom = args['elementNom'] as String? ?? code;
            return MaterialPage(
              child: ElementHistoryScreen(elementCode: code, elementNom: nom),
            );
          },
        ),
        GoRoute(
          path: 'create-user',
          name: 'responsable-create-user',
          pageBuilder: (context, state) => const MaterialPage(
            child: CreateUserScreen(),
          ),
        ),
        GoRoute(
          path: 'create-module',
          name: 'responsable-create-module',
          pageBuilder: (context, state) => const MaterialPage(
            child: CreateModuleScreen(),
          ),
        ),
      ],
    ),
  ],

  // ─── Error page ───────────────────────────────────────────────────────────
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Page introuvable',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Retour à la connexion'),
          ),
        ],
      ),
    ),
  ),
);
