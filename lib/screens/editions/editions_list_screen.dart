import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/edition.dart';
import '../../models/profile.dart';
import '../../services/edition_service.dart';
import 'pdf_viewer_screen.dart';

class EditionsListScreen extends StatefulWidget {
  final Profile? profile;

  const EditionsListScreen({super.key, this.profile});

  @override
  State<EditionsListScreen> createState() => _EditionsListScreenState();
}

class _EditionsListScreenState extends State<EditionsListScreen> {
  final _editionService = EditionService();
  late Future<List<Edition>> _editionsFuture;

  @override
  void initState() {
    super.initState();
    _editionsFuture = _editionService.fetchEditions();
  }

  Future<void> _refresh() async {
    setState(() {
      _editionsFuture = _editionService.fetchEditions();
    });
    await _editionsFuture;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // L'admin a acces a tout : on le traite comme un abonne (pas de
    // banniere d'invitation a s'abonner).
    final hasSubscription = (widget.profile?.hasActiveSubscription ?? false) ||
        (widget.profile?.isAdmin ?? false);

    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [scheme.primary, scheme.primaryContainer],
                ),
              ),
              child: Icon(Icons.menu_book_rounded,
                  size: 18, color: scheme.onPrimary),
            ),
            const SizedBox(width: 10),
            const Text('Fooyre Ɓamtaare'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Edition>>(
          future: _editionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      l10n.loadError,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              );
            }
            final editions = snapshot.data ?? [];
            if (editions.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 80),
                  Icon(
                    Icons.menu_book_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hasSubscription ? l10n.noEditions : l10n.noFreeEditions,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 12),
              itemCount: editions.length + (hasSubscription ? 0 : 1),
              itemBuilder: (context, index) {
                // Banniere d'invitation a s'abonner pour les non-abonnes.
                if (!hasSubscription && index == 0) {
                  return const _SubscribeBanner();
                }
                final edition =
                    editions[hasSubscription ? index : index - 1];
                return _EditionTile(edition: edition);
              },
            );
          },
        ),
      ),
    );
  }
}

class _EditionTile extends StatelessWidget {
  final Edition edition;

  const _EditionTile({required this.edition});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateStr =
        DateFormat('MMMM yyyy', 'fr').format(edition.datePublication);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PdfViewerScreen(edition: edition),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [scheme.primary, scheme.primaryContainer],
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${edition.numero}',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      edition.titre,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (edition.gratuit)
                Chip(
                  label: Text(AppLocalizations.of(context).free),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: scheme.secondaryContainer,
                  labelStyle: TextStyle(
                    color: scheme.onSecondaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                Icon(Icons.chevron_right, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubscribeBanner extends StatelessWidget {
  const _SubscribeBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.all(12),
      color: scheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.workspace_premium_outlined,
                color: scheme.onTertiaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.subscribeTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: scheme.onTertiaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.subscribeBody,
                    style: TextStyle(color: scheme.onTertiaryContainer),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
