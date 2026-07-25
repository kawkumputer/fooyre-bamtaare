import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../widgets/app_logo.dart';
import '../widgets/subscribe_contact_actions.dart';

/// Page de contact accessible depuis l'accueil, quel que soit l'etat de
/// connexion (invite ou lecteur). Requise par la politique Google Play
/// "Actualites et magazines" : une page de contact integree a l'appli,
/// avec e-mail ou telephone visible.
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  static const _privacyPolicyUrl =
      'https://kawkumputer.github.io/fooyre-bamtaare/privacy.html';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.contact)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: AppLogo(size: 72)),
              const SizedBox(height: 16),
              Text(
                'Fedde Ɓamtaare Pulaar he Muritani (FBPM)',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.contactBody,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              const Center(child: SubscribeContactActions()),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () => launchUrl(
                    Uri.parse(_privacyPolicyUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  child: Text(l10n.privacyPolicy),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
