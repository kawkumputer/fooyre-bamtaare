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

class _EditionsData {
  final List<Edition> editions;
  final Map<String, String> coverUrls;
  const _EditionsData(this.editions, this.coverUrls);
}

class _EditionsListScreenState extends State<EditionsListScreen> {
  final _editionService = EditionService();
  final _searchController = TextEditingController();
  late Future<_EditionsData> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
    FocusScope.of(context).unfocus();
  }

  Future<_EditionsData> _load() async {
    final editions = await _editionService.fetchEditions();
    final covers = await _editionService.coverSignedUrls(editions);
    return _EditionsData(editions, covers);
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  /// Filtre par numero ou titre.
  List<Edition> _filter(List<Edition> editions) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return editions;
    return editions
        .where(
          (e) =>
              e.numero.toString().contains(q) ||
              e.titre.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // L'admin et les abonnes ont acces a la version complete.
    final hasFullAccess =
        (widget.profile?.hasActiveSubscription ?? false) ||
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
              child: Icon(
                Icons.menu_book_rounded,
                size: 18,
                color: scheme.onPrimary,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Fooyre Ɓamtaare'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: l10n.searchEditionHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _clearSearch,
                      ),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusScope.of(context).unfocus(),
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<_EditionsData>(
                  future: _future,
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
                    final data = snapshot.data!;
                    final filtered = _filter(data.editions);
                    if (filtered.isEmpty) {
                      return ListView(
                        children: [
                          const SizedBox(height: 80),
                          Icon(
                            Icons.menu_book_outlined,
                            size: 64,
                            color: scheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            data.editions.isEmpty
                                ? l10n.noEditions
                                : l10n.noSearchResult,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      itemCount: filtered.length + (hasFullAccess ? 0 : 1),
                      itemBuilder: (context, index) {
                        if (!hasFullAccess && index == 0) {
                          return const _SubscribeBanner();
                        }
                        final edition =
                            filtered[hasFullAccess ? index : index - 1];
                        return _EditionCard(
                          edition: edition,
                          coverUrl: data.coverUrls[edition.id],
                          hasFullAccess: hasFullAccess,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditionCard extends StatelessWidget {
  final Edition edition;
  final String? coverUrl;
  final bool hasFullAccess;

  const _EditionCard({
    required this.edition,
    required this.coverUrl,
    required this.hasFullAccess,
  });

  void _onTap(BuildContext context, AppLocalizations l10n) {
    // Abonne / admin : ouvre la version complete.
    if (hasFullAccess && edition.hasComplet) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PdfViewerScreen(
            edition: edition,
            pdfPath: edition.pdfComplet!,
            cacheKey: '${edition.id}_complet',
          ),
        ),
      );
      return;
    }
    // Abonne mais pas de PDF complet disponible.
    if (hasFullAccess && !edition.hasComplet) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.editionUnavailable)));
      return;
    }
    // Non-abonne : invitation a s'abonner + contacter l'editeur.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.subscribeDialogTitle),
        content: Text(l10n.subscribeDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final dateStr = DateFormat(
      'd MMMM yyyy',
      'fr',
    ).format(edition.datePublication);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _onTap(context, l10n),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Affiche / la une.
            _Cover(coverUrl: coverUrl, numero: edition.numero),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          edition.titre,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.publishedOn(dateStr),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        if (!hasFullAccess) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 14,
                                color: scheme.tertiary,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  l10n.subscribeForFull,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: scheme.tertiary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    hasFullAccess ? Icons.chevron_right : Icons.lock_outline,
                    color: scheme.outline,
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

/// Affiche l'image de couverture en plein cadre (bord a bord, sans bande
/// grise), ou un aplat avec le numero a defaut.
class _Cover extends StatelessWidget {
  final String? coverUrl;
  final int numero;

  const _Cover({required this.coverUrl, required this.numero});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (coverUrl == null) {
      return AspectRatio(
        aspectRatio: 3 / 2,
        child: Container(
          color: scheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.image_not_supported_outlined,
                color: scheme.outline,
                size: 32,
              ),
              const SizedBox(height: 6),
              Text(
                'N°$numero',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 3 / 2,
      child: Image.network(
        coverUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: scheme.surfaceContainerHighest,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stack) => Container(
          color: scheme.surfaceContainerHighest,
          child: Center(
            child: Icon(Icons.broken_image_outlined, color: scheme.outline),
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
            Icon(
              Icons.workspace_premium_outlined,
              color: scheme.onTertiaryContainer,
            ),
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
