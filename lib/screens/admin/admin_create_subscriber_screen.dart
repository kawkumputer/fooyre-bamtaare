import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../services/admin_service.dart';

/// Creation d'un compte lecteur par l'admin (remplace l'ancienne
/// inscription en libre-service, retiree suite au retour App Store
/// guideline 3.1.1/3.1.3(a) : accessible uniquement depuis l'ecran
/// Abonnes, jamais depuis un ecran visible d'un visiteur anonyme).
class AdminCreateSubscriberScreen extends StatefulWidget {
  const AdminCreateSubscriberScreen({super.key});

  @override
  State<AdminCreateSubscriberScreen> createState() =>
      _AdminCreateSubscriberScreenState();
}

class _AdminCreateSubscriberScreenState
    extends State<AdminCreateSubscriberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _adminService = AdminService();
  bool _loading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final password = await _adminService.createSubscriberAccount(
        email: _emailController.text.trim(),
        nom: _nomController.text.trim(),
        telephone: _telephoneController.text.trim().isEmpty
            ? null
            : _telephoneController.text.trim(),
      );
      if (mounted) {
        await _showCredentialsDialog(
          name: _nomController.text.trim(),
          email: _emailController.text.trim(),
          password: password,
        );
        if (mounted) Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorWithMessage('$e'))));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showCredentialsDialog({
    required String name,
    required String email,
    required String password,
  }) async {
    final l10n = AppLocalizations.of(context);
    final body = l10n.subscriberCreatedBody(name, email, password);
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.subscriberCreatedTitle),
        content: SelectableText(body),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: body));
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.credentialsCopied)));
              }
            },
            child: Text(l10n.copy),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.addSubscriber)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nomController,
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? l10n.nameRequired : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phoneOptional,
                    helperText: l10n.phoneHelper,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (v) =>
                      v == null || !v.contains('@') ? l10n.invalidEmail : null,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _create,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.addSubscriber),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
