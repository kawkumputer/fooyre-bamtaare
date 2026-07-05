import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final p = profile;
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr');

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: p == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(p.nom.isEmpty ? '(sans nom)' : p.nom),
                    subtitle: Text(p.telephone ?? 'Pas de telephone'),
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
                                    ? 'Abonnement actif'
                                    : 'Pas d\'abonnement actif',
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (p.hasActiveSubscription) ...[
                            Text(
                              'Expire le ${dateFormat.format(p.subscriptionEnd!)} '
                              '(${p.daysLeft} jours restants)',
                            ),
                          ] else ...[
                            const Text(
                              'Pour vous abonner, contactez l\'editeur du '
                              'journal (Bankily, Wave, virement...). Votre '
                              'acces sera active des reception du paiement.',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
                if (p.isAdmin) ...[
                  const SizedBox(height: 8),
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.admin_panel_settings_outlined),
                      title: Text('Compte administrateur'),
                      subtitle: Text('Acces illimite a toutes les editions'),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Se deconnecter'),
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
