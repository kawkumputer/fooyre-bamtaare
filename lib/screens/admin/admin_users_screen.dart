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
    final months = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Abonnement de ${user.nom.isEmpty ? "(sans nom)" : user.nom}'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 3),
            child: const Text('Activer 3 mois'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 5),
            child: const Text('Activer 5 mois'),
          ),
          if (user.hasActiveSubscription)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, -1),
              child: Text(
                'Desactiver l\'acces',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
    if (months == null) return;

    try {
      if (months == -1) {
        await _adminService.deactivateSubscription(user);
      } else {
        await _adminService.activateSubscription(user, months);
      }
      await _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              months == -1
                  ? 'Acces desactive.'
                  : 'Abonnement de $months mois active.',
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
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user.hasActiveSubscription
                        ? (expiringSoon
                            ? Colors.orange.shade200
                            : Colors.green.shade200)
                        : Colors.grey.shade300,
                    child: Icon(
                      user.isAdmin
                          ? Icons.admin_panel_settings
                          : Icons.person,
                      color: Colors.black54,
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
