import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';
import '../models/subscription_period.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Page de rebond HTTPS (GitHub Pages) utilisee comme redirection
  /// apres confirmation d'email, avant de renvoyer vers l'app via le
  /// schema personnalise io.fbpm.fooyre://login-callback.
  ///
  /// Necessaire car certains clients mail (Gmail) reecrivent les liens
  /// avec leur propre redirecteur, qui echoue silencieusement sur un
  /// schema d'URL personnalise. Une page https classique passe sans
  /// probleme ; c'est elle qui redirige ensuite vers l'app en JS, une
  /// fois chargee dans le vrai navigateur du telephone.
  ///
  /// Doit correspondre a ce qui est enregistre dans Supabase
  /// (Authentication > URL Configuration > Redirect URLs).
  static const String emailRedirectTo =
      'https://kawkumputer.github.io/fooyre-bamtaare/confirm.html';

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<void> signUp({
    required String email,
    required String password,
    required String nom,
    String? telephone,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'nom': nom, 'telephone': telephone},
      emailRedirectTo: emailRedirectTo,
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Envoie un e-mail de reinitialisation de mot de passe. Reutilise la
  /// meme page de rebond (deep link) que la confirmation d'inscription :
  /// l'ouverture du lien authentifie temporairement l'utilisateur
  /// (evenement AuthChangeEvent.passwordRecovery, gere par AuthGate dans
  /// main.dart) pour lui permettre de choisir un nouveau mot de passe.
  Future<void> sendPasswordResetEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email, redirectTo: emailRedirectTo);
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<Profile?> fetchMyProfile() async {
    final user = currentUser;
    if (user == null) return null;
    final data =
        await _client.from('profiles').select().eq('id', user.id).maybeSingle();
    if (data == null) return null;
    final periodsData = await _client
        .from('subscription_periods')
        .select()
        .eq('user_id', user.id);
    final periods = (periodsData as List)
        .map((e) => SubscriptionPeriod.fromJson(e as Map<String, dynamic>))
        .toList();
    return Profile.fromJson(data).copyWith(periods: periods);
  }

  Future<void> updateMyProfile({required String nom, String? telephone}) async {
    final user = currentUser;
    if (user == null) return;
    await _client
        .from('profiles')
        .update({'nom': nom, 'telephone': telephone}).eq('id', user.id);
  }

  /// Change le mot de passe de l'utilisateur connecte.
  Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Supprime definitivement le compte de l'utilisateur connecte
  /// (profil + abonnement inclus, via cascade cote base).
  Future<void> deleteMyAccount() async {
    await _client.rpc('delete_my_account');
    await _client.auth.signOut();
  }
}
