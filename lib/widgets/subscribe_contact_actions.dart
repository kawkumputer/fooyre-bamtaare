import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Boutons de contact (email + WhatsApp) pour activer un abonnement.
/// Reutilise sur l'accueil, le profil et le dialogue d'edition verrouillee.
class SubscribeContactActions extends StatelessWidget {
  const SubscribeContactActions({super.key});

  static const _email = 'fooyre.bamtaare.app@gmail.com';
  static const _whatsappDisplay = '+222 46 96 19 58';
  static const _whatsappDigits = '22246961958';

  Future<void> _launch(BuildContext context, Uri uri, String fallback) async {
    bool ok = false;
    try {
      ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      ok = false;
    }
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(fallback)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: () => _launch(
            context,
            Uri(scheme: 'mailto', path: _email),
            _email,
          ),
          icon: const Icon(Icons.email_outlined, size: 18),
          label: const Text(_email),
        ),
        OutlinedButton.icon(
          onPressed: () => _launch(
            context,
            Uri.parse('https://wa.me/$_whatsappDigits'),
            _whatsappDisplay,
          ),
          icon: const Icon(Icons.chat_outlined, size: 18),
          label: Text('WhatsApp $_whatsappDisplay'),
        ),
      ],
    );
  }
}
