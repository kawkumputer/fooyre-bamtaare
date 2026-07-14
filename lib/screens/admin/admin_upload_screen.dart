import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/edition.dart';
import '../../services/admin_service.dart';
import '../../services/edition_service.dart';

enum _CoverSource { gallery, files }

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

  Uint8List? _coverBytes;
  String? _coverFileName;
  PlatformFile? _pdfFile;
  DateTime _datePublication = DateTime.now();
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

  Future<PlatformFile?> _pickFile(List<String> extensions) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      return result.files.first;
    }
    return null;
  }

  /// Propose de choisir l'affiche depuis la galerie photos ou l'app
  /// Fichiers (l'ancien comportement, limite aux documents/Fichiers seul).
  Future<void> _pickCoverImage() async {
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context);
    final source = await showModalBottomSheet<_CoverSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.chooseFromGallery),
              onTap: () => Navigator.pop(context, _CoverSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(l10n.chooseFromFiles),
              onTap: () => Navigator.pop(context, _CoverSource.files),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    if (source == _CoverSource.gallery) {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _coverBytes = bytes;
        _coverFileName = picked.name;
      });
    } else {
      final f = await _pickFile(['jpg', 'jpeg', 'png', 'webp']);
      if (f != null) {
        setState(() {
          _coverBytes = f.bytes;
          _coverFileName = f.name;
        });
      }
    }
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _datePublication.isAfter(now) ? now : _datePublication,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      helpText: AppLocalizations.of(context).publicationDate,
    );
    if (picked != null) setState(() => _datePublication = picked);
  }

  Future<void> _publish() async {
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_coverBytes == null || _pdfFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.coverAndPdfRequired)));
      return;
    }

    setState(() => _uploading = true);
    try {
      await _adminService.publishEdition(
        numero: int.parse(_numeroController.text.trim()),
        titre: _titreController.text.trim(),
        datePublication: _datePublication,
        coverBytes: _coverBytes!,
        coverExt: _coverFileName?.split('.').last,
        completBytes: _pdfFile!.bytes!,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.editionPublished)));
        setState(() {
          _coverBytes = null;
          _coverFileName = null;
          _pdfFile = null;
          _datePublication = DateTime.now();
          _numeroController.clear();
          _titreController.clear();
        });
        _reloadEditions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorWithMessage('$e'))));
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _confirmDelete(Edition edition) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteEditionTitle),
        content: Text(l10n.deleteEditionBody(edition.numero, edition.titre)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _adminService.deleteEdition(edition);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.editionDeleted)));
        _reloadEditions();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorWithMessage('$e'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.publishEdition)),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
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
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.editionNumber,
                        hintText: l10n.editionNumberHint,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || int.tryParse(v.trim()) == null
                          ? l10n.invalidNumber
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titreController,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                      decoration: InputDecoration(
                        labelText: l10n.title,
                        hintText: l10n.titleHint,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? l10n.titleRequired
                          : null,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(
                        '${l10n.publicationDate} : '
                        '${DateFormat('dd/MM/yyyy').format(_datePublication)}',
                      ),
                      onPressed: _uploading ? null : _pickDate,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.image_outlined),
                      label: Text(
                        _coverFileName ?? l10n.chooseCoverImage,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: _uploading ? null : _pickCoverImage,
                    ),
                    if (_coverBytes != null) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _coverBytes!,
                          height: 160,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: Text(
                        _pdfFile == null ? l10n.chooseFullPdf : _pdfFile!.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onPressed: _uploading
                          ? null
                          : () async {
                              final f = await _pickFile(['pdf']);
                              if (f != null) setState(() => _pdfFile = f);
                            },
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
                      label: Text(_uploading ? l10n.publishing : l10n.publish),
                      onPressed: _uploading ? null : _publish,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                l10n.publishedEditions,
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
    final l10n = AppLocalizations.of(context);
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
                Text(l10n.loadErrorEditions),
                TextButton(onPressed: onRetry, child: Text(l10n.retry)),
              ],
            ),
          );
        }
        final editions = snapshot.data ?? [];
        if (editions.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.noEditionsYet),
          );
        }
        return Column(
          children: editions.map((edition) {
            final dateStr = DateFormat(
              'MMMM yyyy',
              'fr',
            ).format(edition.datePublication);
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: Text('${edition.numero}'),
                ),
                title: Text(edition.titre),
                subtitle: Text(
                  '$dateStr — '
                  '${[if (edition.hasCover) l10n.coverLabel, if (edition.hasComplet) l10n.editionComplete].join(' + ')}',
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  tooltip: l10n.delete,
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
