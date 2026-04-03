// lib/screens/login_screen.dart
// Description: Login screen with email/password form, validation, role-based redirect, and loading overlay.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _showPassword = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Seed Database ────────────────────────────────────────────────────────
  Future<void> _handleCreateTestAccounts() async {
    setState(() => _isLoading = true);
    final error = await _authService.createTestAccounts();
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Comptes prof@univ.dz et etudiant@univ.dz créés (mdp: password123) !'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ─── Sign in handler ────────────────────────────────────────────────────────
  Future<void> _handleSignIn() async {
    // Clear previous error
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await _authService.signIn(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
      return;
    }

    // Fetch role and navigate
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Utilisateur introuvable. Contactez l\'administrateur.';
      });
      return;
    }

    final role = await _authService.getUserRole(uid);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (role == 'professeur') {
      context.go('/teacher');
    } else if (role == 'etudiant') {
      context.go('/student');
    } else if (role == 'responsable') {
      context.go('/responsable');
    } else {
      setState(() {
        _errorMessage =
            'Rôle non défini. Contactez l\'administrateur Firebase.';
      });
      await _authService.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),

                  // ─── Logo ────────────────────────────────────────────────
                  const Center(child: AppLogo()),
                  const SizedBox(height: 48),

                  // ─── Title ───────────────────────────────────────────────
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1A237E),
                          letterSpacing: -1,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your Presence account',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // ─── Email Field ─────────────────────────────────────────
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'name@example.com',
                      prefixIcon: const Icon(Icons.alternate_email_rounded, color: Color(0xFF1A237E)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email.';
                      }
                      final emailRegex =
                          RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid email.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ─── Password Field ──────────────────────────────────────
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSignIn(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_rounded, color: Color(0xFF1A237E)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: Colors.grey.shade400,
                        ),
                        onPressed: () =>
                            setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot Password?', 
                        style: TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── Sign in button ──────────────────────────────────────
                  Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A237E).withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A237E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Sign In', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(width: 12),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ─── Info footer ─────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00B8D4).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.security_rounded,
                                  color: Color(0xFF00B8D4),
                                  size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Secure Attendance System',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A237E),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Powered by presence0-fc30f security infrastructure.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // ─── Bouton DEV (Créer les comptes auto) ─────────────────
                  Center(
                    child: TextButton.icon(
                      onPressed: _isLoading ? null : _handleCreateTestAccounts,
                      icon: const Icon(Icons.bolt_rounded, size: 18),
                      label: const Text('Setup Demo Environment'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF00B8D4),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
