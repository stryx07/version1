// lib/screens/responsable/create_module_screen.dart

import 'package:flutter/material.dart';
import '../../services/admin_service.dart';
import '../../models/module_model.dart';
import 'package:go_router/go_router.dart';

class CreateModuleScreen extends StatefulWidget {
  const CreateModuleScreen({super.key});

  @override
  State<CreateModuleScreen> createState() => _CreateModuleScreenState();
}

class _CreateModuleScreenState extends State<CreateModuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adminService = AdminService();

  String _moduleName = '';
  String _moduleIntitule = '';
  String _semestre = 'S1';
  
  // List of temporary elements built before saving the module
  final List<ElementData> _elements = [];

  bool _isLoading = false;

  void _addElementDialog() {
    final elementFormKey = GlobalKey<FormState>();
    String eCode = '';
    String eNom = '';
    String eProfEmail = '';
    String eProfName = '';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Ajouter un Élément'),
          content: SingleChildScrollView(
            child: Form(
              key: elementFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Code de l\'élément (ex: EL_MATHS)'),
                    validator: (v) => v!.isEmpty ? 'Requis' : null,
                    onSaved: (v) => eCode = v!.trim(),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nom (ex: Mathématiques)'),
                    validator: (v) => v!.isEmpty ? 'Requis' : null,
                    onSaved: (v) => eNom = v!.trim(),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email du Professeur'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (!v!.contains('@')) ? 'Email invalide' : null,
                    onSaved: (v) => eProfEmail = v!.trim(),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Nom du Professeur (Optionnel)'),
                    onSaved: (v) => eProfName = v?.trim() ?? '',
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (elementFormKey.currentState!.validate()) {
                  elementFormKey.currentState!.save();
                  setState(() {
                    _elements.add(ElementData(
                      code: eCode,
                      nom: eNom,
                      professorEmail: eProfEmail,
                      professorName: eProfName.isEmpty ? 'Prof' : eProfName,
                    ));
                  });
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitModule() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_elements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le module doit avoir au moins un élément !'), backgroundColor: Colors.orange),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    final newModule = ModuleData(
      id: _moduleName.replaceAll(' ', '_').toLowerCase(),
      name: _moduleName,
      intitule: _moduleIntitule,
      semestre: _semestre,
      elements: _elements,
    );

    try {
      await _adminService.createModule(newModule);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Module créé avec succès !'), backgroundColor: Colors.green),
      );
      
      // Go back to admin dashboard
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
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
        title: const Text('Nouveau Module'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Informations Globales du module
              const Text(
                'Informations du Module',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD32F2F),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Identifiant du Module (ex: M11)',
                  prefixIcon: Icon(Icons.class_outlined, color: Color(0xFFD32F2F)),
                ),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
                onSaved: (v) => _moduleName = v!.trim(),
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Intitulé Complet (ex: Programmation Mobile)',
                  prefixIcon: Icon(Icons.title, color: Color(0xFFD32F2F)),
                ),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
                onSaved: (v) => _moduleIntitule = v!.trim(),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _semestre,
                decoration: const InputDecoration(
                  labelText: 'Semestre',
                  prefixIcon: Icon(Icons.timeline, color: Color(0xFFD32F2F)),
                ),
                items: ['S1', 'S2', 'S3', 'S4', 'S5', 'S6']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _semestre = val!),
              ),
              const SizedBox(height: 32),

              // Liste des Eléments
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Text(
                    'Éléments du Module',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addElementDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_elements.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: const Text('Aucun élément ajouté. Un module doit avoir au moins un élément (matière).', style: TextStyle(color: Colors.amber, fontSize: 13)),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _elements.length,
                  itemBuilder: (context, index) {
                    final el = _elements[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.book, size: 18)),
                        title: Text('${el.code} : ${el.nom}'),
                        subtitle: Text('Prof: ${el.professorEmail}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => _elements.removeAt(index));
                          },
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 48),

              // Submit Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitModule,
                icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.save),
                label: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Enregistrer le Module'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
