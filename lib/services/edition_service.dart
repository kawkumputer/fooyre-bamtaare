import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/edition.dart';

class EditionService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Liste des editions visibles pour l'utilisateur courant.
  /// La RLS filtre automatiquement : un lecteur sans abonnement
  /// ne recoit que les editions gratuites.
  Future<List<Edition>> fetchEditions() async {
    final data = await _client
        .from('editions')
        .select()
        .order('numero', ascending: false);
    return (data as List)
        .map((e) => Edition.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Retourne le fichier PDF local, en le telechargeant si besoin
  /// (cache pour la lecture hors-ligne).
  Future<File> getLocalPdf(Edition edition) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/editions/${edition.id}.pdf');
    if (await file.exists()) return file;

    final signedUrl = await _client.storage
        .from(SupabaseConfig.editionsBucket)
        .createSignedUrl(edition.pdfPath, 3600);

    final response = await http.get(Uri.parse(signedUrl));
    if (response.statusCode != 200) {
      throw Exception('Telechargement impossible (${response.statusCode})');
    }
    await file.parent.create(recursive: true);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  /// Verifie si une edition est deja disponible hors-ligne.
  Future<bool> isDownloaded(Edition edition) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/editions/${edition.id}.pdf').exists();
  }
}
