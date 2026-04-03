// lib/screens/teacher/subject_qr_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/module_model.dart';
import 'package:intl/intl.dart';

class SubjectQrScreen extends StatelessWidget {
  final String elementCode;
  final String elementNom;

  const SubjectQrScreen({super.key, required this.elementCode, required this.elementNom});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    final todayFormatted =
        DateFormat('EEEE, MMM d, yyyy').format(DateTime.now());
    final dateQuery = firestoreService.todayDate;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(elementNom, 
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: -0.5)),
              centerTitle: true,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // ─── QR Code Section ──────────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A237E).withValues(alpha: 0.05),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today_rounded, color: Color(0xFF00B8D4), size: 16),
                            const SizedBox(width: 8),
                            Text(
                              todayFormatted.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF00B8D4),
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.shade100, width: 2),
                          ),
                          child: QrImageView(
                            data: elementCode,
                            version: QrVersions.auto,
                            size: 240,
                            backgroundColor: Colors.white,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.circle,
                              color: Color(0xFF1A237E),
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.circle,
                              color: Color(0xFF00B8D4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A237E).withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            'CODE: $elementCode',
                            style: const TextStyle(
                              color: Color(0xFF1A237E),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ─── Real-time Attendance Section ────────────────────────────────
                  Row(
                    children: [
                      const Icon(Icons.hub_rounded, color: Color(0xFF1A237E), size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Live Attendance',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1A237E),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      StreamBuilder<List<AttendanceData>>(
                        stream: firestoreService.getAttendanceForElement(elementCode, dateQuery),
                        builder: (context, snapshot) {
                          final count = snapshot.data?.length ?? 0;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B8D4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$count Active',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  StreamBuilder<List<AttendanceData>>(
                    stream: firestoreService.getAttendanceForElement(elementCode, dateQuery),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Padding(
                          padding: EdgeInsets.all(40),
                          child: CircularProgressIndicator(color: Color(0xFF1A237E)),
                        ));
                      }
                      if (snapshot.hasError) return _errorWidget(snapshot.error.toString());
                      final attendees = snapshot.data ?? [];
                      if (attendees.isEmpty) return _emptyWidget();

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: attendees.length,
                        itemBuilder: (context, index) {
                          final entry = attendees[index];
                          return _AttendeeRow(
                            index: index + 1,
                            email: entry.studentEmail,
                            time: DateFormat('HH:mm').format(entry.timestamp),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.waves_rounded, size: 48, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            'Waiting for check-ins...',
            style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _errorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF1744).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text('Service Interrupted: $error', style: const TextStyle(color: Color(0xFFFF1744), fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }
}

class _AttendeeRow extends StatelessWidget {
  final int index;
  final String email;
  final String time;

  const _AttendeeRow({required this.index, required this.email, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E).withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(color: Color(0xFF1A237E), fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1A237E)),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Checked in at $time',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                )
              ],
            ),
          ),
          const Icon(Icons.verified_user_rounded, color: Color(0xFF00C853), size: 20),
        ],
      ),
    );
  }
}
