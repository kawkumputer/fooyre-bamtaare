import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/edition.dart';
import '../../services/admin_service.dart';
import '../../services/edition_service.dart';

class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numeroController = TextEditingController();
  final _titreController = TextEditingController();
  final _adminService = AdminService();
  final _editionService = EditionService();

  PlatformFile? _pickedFile;
  bool _gratuit = false;
  bool _uploading = false;
  late Future<List<Edition>> _editionsFuture;

  @override
  void initState() {
    super.initState();
    _editionsFuture = _editionService.fetchEditions();
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _titreController.dispose();
    super.dispose();
  }

  void _reloadEditions() {
    setState(() {
      _editionsFuture = _editionService.fetchEditions();
    });
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) return;
    final file = _pickedFile;
    if (file == null || file.bytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez d\'abord un fichier PDF.')),
      );
      return;
    }

    setState(() => _uploading = true);
    try {
      await _adminService.publishEdition(
        numero: int.parse(_numeroController.text.trim()),
        titre: _titreController.text.trim(),
        gratuit: _gratuit,
        pdfBytes: file.bytes!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edition publiee !')),
        );
        setState(() {
          _pickedFile = null;
          _numeroController.clear();
          _titreController.clear();
          _gratuit = false;
        });
        _reloadEditions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _confirmDelete(Edition edition) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette edition ?'),
        content: Text(
          'N°${edition.numero} — ${edition.titre}\n\n'
          'Le fichier PDF et l\'edition seront supprimes '
          'definitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _adminService.deleteEdition(edition);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edition supprimee.')),
        );
        _reloadEditions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publier une edition')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _numeroController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Numero de l\'edition',
                      hintText: 'ex : 262',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || int.tryParse(v.trim()) == null
                            ? 'Numero invalide'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titreController,
                    decoration: const InputDecoration(
                      labelText: 'Titre',
                      hintText: 'ex : Fooyre Ɓamtaare 262',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Titre requis' : null,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Edition gratuite'),
                    subtitle: const Text(
                      'Accessible a tous, meme sans abonnement',
                    ),
                    value: _gratuit,
                    onChanged: (v) => setState(() => _gratuit = v),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                      _pickedFile == null
                          ? 'Choisir le fichier PDF'
                          : _pickedFile!.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onPressed: _uploading ? null : _pickPdf,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: _uploading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload_outlined),
                    label: Text(_uploading ? 'Publication...' : 'Publier'),
                    onPressed: _uploading ? null : _publish,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Editions publiees',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _EditionsAdminList(
              future: _editionsFuture,
              onDelete: _confirmDelete,
              onRetry: _reloadEditions,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditionsAdminList extends StatelessWidget {
  final Future<List<Edition>> future;
  final void Function(Edition) onDelete;
  final VoidCallback onRetry;

  const _EditionsAdminList({
    required this.future,
    required this.onDelete,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Edition>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Erreur de chargement des editions.'),
                TextButton(onPressed: onRetry, child: const Text('Reessayer')),
              ],
            ),
          );
        }
        final editions = snapshot.data ?? [];
        if (editions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Aucune edition publiee pour le moment.'),
          );
        }
        return Column(
          children: editions.map((edition) {
            final dateStr =
                DateFormat('MMMM yyyy', 'fr').format(edition.datePublication);
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Text('${edition.numero}'),
                ),
                title: Text(edition.titre),
                subtitle: Text(
                  '$dateStr — ${edition.gratuit ? "Gratuit" : "Abonnes"}',
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  tooltip: 'Supprimer',
                  onPressed: () => onDelete(edition),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
