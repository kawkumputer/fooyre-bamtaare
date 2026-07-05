import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../main.dart' show localeController;
import '../../models/profile.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  final Profile? profile;
  final VoidCallback onSignedOut;

  const ProfileScreen({
    super.key,
    required this.profile,
    required this.onSignedOut,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = profile;
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myProfile)),
      body: p == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(p.nom.isEmpty ? l10n.noName : p.nom),
                    subtitle: Text(p.telephone ?? l10n.noPhone),
                  ),
                ),
                if (!p.isAdmin) ...[
                  const SizedBox(height: 8),
                  Card(
                    color: p.hasActiveSubscription
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                p.hasActiveSubscription
                                    ? Icons.check_circle_outline
                                    : Icons.info_outline,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                p.hasActiveSubscription
                                    ? l10n.subActive
                                    : l10n.subInactive,
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (p.hasActiveSubscription) ...[
                            Text(
                              l10n.subExpiresOn(
                                dateFormat.format(p.subscriptionEnd!),
                                p.daysLeft,
                              ),
                            ),
                          ] else ...[
                            Text(l10n.subscribeContact),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                if (p.isAdmin) ...[
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.admin_panel_settings_outlined),
                      title: Text(l10n.adminAccount),
                      subtitle: Text(l10n.adminUnlimited),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                _LanguageCard(l10n: l10n),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: Text(l10n.signOut),
                  onPressed: () async {
                    await AuthService().signOut();
                    onSignedOut();
                  },
                ),
              ],
            ),
    );
  }
}

/// Carte de choix de langue (pulaar / francais), avec bascule a chaud.
class _LanguageCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _LanguageCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.language),
                const SizedBox(width: 8),
                Text(l10n.language,
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<Locale>(
              valueListenable: localeController,
              builder: (context, locale, _) {
                return SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'ff', label: Text('Pulaar')),
                    ButtonSegment(value: 'fr', label: Text('Français')),
                  ],
                  selected: {locale.languageCode},
                  onSelectionChanged: (sel) =>
                      localeController.setLocale(Locale(sel.first)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
