import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../services/admin_service.dart';

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

  PlatformFile? _pickedFile;
  bool _gratuit = false;
  bool _uploading = false;

  @override
  void dispose() {
    _numeroController.dispose();
    _titreController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publier une edition')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
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
                ),
                validator: (v) => v == null || int.tryParse(v.trim()) == null
                    ? 'Numero invalide'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titreController,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  hintText: 'ex : Fooyre Ɓamtaare 262',
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
      ),
    );
  }
}
