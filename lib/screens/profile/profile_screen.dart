import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../main.dart' show localeController;
import '../../models/profile.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/subscribe_contact_actions.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Profile? profile;
  final VoidCallback onSignedOut;
  final VoidCallback onProfileUpdated;

  const ProfileScreen({
    super.key,
    required this.profile,
    required this.onSignedOut,
    required this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final p = profile;
    final dateFormat = DateFormat('dd MMMM yyyy', 'fr');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myProfile)),
      body: p == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    Text(l10n.loadError, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: onProfileUpdated,
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(p.nom.isEmpty ? l10n.noName : p.nom),
                    subtitle: Text(p.telephone ?? l10n.noPhone),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: l10n.editProfile,
                      onPressed: () async {
                        final updated = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(
                              profile: p,
                              email: AuthService().currentUser?.email,
                            ),
                          ),
                        );
                        if (updated == true) onProfileUpdated();
                      },
                    ),
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
                            const SizedBox(height: 12),
                            const SubscribeContactActions(),
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
                  const SizedBox(height: 8),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.bug_report_outlined),
                      title: const Text('Debug : jeton notifications (FCM)'),
                      subtitle: const Text('Diagnostic temporaire push iOS'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showFcmTokenDialog(context),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.lock_reset_outlined),
                    title: Text(l10n.changePassword),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    ),
                  ),
                ),
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
                const SizedBox(height: 12),
                TextButton.icon(
                  icon: Icon(
                    Icons.delete_forever_outlined,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  label: Text(
                    l10n.deleteMyAccount,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  onPressed: () => _confirmDeleteAccount(context, l10n),
                ),
              ],
            ),
    );
  }

  Future<void> _confirmDeleteAccount(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMyAccountConfirmTitle),
        content: Text(l10n.deleteMyAccountConfirmBody),
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
      await AuthService().deleteMyAccount();
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.myAccountDeleted)));
        onSignedOut();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorWithMessage('$e'))));
      }
    }
  }

  Future<void> _showFcmTokenDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jeton FCM de cet appareil'),
        content: FutureBuilder<String?>(
          future: NotificationService().debugFcmToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 60,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final token = snapshot.data;
            if (token == null) {
              return const Text('Jeton indisponible.');
            }
            return SelectableText(token, style: const TextStyle(fontSize: 12));
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          FilledButton(
            onPressed: () async {
              final token = await NotificationService().debugFcmToken();
              if (token != null) {
                await Clipboard.setData(ClipboardData(text: token));
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Copier'),
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
