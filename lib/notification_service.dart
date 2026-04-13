import 'dart:developer';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'core/api_service.dart';

class NotificationService {
  // static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    /*
    // 1. Demander les permissions (Android 13+ & iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted notification permissions');
    }
    */

    // 2. Initialiser les notifications locales
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    /*
    // 3. Écouter les messages en premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Foreground message received: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // 4. Gérer le clic sur une notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('Notification opened app: ${message.notification?.title}');
    });
    */
  }

  // 🔔 Afficher une notification locale
  static Future<void> _showLocalNotification(dynamic message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'parking_alert_channel',
      'Parking Alert Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      0,
      'Nouvelle Alerte 🚗',
      'Quelqu\'un a besoin de vous !',
      details,
    );
  }

  // 🔑 Récupérer et enregistrer le Token FCM
  static Future<void> updateTokenInBackend(String matricule) async {
    try {
      /*
      String? token = await _fcm.getToken();
      if (token != null) {
        log('FCM Token: $token');
        await ApiService.updateUser(matricule, {'fcmToken': token});
      }
      */
    } catch (e) {
      log('Error updating FCM token: $e');
    }
  }
}

// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   log("Handling a background message: ${message.messageId}");
// }
