import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/edition.dart';
import '../models/profile.dart';
import '../models/subscription_period.dart';

class AdminService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Tous les utilisateurs inscrits, avec statut de confirmation email
  /// (vue admin_users_view : admin uniquement) et leurs periodes
  /// d'abonnement (passees et en cours).
  Future<List<Profile>> fetchAllUsers() async {
    final data =
        await _client.from('admin_users_view').select().order('created_at');
    final periodsData = await _client.from('subscription_periods').select();
    final periodsByUser = <String, List<SubscriptionPeriod>>{};
    for (final row in periodsData as List) {
      final period = SubscriptionPeriod.fromJson(row as Map<String, dynamic>);
      periodsByUser.putIfAbsent(period.userId, () => []).add(period);
    }
    return (data as List).map((e) {
      final profile = Profile.fromJson(e as Map<String, dynamic>);
      return profile.copyWith(periods: periodsByUser[profile.id] ?? []);
    }).toList();
  }

  /// Confirme manuellement l'email d'un utilisateur (contournement pour
  /// les cas ou le lien de confirmation ne fonctionne pas, ex: Gmail
  /// sur iOS).
  Future<void> confirmUserEmail(String userId) async {
    await _client.rpc(
      'admin_confirm_user_email',
      params: {'target_user_id': userId},
    );
  }

  /// Ajoute une nouvelle periode d'abonnement pour un utilisateur.
  /// Independante des periodes existantes : permet des abonnements
  /// non contigus (ex: juillet-septembre, puis decembre-mai).
  Future<void> addSubscriptionPeriod(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    await _client.from('subscription_periods').insert({
      'user_id': userId,
      'start_date': _dateOnly(startDate),
      'end_date': _dateOnly(endDate),
    });
  }

  /// Supprime une periode d'abonnement (ex: erreur de saisie de l'admin).
  Future<void> deleteSubscriptionPeriod(String periodId) async {
    await _client.from('subscription_periods').delete().eq('id', periodId);
  }

  /// Met fin des aujourd'hui a la periode en cours d'un utilisateur
  /// (raccourcit sa date de fin a hier), sans supprimer l'historique.
  Future<void> endActivePeriodNow(SubscriptionPeriod period) async {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await _client
        .from('subscription_periods')
        .update({'end_date': _dateOnly(yesterday)}).eq('id', period.id);
  }

  String _dateOnly(DateTime d) => d.toIso8601String().substring(0, 10);

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
