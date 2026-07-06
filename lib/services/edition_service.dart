// createSignedUrls (batch) est marque deprecated par storage_client mais
// reste la methode adaptee ici (les chemins existent toujours).
// ignore_for_file: deprecated_member_use
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/edition.dart';

class EditionService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Liste des editions. La RLS rend les metadonnees visibles a tous ;
  /// l'acces aux fichiers (apercu vs complet) est gere au telechargement.
  Future<List<Edition>> fetchEditions() async {
    final data = await _client
        .from('editions')
        .select()
        .order('numero', ascending: false);
    return (data as List)
        .map((e) => Edition.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// URLs signees (1h) des affiches, en une seule requete.
  /// Retourne une map id_edition -> url image. Les editions sans affiche
  /// sont absentes de la map.
  Future<Map<String, String>> coverSignedUrls(List<Edition> editions) async {
    final withCover = editions.where((e) => e.hasCover).toList();
    if (withCover.isEmpty) return {};

    final paths = withCover.map((e) => e.coverPath!).toList();
    final signed = await _client.storage
        .from(SupabaseConfig.editionsBucket)
        .createSignedUrls(paths, 3600);

    final urlByPath = {for (final s in signed) s.path: s.signedUrl};
    final result = <String, String>{};
    for (final e in withCover) {
      final url = urlByPath[e.coverPath];
      if (url != null) result[e.id] = url;
    }
    return result;
  }

  /// Telecharge (et met en cache) un PDF depuis son chemin Storage.
  /// [cacheKey] distingue les fichiers en cache (ex: apercu vs complet).
  Future<File> getLocalPdf({
    required String pdfPath,
    required String cacheKey,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/editions/$cacheKey.pdf');
    if (await file.exists()) return file;

    final signedUrl = await _client.storage
        .from(SupabaseConfig.editionsBucket)
        .createSignedUrl(pdfPath, 3600);

    final response = await http.get(Uri.parse(signedUrl));
    if (response.statusCode != 200) {
      throw Exception('Telechargement impossible (${response.statusCode})');
    }
    await file.parent.create(recursive: true);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }
}
