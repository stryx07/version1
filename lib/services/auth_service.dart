// lib/services/auth_service.dart
// Description: Handles Firebase Authentication (signIn, signOut, role fetch, currentUser).

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Current user getter ───────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;

  // ─── Auth state stream (used by GoRouter redirect) ─────────────────────────
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Sign in with email & password ─────────────────────────────────────────
  /// Returns null on success, or a human-readable error message.
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      return _mapFirebaseError(e.code);
    } catch (_) {
      return 'Une erreur inattendue s\'est produite. Réessayez.';
    }
  }

  // ─── Fetch user role from Firestore ────────────────────────────────────────
  /// Returns "teacher", "student", or null if doc not found.
  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return doc.data()?['role'] as String?;
    } catch (_) {
      return null;
    }
  }

  // ─── Sign out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ─── Human-readable Firebase error messages ────────────────────────────────
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Aucun compte trouvé pour cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez dans quelques minutes.';
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'network-request-failed':
        return 'Erreur réseau. Vérifiez votre connexion internet.';
      default:
        return 'Erreur de connexion ($code). Contactez l\'administrateur.';
    }
  }

  // ─── [DEV ONLY] Générer les comptes de test et les modules ───────────────────
  Future<String?> createTestAccounts() async {
    try {
      // 1. Professeur
      try {
        final profCred = await _auth.createUserWithEmailAndPassword(
            email: 'prof@univ.dz', password: 'password123');
        await _db.collection('users').doc(profCred.user!.uid).set({
          'email': 'prof@univ.dz',
          'role': 'professeur',
        });
      } on FirebaseAuthException catch (e) {
        if (e.code != 'email-already-in-use') rethrow;
      }

      // 2. Étudiant
      try {
        final studentCred = await _auth.createUserWithEmailAndPassword(
            email: 'etudiant@univ.dz', password: 'password123');
        await _db.collection('users').doc(studentCred.user!.uid).set({
          'email': 'etudiant@univ.dz',
          'role': 'etudiant',
        });
      } on FirebaseAuthException catch (e) {
        if (e.code != 'email-already-in-use') rethrow;
      }

      // 3. Responsable
      try {
        final respCred = await _auth.createUserWithEmailAndPassword(
            email: 'admin@univ.dz', password: 'password123');
        await _db.collection('users').doc(respCred.user!.uid).set({
          'email': 'admin@univ.dz',
          'role': 'responsable',
        });
      } on FirebaseAuthException catch (e) {
        if (e.code != 'email-already-in-use') rethrow;
      }

      // 4. Créer des modules fictifs (S5 et S6)
      final batch = _db.batch();
      
      final mod1 = _db.collection('modules').doc('M_S5_01');
      batch.set(mod1, {
        'name': 'Module S5 01',
        'intitule': 'Développement Web & Mobile',
        'semestre': 'S5',
        'elements': [
          {
            'code': 'EL_FLUTTER',
            'nom': 'Programmation Mobile Flutter',
            'professorEmail': 'prof@univ.dz',
            'professorName': 'Dr. Professeur',
          },
          {
            'code': 'EL_REACT',
            'nom': 'Architecture Web React',
            'professorEmail': 'autre@univ.dz',
            'professorName': 'Dr. Autre',
          }
        ]
      });

      final mod2 = _db.collection('modules').doc('M_S6_01');
      batch.set(mod2, {
        'name': 'Module S6 01',
        'intitule': 'Intelligence Artificielle',
        'semestre': 'S6',
        'elements': [
          {
            'code': 'EL_AI_GEN',
            'nom': 'IA Générative et LLMs',
            'professorEmail': 'prof@univ.dz',
            'professorName': 'Dr. Professeur',
          }
        ]
      });

      await batch.commit();

      // Déconnecter
      await _auth.signOut();
      return null;
    } catch (e) {
      return 'Erreur génération : $e';
    }
  }
}

