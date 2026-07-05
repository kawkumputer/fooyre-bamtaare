/// Configuration Supabase.
///
/// Remplacer par les valeurs du projet (dashboard Supabase >
/// Settings > API). La cle "anon" (legacy) ou "publishable"
/// (sb_publishable_...) fonctionnent toutes les deux. Cette cle
/// est publique par nature : la securite repose sur les policies
/// RLS, pas sur cette cle.
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://cgsgfgvwkticuhsyqurz.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_hWoFVFp24uVGMrXVwz0J8g_wfC3xkdy',
  );

  /// Nom du bucket Storage contenant les PDF des editions.
  static const String editionsBucket = 'editions';
}
