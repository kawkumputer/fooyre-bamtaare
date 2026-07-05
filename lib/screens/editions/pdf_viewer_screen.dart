import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../l10n/app_localizations.dart';
import '../../models/edition.dart';
import '../../services/edition_service.dart';

class PdfViewerScreen extends StatefulWidget {
  final Edition edition;

  const PdfViewerScreen({super.key, required this.edition});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  final _editionService = EditionService();
  late Future<File> _pdfFuture;

  @override
  void initState() {
    super.initState();
    _pdfFuture = _editionService.getLocalPdf(widget.edition);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('N°${widget.edition.numero} — ${widget.edition.titre}'),
      ),
      body: FutureBuilder<File>(
        future: _pdfFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.downloadingEdition),
                ],
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      l10n.pdfOpenError,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => setState(() {
                        _pdfFuture =
                            _editionService.getLocalPdf(widget.edition);
                      }),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }
          return PdfViewer.file(snapshot.data!.path);
        },
      ),
    );
  }
}
