// lib/screens/responsable/create_user_screen.dart

import 'package:flutter/material.dart';
import '../../services/admin_service.dart';

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adminService = AdminService();

  String _email = '';
  String _password = '';
  String _role = 'etudiant'; // default

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      await _adminService.createUser(
        email: _email,
        password: _password,
        role: _role,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Succès : Utilisateur $_email créé en tant que $_role!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Clear form except role
      _formKey.currentState!.reset();
      setState(() {
        _email = '';
        _password = '';
      });
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Ajouter un Utilisateur'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Créer un étudiant ou un enseignant',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Les identifiants seront inscrits dans Firebase Auth et le rôle assigné dans Firestore.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Rôle Dropdown
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(
                  labelText: 'Rôle',
                  prefixIcon: Icon(Icons.badge, color: Color(0xFFD32F2F)),
                ),
                items: const [
                  DropdownMenuItem(value: 'etudiant', child: Text('Étudiant')),
                  DropdownMenuItem(value: 'professeur', child: Text('Professeur')),
                  DropdownMenuItem(value: 'responsable', child: Text('Responsable')),
                ],
                onChanged: (value) {
                  setState(() {
                    _role = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: Color(0xFFD32F2F)),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Veuillez entrer un email valide.';
                  }
                  return null;
                },
                onSaved: (value) => _email = value!.trim(),
              ),
              const SizedBox(height: 16),

              // Mot de passe
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Mot de passe provisoire',
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFD32F2F)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Minimum 6 caractères requis.';
                  }
                  return null;
                },
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 32),

              // Bouton 
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Créer l\'utilisateur'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
