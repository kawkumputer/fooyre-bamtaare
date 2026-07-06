import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/profile.dart';
import '../../services/auth_service.dart';

/// Modification du profil : nom complet et telephone.
/// L'email n'est pas modifiable (identifiant du compte).
class EditProfileScreen extends StatefulWidget {
  final Profile profile;
  final String? email;

  const EditProfileScreen({
    super.key,
    required this.profile,
    required this.email,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _telephoneController;
  final _authService = AuthService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.profile.nom);
    _telephoneController =
        TextEditingController(text: widget.profile.telephone ?? '');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final tel = _telephoneController.text.trim();
      await _authService.updateMyProfile(
        nom: _nomController.text.trim(),
        telephone: tel.isEmpty ? null : tel,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileUpdated)),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorWithMessage('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
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
                // Email affiche mais non modifiable.
                TextFormField(
                  initialValue: widget.email ?? '',
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    helperText: l10n.emailNotEditable,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
