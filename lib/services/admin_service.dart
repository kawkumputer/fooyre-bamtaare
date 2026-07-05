import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/profile.dart';

class AdminService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Tous les utilisateurs inscrits (RLS : admin uniquement).
  Future<List<Profile>> fetchAllUsers() async {
    final data =
        await _client.from('profiles').select().order('created_at');
    return (data as List)
        .map((e) => Profile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Active ou prolonge l'abonnement d'un utilisateur.
  ///
  /// Si l'abonnement est encore actif, les mois s'ajoutent a la
  /// date de fin actuelle ; sinon la periode démarre aujourd'hui.
  Future<void> activateSubscription(Profile user, int months) async {
    final now = DateTime.now();
    final base = user.hasActiveSubscription ? user.subscriptionEnd! : now;
    final end = DateTime(base.year, base.month + months, base.day);

    await _client.from('profiles').update({
      'subscription_start':
          user.hasActiveSubscription ? null : now.toIso8601String(),
      'subscription_end': end.toIso8601String(),
      'is_active': true,
    }).eq('id', user.id);
  }

  /// Desactive l'acces d'un utilisateur immediatement.
  Future<void> deactivateSubscription(Profile user) async {
    await _client.from('profiles').update({
      'is_active': false,
      'subscription_end': DateTime.now().toIso8601String(),
    }).eq('id', user.id);
  }

  /// Publie une nouvelle edition : upload du PDF puis insertion
  /// de la ligne dans la table editions.
  Future<void> publishEdition({
    required int numero,
    required String titre,
    required bool gratuit,
    required Uint8List pdfBytes,
  }) async {
    // Les PDF gratuits vont dans le dossier "gratuit/" : la policy
    // Storage s'appuie sur ce prefixe pour autoriser la lecture.
    final folder = gratuit ? 'gratuit' : 'abonnes';
    final path = '$folder/fooyre_$numero.pdf';

    await _client.storage.from(SupabaseConfig.editionsBucket).uploadBinary(
          path,
          pdfBytes,
          fileOptions: const FileOptions(
            contentType: 'application/pdf',
            upsert: true,
          ),
        );

    await _client.from('editions').upsert({
      'numero': numero,
      'titre': titre,
      'gratuit': gratuit,
      'pdf_path': path,
      'date_publication': DateTime.now().toIso8601String().substring(0, 10),
    }, onConflict: 'numero');
  }
}
