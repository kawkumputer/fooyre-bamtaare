class Edition {
  final String id;
  final int numero;
  final String titre;
  final DateTime datePublication;
  final String pdfPath;
  final bool gratuit;

  const Edition({
    required this.id,
    required this.numero,
    required this.titre,
    required this.datePublication,
    required this.pdfPath,
    required this.gratuit,
  });

  factory Edition.fromJson(Map<String, dynamic> json) => Edition(
        id: json['id'] as String,
        numero: json['numero'] as int,
        titre: json['titre'] as String,
        datePublication: DateTime.parse(json['date_publication'] as String),
        pdfPath: json['pdf_path'] as String,
        gratuit: (json['gratuit'] as bool?) ?? false,
      );
}
