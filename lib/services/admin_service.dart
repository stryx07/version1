// lib/services/admin_service.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
import '../models/module_model.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a new user (Etudiant/Prof) without signing out the current Admin
  /// by using a secondary Firebase App instance.
  Future<void> createUser({
    required String email,
    required String password,
    required String role,
  }) async {
    FirebaseApp? tempApp;
    try {
      // 1. Initialize a temporary Firebase App
      tempApp = await Firebase.initializeApp(
        name: 'TemporaryAuthApp',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // 2. Use the temporary app's Auth instance to create the user
      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
      final userCredential = await tempAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw Exception("Échec de la récupération de l'UID.");
      }

      // 3. Write user role to main Firestore instance
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Cet email est déjà utilisé par un autre compte.');
      } else if (e.code == 'weak-password') {
        throw Exception('Le mot de passe est trop faible (minimum 6 caractères).');
      } else {
        throw Exception('Erreur Auth: ${e.message}');
      }
    } finally {
      // 4. Clean up the temporary app so it doesn't leak memory
      if (tempApp != null) {
        await tempApp.delete();
      }
    }
  }

  /// Creates a new Module in Firestore
  Future<void> createModule(ModuleData module) async {
    try {
      // Use the 'name' as Document ID to avoid duplicates
      // e.g., "Programmation Web"
      final docId = module.name.replaceAll(' ', '_').toLowerCase();
      
      await _firestore.collection('modules').doc(docId).set(module.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la création du module : $e');
    }
  }
}
