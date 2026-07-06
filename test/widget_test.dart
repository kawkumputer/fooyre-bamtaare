import 'package:flutter_test/flutter_test.dart';

import 'package:fooyre_app/models/edition.dart';
import 'package:fooyre_app/models/profile.dart';

void main() {
  group('Profile', () {
    test('abonnement actif quand la date de fin est future', () {
      final profile = Profile(
        id: 'u1',
        nom: 'Test',
        role: 'reader',
        subscriptionEnd: DateTime.now().add(const Duration(days: 30)),
        isActive: true,
      );
      expect(profile.hasActiveSubscription, isTrue);
      expect(profile.daysLeft, greaterThan(0));
    });

    test('abonnement expire quand la date de fin est passee', () {
      final profile = Profile(
        id: 'u1',
        nom: 'Test',
        role: 'reader',
        subscriptionEnd: DateTime.now().subtract(const Duration(days: 1)),
        isActive: true,
      );
      expect(profile.hasActiveSubscription, isFalse);
      expect(profile.daysLeft, 0);
    });

    test('abonnement inactif meme avec date future si is_active=false', () {
      final profile = Profile(
        id: 'u1',
        nom: 'Test',
        role: 'reader',
        subscriptionEnd: DateTime.now().add(const Duration(days: 30)),
        isActive: false,
      );
      expect(profile.hasActiveSubscription, isFalse);
    });

    test('fromJson analyse le role admin', () {
      final profile = Profile.fromJson({
        'id': 'u2',
        'nom': 'Editeur',
        'role': 'admin',
        'is_active': false,
      });
      expect(profile.isAdmin, isTrue);
      expect(profile.hasActiveSubscription, isFalse);
    });
  });

  group('Edition', () {
    test('fromJson analyse une edition avec affiche et complet', () {
      final edition = Edition.fromJson({
        'id': 'e1',
        'numero': 261,
        'titre': 'Fooyre Ɓamtaare 261',
        'date_publication': '2026-06-01',
        'cover_path': 'gratuit/cover_261.jpg',
        'pdf_complet': 'abonnes/fooyre_261.pdf',
      });
      expect(edition.numero, 261);
      expect(edition.hasCover, isTrue);
      expect(edition.hasComplet, isTrue);
    });

    test('fromJson : edition sans affiche', () {
      final edition = Edition.fromJson({
        'id': 'e2',
        'numero': 262,
        'titre': 'Fooyre Ɓamtaare 262',
        'date_publication': '2026-07-01',
        'pdf_complet': 'abonnes/fooyre_262.pdf',
      });
      expect(edition.hasCover, isFalse);
      expect(edition.hasComplet, isTrue);
    });
  });
}
