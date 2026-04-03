// lib/models/module_model.dart
// Description: Model classes for Modules, Elements, and Attendance records.

import 'package:cloud_firestore/cloud_firestore.dart';

class ElementData {
  final String code;
  final String nom;
  final String professorEmail;
  final String professorName;

  ElementData({
    required this.code,
    required this.nom,
    required this.professorEmail,
    required this.professorName,
  });

  factory ElementData.fromJson(Map<String, dynamic> json) {
    return ElementData(
      code: json['code'] ?? '',
      nom: json['nom'] ?? '',
      professorEmail: json['professorEmail'] ?? '',
      professorName: json['professorName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'nom': nom,
      'professorEmail': professorEmail,
      'professorName': professorName,
    };
  }
}

class ModuleData {
  final String id;
  final String name;
  final String intitule;
  final String semestre;
  final List<ElementData> elements;

  ModuleData({
    required this.id,
    required this.name,
    required this.intitule,
    required this.semestre,
    required this.elements,
  });

  factory ModuleData.fromJson(String id, Map<String, dynamic> json) {
    final elementsList = json['elements'] as List<dynamic>? ?? [];
    return ModuleData(
      id: id,
      name: json['name'] ?? '',
      intitule: json['intitule'] ?? '',
      semestre: json['semestre'] ?? '',
      elements: elementsList
          .map((e) => ElementData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'intitule': intitule,
      'semestre': semestre,
      'elements': elements.map((e) => e.toJson()).toList(),
    };
  }
}

class AttendanceData {
  final String studentEmail;
  final String elementCode;
  final String elementNom;
  final String date;
  final DateTime timestamp;

  AttendanceData({
    required this.studentEmail,
    required this.elementCode,
    required this.elementNom,
    required this.date,
    required this.timestamp,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    final ts = json['timestamp'];
    DateTime parsedTime = DateTime.now();
    if (ts is Timestamp) {
      parsedTime = ts.toDate();
    }
    
    return AttendanceData(
      studentEmail: json['studentEmail'] ?? '',
      elementCode: json['elementCode'] ?? '',
      elementNom: json['elementNom'] ?? '',
      date: json['date'] ?? '',
      timestamp: parsedTime,
    );
  }
}
