// lib/services/firestore_service.dart
// Description: V2 Firestore operations with structured Module queries and atomic attendance registration.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/module_model.dart';

enum AttendanceResult { success, duplicate, error }

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Today's date as "yyyy-MM-dd" ─────────────────────────────────────────
  String get todayDate => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // ─── Professeur : Obtenir mes éléments ─────────────────────────────────────
  /// Query modules and return sub-elements assigned to this professor email.
  Future<List<ElementData>> getMyElements(String email) async {
    final modulesSnapshot = await _db.collection('modules').get();
    List<ElementData> myElements = [];

    for (var doc in modulesSnapshot.docs) {
      final module = ModuleData.fromJson(doc.id, doc.data());
      for (var element in module.elements) {
        if (element.professorEmail == email) {
          myElements.add(element);
        }
      }
    }
    return myElements;
  }

  // ─── Responsable : Stream de tous les modules ──────────────────────────────
  Stream<List<ModuleData>> getAllModules() {
    return _db.collection('modules').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ModuleData.fromJson(doc.id, doc.data()))
          .toList();
    });
  }

  // ─── Tous : Stream de présences pour un élément et une date ────────────────
  Stream<List<AttendanceData>> getAttendanceForElement(
      String code, String date) {
    return _db
        .collection('attendance')
        .where('elementCode', isEqualTo: code)
        .where('date', isEqualTo: date)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => AttendanceData.fromJson(doc.data()))
          .toList();
      list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return list;
    });
  }

  // ─── Étudiant : Récupérer le nom de l'élément à partir du code QR ─────────
  Future<String?> getElementNomByCode(String code) async {
    final snapshot = await _db.collection('modules').get();
    for (var doc in snapshot.docs) {
      final module = ModuleData.fromJson(doc.id, doc.data());
      for (var element in module.elements) {
        if (element.code == code) return element.nom;
      }
    }
    return null; // Invalid QR code or element not found
  }

  // ─── Étudiant : Marquer présence (Transaction Atomique) ────────────────────
  /// Uses a transaction with a deterministic document ID to guarantee atomicity
  /// and robust anti-duplicate protection (1 scan per day per element per student).
  Future<AttendanceResult> markAttendance(
      String studentEmail, String elementCode, String elementNom) async {
    try {
      final tDate = todayDate;
      // Deterministic ID ensures no parallel writes can duplicate
      final docId = '${studentEmail}_${elementCode}_$tDate';
      final docRef = _db.collection('attendance').doc(docId);

      final success = await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (snapshot.exists) {
          throw Exception('Duplicate in transaction'); // Cancel transaction
        }

        transaction.set(docRef, {
          'studentEmail': studentEmail,
          'elementCode': elementCode,
          'elementNom': elementNom,
          'date': tDate,
          'timestamp': FieldValue.serverTimestamp(),
        });
        return true;
      });

      return success ? AttendanceResult.success : AttendanceResult.error;
    } catch (e) {
      if (e.toString().contains('Duplicate')) {
        return AttendanceResult.duplicate;
      }
      return AttendanceResult.error;
    }
  }
}
