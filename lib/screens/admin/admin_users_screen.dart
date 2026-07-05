import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final action = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title:
            Text('Abonnement de ${user.nom.isEmpty ? "(sans nom)" : user.nom}'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 'date'),
            child: Text(user.hasActiveSubscription
                ? 'Modifier la date de fin...'
                : 'Definir la date de fin...'),
          ),
          if (user.hasActiveSubscription)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'deactivate'),
              child: Text(
                'Desactiver l\'acces',
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
            const SnackBar(content: Text('Acces desactive.')),
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
        helpText: 'Date de fin de l\'abonnement',
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
              'Abonnement actif jusqu\'au '
              '${DateFormat('dd/MM/yyyy').format(endDate)}.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Abonnes')),
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
                children: const [
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Erreur de chargement.\nTirez vers le bas pour reessayer.',
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
                  title: Text(user.nom.isEmpty ? '(sans nom)' : user.nom),
                  subtitle: Text(
                    [
                      if (user.telephone != null) user.telephone!,
                      if (user.hasActiveSubscription)
                        'Expire ${dateFormat.format(user.subscriptionEnd!)}'
                            '${expiringSoon ? " (bientot !)" : ""}'
                      else
                        'Pas d\'abonnement',
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
