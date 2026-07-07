class Profile {
  final String id;
  final String nom;
  final String? telephone;
  final String role;
  final DateTime? subscriptionStart;
  final DateTime? subscriptionEnd;
  final bool isActive;

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
    this.subscriptionStart,
    this.subscriptionEnd,
    required this.isActive,
    this.email,
    this.emailConfirmed,
  });

  bool get isAdmin => role == 'admin';

  bool get hasActiveSubscription =>
      isActive &&
      subscriptionEnd != null &&
      subscriptionEnd!.isAfter(DateTime.now());

  /// Jours restants d'abonnement (0 si expire ou absent).
  int get daysLeft {
    if (!hasActiveSubscription) return 0;
    return subscriptionEnd!.difference(DateTime.now()).inDays;
  }

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String,
        nom: (json['nom'] as String?) ?? '',
        telephone: json['telephone'] as String?,
        role: (json['role'] as String?) ?? 'reader',
        subscriptionStart: json['subscription_start'] != null
            ? DateTime.parse(json['subscription_start'] as String)
            : null,
        subscriptionEnd: json['subscription_end'] != null
            ? DateTime.parse(json['subscription_end'] as String)
            : null,
        isActive: (json['is_active'] as bool?) ?? false,
        email: json['email'] as String?,
        emailConfirmed: json['email_confirmed'] as bool?,
      );
}
