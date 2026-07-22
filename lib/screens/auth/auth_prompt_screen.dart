import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'login_screen.dart';

/// Affichee dans l'onglet Profil quand personne n'est connecte (mode
/// invite). Se connecter reste facultatif : seules les fonctionnalites
/// liees a un compte (abonnement, edition du profil, ...) en ont besoin,
/// pas la consultation des editions.
///
/// Pas d'inscription en libre-service ici (guideline App Store 3.1.3(a) :
/// une "Reader App" ne doit pas proposer de creation de compte donnant
/// acces a du contenu payant). Les nouveaux abonnes contactent la
/// redaction ; le compte est cree cote admin (Supabase Dashboard).
class AuthPromptScreen extends StatelessWidget {
  final VoidCallback onAuthChanged;

  const AuthPromptScreen({super.key, required this.onAuthChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myProfile)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.account_circle_outlined,
                size: 64,
                color: scheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.guestProfilePrompt,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                  onAuthChanged();
                },
                child: Text(l10n.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
