import 'package:flutter_test/flutter_test.dart';

import 'package:fooyre_app/models/edition.dart';
import 'package:fooyre_app/models/profile.dart';
import 'package:fooyre_app/models/subscription_period.dart';

SubscriptionPeriod _period(String id, DateTime start, DateTime end) =>
    SubscriptionPeriod(id: id, userId: 'u1', startDate: start, endDate: end);

void main() {
  group('Profile', () {
    test('abonnement actif quand une periode couvre aujourd\'hui', () {
      final profile = Profile(
        id: 'u1',
        nom: 'Test',
        role: 'reader',
        periods: [
          _period(
            'p1',
            DateTime.now().subtract(const Duration(days: 10)),
            DateTime.now().add(const Duration(days: 30)),
          ),
        ],
      );
      expect(profile.hasActiveSubscription, isTrue);
      expect(profile.daysLeft, greaterThan(0));
    });

    test('abonnement expire quand toutes les periodes sont passees', () {
      final profile = Profile(
        id: 'u1',
        nom: 'Test',
        role: 'reader',
        periods: [
          _period(
            'p1',
            DateTime.now().subtract(const Duration(days: 30)),
            DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      );
      expect(profile.hasActiveSubscription, isFalse);
      expect(profile.daysLeft, 0);
    });

    test('acces archive conserve a une edition parue durant une periode '
        'passee, meme sans abonnement actif', () {
      final juillet = DateTime(2026, 7, 15);
      final septembre = DateTime(2026, 9, 15);
      final profile = Profile(
        id: 'u1',
        nom: 'Test',
        role: 'reader',
        periods: [_period('p1', DateTime(2026, 7, 1), DateTime(2026, 9, 30))],
      );
      expect(profile.canAccessDate(juillet), isTrue);
      expect(profile.canAccessDate(septembre), isTrue);
    });

    test('periodes non contigues : pas d\'acces dans le trou entre deux '
        'abonnements', () {
      final profile = Profile(
        id: 'u1',
        nom: 'Test',
        role: 'reader',
        periods: [
          _period('p1', DateTime(2026, 7, 1), DateTime(2026, 9, 30)),
          _period('p2', DateTime(2026, 12, 1), DateTime(2027, 5, 31)),
        ],
      );
      expect(profile.canAccessDate(DateTime(2026, 8, 15)), isTrue);
      expect(profile.canAccessDate(DateTime(2026, 10, 15)), isFalse);
      expect(profile.canAccessDate(DateTime(2027, 1, 15)), isTrue);
    });

    test('fromJson analyse le role admin', () {
      final profile = Profile.fromJson({
        'id': 'u2',
        'nom': 'Editeur',
        'role': 'admin',
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
        'titre': 'Tonngoode 262',
        'date_publication': '2026-07-01',
        'pdf_complet': 'abonnes/fooyre_262.pdf',
      });
      expect(edition.hasCover, isFalse);
      expect(edition.hasComplet, isTrue);
    });
  });
}
