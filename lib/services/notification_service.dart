import 'dart:io';

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

    // Sur iOS, l'abonnement a un topic echoue silencieusement tant que le
    // jeton APNs n'est pas encore disponible (contrairement a Android, qui
    // n'en a pas besoin). On attend qu'il soit pret avant de s'abonner.
    if (Platform.isIOS) {
      String? apnsToken = await messaging.getAPNSToken();
      var attempts = 0;
      while (apnsToken == null && attempts < 10) {
        await Future.delayed(const Duration(seconds: 1));
        apnsToken = await messaging.getAPNSToken();
        attempts++;
      }
      if (apnsToken == null) {
        debugPrint('NotificationService: jeton APNs indisponible, abandon.');
        return;
      }
    }

    try {
      await messaging.subscribeToTopic(_newEditionsTopic);
    } catch (e) {
      // Pas bloquant pour le reste de l'app si l'abonnement echoue
      // (ex: pas de connexion au demarrage).
      debugPrint('NotificationService: abonnement topic echoue: $e');
    }
  }
}
