import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Schema d'URL personnalise pour ramener l'utilisateur dans l'app
  /// apres confirmation d'email. Doit correspondre a ce qui est
  /// enregistre dans Supabase (Authentication > URL Configuration >
  /// Redirect URLs) et dans les manifestes iOS/Android.
  static const String emailRedirectTo = 'io.fbpm.fooyre://login-callback';

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

  Future<void> signOut() => _client.auth.signOut();

  Future<Profile?> fetchMyProfile() async {
    final user = currentUser;
    if (user == null) return null;
    final data =
        await _client.from('profiles').select().eq('id', user.id).maybeSingle();
    if (data == null) return null;
    return Profile.fromJson(data);
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
