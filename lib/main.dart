import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'l10n/fallback_localizations.dart';
import 'models/profile.dart';
import 'screens/admin/admin_upload_screen.dart';
import 'screens/admin/admin_users_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/editions/editions_list_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'services/auth_service.dart';
import 'services/locale_controller.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

/// Controleur de langue global (pulaar/francais), accessible partout.
final localeController = LocaleController();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Le pulaar n'a pas de locale intl dédiée : on formate les dates avec
  // le francais dans les deux langues.
  await initializeDateFormatting('fr');
  await localeController.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );
  runApp(const FooyreApp());
}

class FooyreApp extends StatelessWidget {
  const FooyreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: localeController,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'Fooyre Ɓamtaare',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.system,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            // Repli pour les widgets systeme en mode pulaar (voir fichier).
            FallbackMaterialLocalizationsDelegate(),
            FallbackCupertinoLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const AuthGate(),
        );
      },
    );
  }
}

/// Redirige vers la connexion ou l'accueil selon l'etat de session.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Lien "mot de passe oublie" ouvert : l'utilisateur est
        // temporairement authentifie, mais doit d'abord choisir un
        // nouveau mot de passe avant d'acceder a l'app.
        if (snapshot.data?.event == AuthChangeEvent.passwordRecovery) {
          return const ResetPasswordScreen();
        }
        final session = Supabase.instance.client.auth.currentSession;
        if (session == null) {
          return const LoginScreen();
        }
        return const HomeShell();
      },
    );
  }
}

/// Accueil : navigation par onglets. Les onglets admin n'apparaissent
/// que pour le role admin.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _authService = AuthService();
  Profile? _profile;
  bool _loadingProfile = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    // Demande de permission + abonnement notifications, non bloquant.
    NotificationService().initialize();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _authService.fetchMyProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _loadingProfile = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingProfile) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isAdmin = _profile?.isAdmin ?? false;
    final l10n = AppLocalizations.of(context);

    final screens = <Widget>[
      EditionsListScreen(profile: _profile),
      if (isAdmin) const AdminUsersScreen(),
      if (isAdmin) const AdminUploadScreen(),
      ProfileScreen(
        profile: _profile,
        onProfileUpdated: _loadProfile,
        onSignedOut: () {
          // AuthGate reagit au changement d'etat et affiche LoginScreen.
        },
      ),
    ];

    final destinations = <NavigationDestination>[
      NavigationDestination(
        icon: const Icon(Icons.menu_book_outlined),
        selectedIcon: const Icon(Icons.menu_book),
        label: l10n.navEditions,
      ),
      if (isAdmin)
        NavigationDestination(
          icon: const Icon(Icons.people_outline),
          selectedIcon: const Icon(Icons.people),
          label: l10n.navSubscribers,
        ),
      if (isAdmin)
        NavigationDestination(
          icon: const Icon(Icons.cloud_upload_outlined),
          selectedIcon: const Icon(Icons.cloud_upload),
          label: l10n.navPublish,
        ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline),
        selectedIcon: const Icon(Icons.person),
        label: l10n.navProfile,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: destinations,
      ),
    );
  }
}
