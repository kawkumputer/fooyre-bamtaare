import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final hasSubscription = widget.profile?.hasActiveSubscription ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Fooyre Tonngoode')),
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
                      'Erreur de chargement.\nTirez vers le bas pour reessayer.',
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
                    hasSubscription
                        ? 'Aucune edition disponible pour le moment.'
                        : 'Aucune edition gratuite disponible.\n'
                            'Abonnez-vous pour acceder au journal.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              );
            }
            return ListView.builder(
              itemCount: editions.length + (hasSubscription ? 0 : 1),
              itemBuilder: (context, index) {
                // Banniere d'invitation a s'abonner pour les non-abonnes.
                if (!hasSubscription && index == 0) {
                  return _SubscribeBanner(profile: widget.profile);
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
    final dateStr =
        DateFormat('MMMM yyyy', 'fr').format(edition.datePublication);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text('${edition.numero}'),
        ),
        title: Text(edition.titre),
        subtitle: Text(dateStr),
        trailing: edition.gratuit
            ? Chip(
                label: const Text('Gratuit'),
                visualDensity: VisualDensity.compact,
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
              )
            : const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PdfViewerScreen(edition: edition),
          ),
        ),
      ),
    );
  }
}

class _SubscribeBanner extends StatelessWidget {
  final Profile? profile;

  const _SubscribeBanner({this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Abonnez-vous a Fooyre Tonngoode',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Pour lire toutes les editions, contactez l\'editeur pour '
              'un abonnement de 3 ou 5 mois (Bankily, Wave, virement...). '
              'Votre acces sera active des reception du paiement.',
            ),
          ],
        ),
      ),
    );
  }
}
