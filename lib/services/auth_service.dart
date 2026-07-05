import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

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
}
