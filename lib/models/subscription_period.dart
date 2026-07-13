/// Une periode d'abonnement (dates de debut/fin incluses). Un
/// utilisateur peut avoir plusieurs periodes non contigues : l'acces
/// a une edition depend de sa date de parution tombant dans au moins
/// une de ces periodes.
class SubscriptionPeriod {
  final String id;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const SubscriptionPeriod({
    required this.id,
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  bool covers(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  factory SubscriptionPeriod.fromJson(Map<String, dynamic> json) =>
      SubscriptionPeriod(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: DateTime.parse(json['end_date'] as String),
      );
}
