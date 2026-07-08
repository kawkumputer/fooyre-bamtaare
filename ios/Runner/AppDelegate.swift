import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Diagnostic temporaire : capture le resultat brut de l'enregistrement
  // APNs (succes ou erreur) dans UserDefaults, lu cote Flutter via
  // shared_preferences (cle prefixee "flutter.") pour l'afficher dans
  // l'ecran de debug notifications, faute d'acces a la console Xcode.
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
    UserDefaults.standard.set(tokenString, forKey: "flutter.apns_debug_token")
    UserDefaults.standard.set("", forKey: "flutter.apns_debug_error")
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  override func application(
    _ application: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    UserDefaults.standard.set(error.localizedDescription, forKey: "flutter.apns_debug_error")
    super.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
  }
}
