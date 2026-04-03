// lib/screens/responsable/responsable_home_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/module_model.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';

class ResponsableHomeScreen extends StatelessWidget {
  const ResponsableHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final firestoreService = FirestoreService();
    final email = authService.currentUser?.email ?? 'Responsable';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        title: Column(
          children: [
            const Text('Administration Pédagogique'),
            Text(email,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w400)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Déconnexion'),
                  content: const Text('Confirmer la déconnexion ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Déconnecter',
                          style: TextStyle(color: Colors.red)),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Créer...'),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (ctx) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Outils d\'Administration',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFD32F2F)),
                    ),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFD32F2F).withOpacity(0.1),
                      child: const Icon(Icons.person_add, color: Color(0xFFD32F2F)),
                    ),
                    title: const Text('Nouvel Utilisateur', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Ajouter un Étudiant ou Professeur'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push('/responsable/create-user');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFD32F2F).withOpacity(0.1),
                      child: const Icon(Icons.my_library_books_rounded, color: Color(0xFFD32F2F)),
                    ),
                    title: const Text('Nouveau Module', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Ajouter un module avec ses éléments'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.push('/responsable/create-module');
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
      body: StreamBuilder<List<ModuleData>>(
        stream: firestoreService.getAllModules(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final modules = snapshot.data ?? [];
          if (modules.isEmpty) {
            return const Center(child: Text('Aucun module trouvé.'));
          }

          // Group by semester
          final mapBySemester = <String, List<ModuleData>>{};
          for (var mod in modules) {
            mapBySemester.putIfAbsent(mod.semestre, () => []).add(mod);
          }

          // Sort semesters (e.g., S5, S6)
          final sortedSemesters = mapBySemester.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedSemesters.length,
            itemBuilder: (context, index) {
              final semestre = sortedSemesters[index];
              final semesterModules = mapBySemester[semestre]!;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  collapsedBackgroundColor: Colors.white,
                  backgroundColor: Colors.grey.shade50,
                  leading: const Icon(Icons.school_outlined,
                      color: Color(0xFFD32F2F)),
                  title: Text(
                    'Semestre $semestre',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                  children: semesterModules.map((mod) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${mod.name} : ${mod.intitule}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          ...mod.elements.map((el) {
                            return ListTile(
                              dense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              leading: const Icon(Icons.book, size: 20),
                              title: Text(el.nom),
                              subtitle: Text('Prof: ${el.professorName}'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                context.push(
                                  '/responsable/history/${Uri.encodeComponent(el.code)}',
                                  extra: {'elementNom': el.nom},
                                );
                              },
                            );
                          }),
                          const Divider(),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
