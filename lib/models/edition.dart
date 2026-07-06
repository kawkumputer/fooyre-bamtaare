class Edition {
  final String id;
  final int numero;
  final String titre;
  final DateTime datePublication;

  /// Affiche / la une (image) : dossier gratuit/, visible par tous.
  final String? coverPath;

  /// Edition complete (PDF) : dossier abonnes/, reservee aux abonnes/admin.
  final String? pdfComplet;

  const Edition({
    required this.id,
    required this.numero,
    required this.titre,
    required this.datePublication,
    this.coverPath,
    this.pdfComplet,
  });

  bool get hasCover => coverPath != null && coverPath!.isNotEmpty;
  bool get hasComplet => pdfComplet != null && pdfComplet!.isNotEmpty;

  factory Edition.fromJson(Map<String, dynamic> json) => Edition(
        id: json['id'] as String,
        numero: json['numero'] as int,
        titre: json['titre'] as String,
        datePublication: DateTime.parse(json['date_publication'] as String),
        coverPath: json['cover_path'] as String?,
        pdfComplet: json['pdf_complet'] as String?,
      );
}
