import 'subscription_period.dart';

class Profile {
  final String id;
  final String nom;
  final String? telephone;
  final String role;

  /// Periodes d'abonnement (passees et en cours). Un utilisateur peut
  /// avoir plusieurs periodes non contigues : l'acces a une edition
  /// depend de sa date de parution tombant dans au moins une d'elles.
  final List<SubscriptionPeriod> periods;

  /// Renseignes uniquement lorsque le profil provient de la vue admin
  /// (admin_users_view) : null pour un profil recupere via
  /// fetchMyProfile (self).
  final String? email;
  final bool? emailConfirmed;

  const Profile({
    required this.id,
    required this.nom,
    this.telephone,
    required this.role,
    this.periods = const [],
    this.email,
    this.emailConfirmed,
  });

  bool get isAdmin => role == 'admin';

  /// La periode qui couvre aujourd'hui, si elle existe.
  SubscriptionPeriod? get _currentPeriod {
    final now = DateTime.now();
    for (final p in periods) {
      if (p.covers(now)) return p;
    }
    return null;
  }

  bool get hasActiveSubscription => _currentPeriod != null;

  /// Date de fin de la periode en cours (null si pas d'abonnement actif).
  DateTime? get subscriptionEnd => _currentPeriod?.endDate;

  /// Jours restants d'abonnement (0 si expire ou absent).
  int get daysLeft {
    final end = subscriptionEnd;
    if (end == null) return 0;
    return end.difference(DateTime.now()).inDays;
  }

  /// Acces a une edition (passee ou en cours) : vrai si sa date de
  /// parution tombe dans au moins une des periodes d'abonnement.
  bool canAccessDate(DateTime date) => periods.any((p) => p.covers(date));

  Profile copyWith({List<SubscriptionPeriod>? periods}) => Profile(
        id: id,
        nom: nom,
        telephone: telephone,
        role: role,
        periods: periods ?? this.periods,
        email: email,
        emailConfirmed: emailConfirmed,
      );

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        nom: (json['nom'] as String?) ?? '',
        telephone: json['telephone'] as String?,
        role: (json['role'] as String?) ?? 'reader',
        email: json['email'] as String?,
        emailConfirmed: json['email_confirmed'] as bool?,
      );
}
