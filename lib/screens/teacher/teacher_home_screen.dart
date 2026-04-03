// lib/screens/teacher/teacher_home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/module_model.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final email = authService.currentUser?.email ?? 'Professor';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: const Color(0xFF1A237E),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text('Dashboard', 
                style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF3949AB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Icon(Icons.school_rounded, size: 150, color: Colors.white.withValues(alpha: 0.1)),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
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
                          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                    'Welcome back,',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    email,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1A237E), letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Your Assigned Modules',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A237E)),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            sliver: FutureBuilder<List<ElementData>>(
              future: FirestoreService().getMyElements(email),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(child: Center(child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: Color(0xFF1A237E)),
                  )));
                }
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(child: Center(child: Text('Service Unreachable: ${snapshot.error}')));
                }
                final elements = snapshot.data ?? [];
                
                if (elements.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_off_rounded, size: 64, color: Colors.grey.shade200),
                          const SizedBox(height: 16),
                          Text('No modules assigned yet.', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final element = elements[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1A237E).withValues(alpha: 0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(24),
                              onTap: () {
                                context.push(
                                  '/teacher/qr/${Uri.encodeComponent(element.code)}',
                                  extra: {'elementNom': element.nom},
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1A237E).withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: const Icon(Icons.auto_stories_rounded, color: Color(0xFF1A237E), size: 28),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            element.nom,
                                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF1A237E)),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'CODE: ${element.code}',
                                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w900),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF00B8D4).withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.qr_code_rounded, color: Color(0xFF00B8D4), size: 22),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: elements.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
