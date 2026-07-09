import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../data/services/api_service.dart';
import '../../data/services/secure_storage_service.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Richiede i permessi per le notifiche
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Permesso per le notifiche concesso.');
      
      // Ottiene l'FCM Token del dispositivo (da inviare poi al backend)
      String? token = await _firebaseMessaging.getToken();
      debugPrint('FCM Token: $token');
      if (token != null) {
        _syncFCMToken(token);
      }
      
      // Ascolta il refresh del token
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
         _syncFCMToken(newToken);
      });

      // Gestisce le notifiche quando l'app � in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Notifica in foreground ricevuta: ${message.notification?.title}');
      });

    } else {
      debugPrint('Permesso per le notifiche negato o non determinato.');
    }
  }

  static Future<void> _syncFCMToken(String token) async {
    try {
      final jwt = await SecureStorageService.getToken();
      if (jwt == null || jwt.isEmpty) {
        debugPrint('Sync FCM saltata: utente non autenticato.');
        return;
      }

      await ApiService.dio.post(
        '/auth/fcm_token',
        data: {'fcm_token': token},
      );
      debugPrint('Token FCM sincronizzato correttamente sul backend.');
    } catch (e) {
      debugPrint('Errore durante la sincronizzazione FCM: $e');
    }
  }
}
