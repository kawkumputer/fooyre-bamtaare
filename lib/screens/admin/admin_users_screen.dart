import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/profile.dart';
import '../../services/admin_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _adminService = AdminService();
  late Future<List<Profile>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _adminService.fetchAllUsers();
  }

  Future<void> _refresh() async {
    setState(() {
      _usersFuture = _adminService.fetchAllUsers();
    });
    await _usersFuture;
  }

  Future<void> _showActivateDialog(Profile user) async {
    final l10n = AppLocalizations.of(context);
    final action = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(
            l10n.subscriptionOf(user.nom.isEmpty ? l10n.noName : user.nom)),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'date'),
            child: Text(user.hasActiveSubscription
                ? l10n.editEndDate
                : l10n.setEndDate),
          ),
          if (user.hasActiveSubscription)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'deactivate'),
              child: Text(
                l10n.deactivateAccess,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
    if (action == null || !mounted) return;

    try {
      if (action == 'deactivate') {
        await _adminService.deactivateSubscription(user);
        await _refresh();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.accessDeactivated)),
          );
        }
        return;
      }

      // action == 'date' : choisir une date de fin.
      final now = DateTime.now();
      final initial = user.hasActiveSubscription && user.subscriptionEnd != null
          ? user.subscriptionEnd!
          : DateTime(now.year, now.month + 3, now.day);
      final endDate = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: now,
        lastDate: DateTime(now.year + 5),
        helpText: l10n.endDateHelp,
      );
      if (endDate == null) return;

      // Fin de journee pour couvrir toute la date choisie.
      final endOfDay =
          DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      await _adminService.activateSubscriptionUntil(user, endOfDay);
      await _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.subUntil(DateFormat('dd/MM/yyyy').format(endDate)),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text(AppLocalizations.of(context).errorWithMessage('$e'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.subscribers)),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Profile>>(
          future: _usersFuture,
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
                    ),
                  ),
                ],
              );
            }
            final users = snapshot.data ?? [];
            // Les abonnements qui expirent bientot en premier.
            users.sort((a, b) {
              if (a.hasActiveSubscription != b.hasActiveSubscription) {
                return a.hasActiveSubscription ? -1 : 1;
              }
              if (a.subscriptionEnd == null || b.subscriptionEnd == null) {
                return 0;
              }
              return a.subscriptionEnd!.compareTo(b.subscriptionEnd!);
            });
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final expiringSoon =
                    user.hasActiveSubscription && user.daysLeft <= 14;
                final avatarColor = user.hasActiveSubscription
                    ? (expiringSoon
                        ? scheme.tertiaryContainer
                        : scheme.primaryContainer)
                    : scheme.surfaceContainerHighest;
                final avatarIconColor = user.hasActiveSubscription
                    ? (expiringSoon
                        ? scheme.onTertiaryContainer
                        : scheme.onPrimaryContainer)
                    : scheme.onSurfaceVariant;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: avatarColor,
                    child: Icon(
                      user.isAdmin
                          ? Icons.admin_panel_settings
                          : Icons.person,
                      color: avatarIconColor,
                    ),
                  ),
                  title: Text(user.nom.isEmpty ? l10n.noName : user.nom),
                  subtitle: Text(
                    [
                      if (user.telephone != null) user.telephone!,
                      if (user.hasActiveSubscription)
                        l10n.expiresOn(dateFormat.format(user.subscriptionEnd!)) +
                            (expiringSoon ? ' (${l10n.expiresSoon})' : '')
                      else
                        l10n.noSubscription,
                    ].join(' — '),
                  ),
                  trailing: const Icon(Icons.edit_outlined),
                  onTap: () => _showActivateDialog(user),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
