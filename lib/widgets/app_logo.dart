import 'package:flutter/material.dart';

/// Marque visuelle de Fooyre Ɓamtaare : cercle degrade vert avec un
/// livre ouvert, reprise sur l'ecran de connexion et l'en-tete du journal.
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
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, scheme.primaryContainer],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.menu_book_rounded,
        size: size * 0.5,
        color: scheme.onPrimary,
      ),
    );
  }
}
