import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/edition.dart';
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

  /// Active l'abonnement d'un utilisateur jusqu'a une date de fin choisie
  /// par l'admin. La date de debut est conservee si l'abonnement etait
  /// deja actif, sinon elle demarre aujourd'hui.
  Future<void> activateSubscriptionUntil(
      Profile user, DateTime endDate) async {
    final now = DateTime.now();
    final start = user.subscriptionStart ?? now;

    await _client.from('profiles').update({
      'subscription_start': start.toIso8601String(),
      'subscription_end': endDate.toIso8601String(),
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
  ///
  /// Un numero comporte :
  ///  - [coverBytes] : affiche / la une (image), dossier gratuit/, visible
  ///    par tous. [coverExt] = extension image (jpg, png, ...).
  ///  - [completBytes] : edition complete (PDF), dossier abonnes/, reservee
  ///    aux abonnes.
  /// Les deux sont obligatoires.
  Future<void> publishEdition({
    required int numero,
    required String titre,
    required DateTime datePublication,
    required Uint8List coverBytes,
    required String? coverExt,
    required Uint8List completBytes,
  }) async {
    final row = <String, dynamic>{
      'numero': numero,
      'titre': titre,
      'date_publication': datePublication.toIso8601String().substring(0, 10),
    };

    // Dossier gratuit/ : lisible par tous (policy Storage).
    final ext = (coverExt ?? 'jpg').toLowerCase();
    final coverPath = 'gratuit/cover_$numero.$ext';
    await _upload(coverPath, coverBytes, _imageContentType(ext));
    row['cover_path'] = coverPath;

    // Dossier abonnes/ : lisible par les abonnes / admin.
    final pdfPath = 'abonnes/fooyre_$numero.pdf';
    await _upload(pdfPath, completBytes, 'application/pdf');
    row['pdf_complet'] = pdfPath;

    await _client.from('editions').upsert(row, onConflict: 'numero');
  }

  String _imageContentType(String ext) {
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  Future<void> _upload(String path, Uint8List bytes, String contentType) async {
    await _client.storage.from(SupabaseConfig.editionsBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType, upsert: true),
        );
  }

  /// Supprime une edition : l'affiche et le PDF complet dans le Storage
  /// puis la ligne dans la table editions (admin via RLS).
  Future<void> deleteEdition(Edition edition) async {
    final paths = <String>[
      if (edition.hasCover) edition.coverPath!,
      if (edition.hasComplet) edition.pdfComplet!,
    ];
    if (paths.isNotEmpty) {
      await _client.storage.from(SupabaseConfig.editionsBucket).remove(paths);
    }
    await _client.from('editions').delete().eq('id', edition.id);
  }
}
