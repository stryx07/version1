// lib/screens/responsable/element_history_screen.dart

import 'package:flutter/material.dart';
import '../../models/module_model.dart';
import '../../services/firestore_service.dart';
import 'package:intl/intl.dart';

class ElementHistoryScreen extends StatefulWidget {
  final String elementCode;
  final String elementNom;

  const ElementHistoryScreen({
    super.key,
    required this.elementCode,
    required this.elementNom,
  });

  @override
  State<ElementHistoryScreen> createState() => _ElementHistoryScreenState();
}

class _ElementHistoryScreenState extends State<ElementHistoryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD32F2F),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final displayDate =
        DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(_selectedDate);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(widget.elementNom),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ─── Date selector banner ──────────────────────────────────
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.date_range, color: Color(0xFFD32F2F)),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Date sélectionnée',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            Text(
                              displayDate,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.edit_calendar, color: Colors.grey),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ─── Attendee List ─────────────────────────────────────────
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.history, color: Color(0xFFD32F2F)),
                          SizedBox(width: 8),
                          Text(
                            'Historique des présences',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD32F2F),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: StreamBuilder<List<AttendanceData>>(
                          stream: _firestoreService.getAttendanceForElement(
                              widget.elementCode, dateString),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Erreur : ${snapshot.error}'));
                            }

                            final attendees = snapshot.data ?? [];

                            if (attendees.isEmpty) {
                              return Center(
                                child: Text(
                                  'Aucune présence enregistrée\nle $displayDate.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              );
                            }

                            return ListView.separated(
                              itemCount: attendees.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final att = attendees[index];
                                final timeStr = DateFormat('HH:mm')
                                    .format(att.timestamp);
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: const Color(0xFFD32F2F)
                                        .withOpacity(0.1),
                                    child: const Icon(Icons.person,
                                        size: 16, color: Color(0xFFD32F2F)),
                                  ),
                                  title: Text(att.studentEmail,
                                      style: const TextStyle(fontSize: 14)),
                                  trailing: Text(timeStr,
                                      style: const TextStyle(
                                          color: Colors.grey, fontSize: 12)),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
