// lib/screens/student/student_home_screen.dart
// Description: Student home screen — displays email, shows scan button, and sign-out option.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final email = authService.currentUser?.email ?? 'Student';
    // Extract display name from email (before @)
    final displayName = email.split('@').first;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Presence Student', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF1A237E)),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  title: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
                  content: const Text('Ready to leave Presence?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Not yet', style: TextStyle(color: Colors.grey)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Sign Out', style: TextStyle(color: Color(0xFFFF1744), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await authService.signOut();
                if (context.mounted) context.go('/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ─── Modern Welcome card ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF00B8D4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A237E).withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_circle_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome, $displayName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // ─── Scan Section ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E).withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.qr_code_scanner_rounded, size: 40, color: Color(0xFF1A237E)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ready to Check-in?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A237E),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Scan the QR code displayed by your instructor to log your attendance instantly.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  Container(
                    height: 64,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00B8D4).withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => context.push('/student/scan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B8D4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_rounded),
                          SizedBox(width: 12),
                          Text('Open Scanner', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ─── Help Section ───────────────────────────────────────────────
            _InfoCard(
              icon: Icons.lightbulb_outline_rounded,
              title: 'Quick Tip',
              description:
                  'Ensure your brightness is up and the QR code is within the guide marks for faster scanning.',
              color: const Color(0xFF1A237E),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16, color: color)),
                const SizedBox(height: 6),
                Text(description,
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade500,
                        height: 1.5,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
