import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final _searchController = TextEditingController();
  late Future<List<Profile>> _usersFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _usersFuture = _adminService.fetchAllUsers();
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

  /// Filtre par nom (ou prenom) ou telephone.
  List<Profile> _filter(List<Profile> users) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return users;
    return users
        .where(
          (u) =>
              u.nom.toLowerCase().contains(q) ||
              (u.telephone ?? '').toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _usersFuture = _adminService.fetchAllUsers();
    });
    await _usersFuture;
  }

  Future<void> _showActivateDialog(Profile user) async {
    final l10n = AppLocalizations.of(context);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final action = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(
          l10n.subscriptionOf(user.nom.isEmpty ? l10n.noName : user.nom),
        ),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'date'),
            child: Text(
              user.hasActiveSubscription ? l10n.editEndDate : l10n.setEndDate,
            ),
          ),
          if (user.hasActiveSubscription)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'deactivate'),
              child: Text(
                l10n.deactivateAccess,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          // On ne permet pas a l'admin de se supprimer lui-meme ici.
          if (user.id != currentUserId)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'delete'),
              child: Text(
                l10n.deleteUserAccount,
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.accessDeactivated)));
        }
        return;
      }

      if (action == 'delete') {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.deleteUserConfirmTitle),
            content: Text(
              l10n.deleteUserConfirmBody(
                user.nom.isEmpty ? l10n.noName : user.nom,
              ),
            ),
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
        if (confirmed != true || !mounted) return;

        await _adminService.deleteUser(user.id);
        await _refresh();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.userAccountDeleted)));
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
      final endOfDay = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorWithMessage('$e')),
          ),
        );
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: l10n.searchUserHint,
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
                      if (a.subscriptionEnd == null ||
                          b.subscriptionEnd == null) {
                        return 0;
                      }
                      return a.subscriptionEnd!.compareTo(b.subscriptionEnd!);
                    });
                    final filtered = _filter(users);
                    if (filtered.isEmpty) {
                      return ListView(
                        children: [
                          const SizedBox(height: 80),
                          Center(
                            child: Text(
                              users.isEmpty
                                  ? l10n.noEditions
                                  : l10n.noSearchResult,
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final user = filtered[index];
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
                          title: Text(
                            user.nom.isEmpty ? l10n.noName : user.nom,
                          ),
                          subtitle: Text(
                            [
                              if (user.telephone != null) user.telephone!,
                              if (user.hasActiveSubscription)
                                l10n.expiresOn(
                                      dateFormat.format(user.subscriptionEnd!),
                                    ) +
                                    (expiringSoon
                                        ? ' (${l10n.expiresSoon})'
                                        : '')
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
            ),
          ),
        ],
      ),
    );
  }
}
