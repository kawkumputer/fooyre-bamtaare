import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/profile.dart';
import '../../models/subscription_period.dart';
import '../../services/admin_service.dart';

/// Gestion des periodes d'abonnement d'un utilisateur (plusieurs
/// periodes non contigues possibles : l'acces a une edition depend de
/// sa date de parution tombant dans au moins une d'elles).
class AdminSubscriptionScreen extends StatefulWidget {
  final Profile user;

  const AdminSubscriptionScreen({super.key, required this.user});

  @override
  State<AdminSubscriptionScreen> createState() =>
      _AdminSubscriptionScreenState();
}

class _AdminSubscriptionScreenState extends State<AdminSubscriptionScreen> {
  final _adminService = AdminService();
  late List<SubscriptionPeriod> _periods;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _periods = List.of(widget.user.periods)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  Future<void> _refresh() async {
    final users = await _adminService.fetchAllUsers();
    Profile? updated;
    for (final u in users) {
      if (u.id == widget.user.id) {
        updated = u;
        break;
      }
    }
    final resolved = updated;
    if (resolved != null && mounted) {
      setState(() {
        _periods = List.of(resolved.periods)
          ..sort((a, b) => b.startDate.compareTo(a.startDate));
      });
    }
  }

  Future<void> _addPeriod() async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final start = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
      helpText: l10n.periodStartDate,
    );
    if (start == null || !mounted) return;

    final end = await showDatePicker(
      context: context,
      initialDate: DateTime(start.year, start.month + 1, start.day),
      firstDate: start,
      lastDate: DateTime(now.year + 5),
      helpText: l10n.periodEndDate,
    );
    if (end == null) return;

    if (end.isBefore(start)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.invalidPeriodRange)));
      }
      return;
    }

    setState(() => _busy = true);
    try {
      await _adminService.addSubscriptionPeriod(widget.user.id, start, end);
      await _refresh();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.periodAdded)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorWithMessage('$e'))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDeletePeriod(SubscriptionPeriod period) async {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePeriodConfirmTitle),
        content: Text(
          l10n.deletePeriodConfirmBody(
            dateFormat.format(period.startDate),
            dateFormat.format(period.endDate),
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

    setState(() => _busy = true);
    try {
      await _adminService.deleteSubscriptionPeriod(period.id);
      await _refresh();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.periodDeleted)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorWithMessage('$e'))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _endActivePeriod(SubscriptionPeriod period) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      await _adminService.endActivePeriodNow(period);
      await _refresh();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.accessDeactivated)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorWithMessage('$e'))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy');
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.subscriptionOf(
            widget.user.nom.isEmpty ? l10n.noName : widget.user.nom,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.subscriptionPeriods,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_periods.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(l10n.noPeriodsYet),
            )
          else
            ..._periods.map((period) {
              final isActive = period.covers(now);
              return Card(
                color: isActive ? scheme.primaryContainer : null,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.event_available_outlined,
                    color: isActive ? scheme.onPrimaryContainer : null,
                  ),
                  title: Text(
                    '${dateFormat.format(period.startDate)} '
                    '→ ${dateFormat.format(period.endDate)}',
                    style: TextStyle(
                      color: isActive ? scheme.onPrimaryContainer : null,
                    ),
                  ),
                  subtitle: isActive
                      ? Text(
                          l10n.activePeriodBadge,
                          style: TextStyle(color: scheme.onPrimaryContainer),
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isActive)
                        IconButton(
                          icon: Icon(
                            Icons.block_outlined,
                            color: scheme.onPrimaryContainer,
                          ),
                          tooltip: l10n.deactivateAccess,
                          onPressed: _busy ? null : () => _endActivePeriod(period),
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: isActive ? scheme.onPrimaryContainer : scheme.error,
                        ),
                        tooltip: l10n.delete,
                        onPressed: _busy ? null : () => _confirmDeletePeriod(period),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: Text(l10n.addPeriod),
            onPressed: _busy ? null : _addPeriod,
          ),
        ],
      ),
    );
  }
}
