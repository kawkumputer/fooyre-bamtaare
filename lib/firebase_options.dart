import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Options Firebase du projet "fooyre-20770", utilisees uniquement pour
/// Firebase Cloud Messaging (notifications push). Pas de google-services.json
/// ni de GoogleService-Info.plist : ces valeurs suffisent pour
/// Firebase.initializeApp() sans toucher aux projets natifs Android/Xcode.
///
/// Valeurs recuperees depuis Firebase Console > Parametres du projet.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions n\'est pas configure pour le web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions n\'est pas configure pour cette plateforme.',
        );
    }
  }

  static const android = FirebaseOptions(
    apiKey: 'AIzaSyAClcJ79eSQMZvwCWPn4CNrFEgw7GgdQUU',
    appId: '1:760060330407:android:7830f8993139a5fbe23682',
    messagingSenderId: '760060330407',
    projectId: 'fooyre-20770',
    storageBucket: 'fooyre-20770.firebasestorage.app',
  );

  static const ios = FirebaseOptions(
    apiKey: 'AIzaSyDCwM-K_6xysfK1EXcNcWFd8uTFBsibgcg',
    appId: '1:760060330407:ios:93e9fb7f3b356471e23682',
    messagingSenderId: '760060330407',
    projectId: 'fooyre-20770',
    storageBucket: 'fooyre-20770.firebasestorage.app',
    iosBundleId: 'org.fbpm.fooyreApp',
  );
}
