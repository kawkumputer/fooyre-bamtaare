import 'package:flutter/material.dart';

/// Marque visuelle de Fooyre Ɓamtaare : le logo officiel de l'app
/// (soleil + livre ouvert), repris sur l'ecran de connexion et
/// l'en-tete du journal.
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 88});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset(
          'assets/icon/app_icon.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
