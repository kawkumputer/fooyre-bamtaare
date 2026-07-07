import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Notifications push (nouvelle edition publiee), via Firebase Cloud
/// Messaging. Tous les appareils s'abonnent au meme topic : pas besoin
/// de stocker des tokens individuels en base, FCM gere la diffusion.
class NotificationService {
  static const String _newEditionsTopic = 'new_editions';

  Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    // Demande la permission d'affichage (iOS + Android 13+).
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    try {
      await messaging.subscribeToTopic(_newEditionsTopic);
    } catch (e) {
      // Pas bloquant pour le reste de l'app si l'abonnement echoue
      // (ex: pas de connexion au demarrage).
      debugPrint('NotificationService: abonnement topic echoue: $e');
    }
  }
}
