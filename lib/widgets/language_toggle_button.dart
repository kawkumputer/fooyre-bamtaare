import 'package:flutter/material.dart';

import '../main.dart' show localeController;

/// Bouton de bascule rapide de langue : affiche le nom de la langue
/// vers laquelle basculer ("Français" quand l'app est en pulaar,
/// "Pulaar" quand elle est en français).
class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<Locale>(
      valueListenable: localeController,
      builder: (context, locale, _) {
        final isFf = locale.languageCode == 'ff';
        return TextButton.icon(
          onPressed: () =>
              localeController.setLocale(Locale(isFf ? 'fr' : 'ff')),
          icon: Icon(Icons.language, size: 18, color: scheme.primary),
          label: Text(
            isFf ? 'Français' : 'Pulaar',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
        );
      },
    );
  }
}
