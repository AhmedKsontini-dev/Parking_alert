import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'core/api_service.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. Demander les permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Initialiser les notifications locales
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // 3. Créer le canal pour Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'parking_alert_channel',
      'Parking Alert Notifications',
      description: 'Canal pour les alertes de parking',
      importance: Importance.max,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 4. Écouter les messages en premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(message);
    });
  }

  // 🔔 Fonction pour tester manuellement (votre bouton)
  static Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'parking_alert_channel',
      'Test Channel',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      99,
      'Test de Notification 🔔',
      'Ceci est une notification de test type WhatsApp/Messenger !',
      details,
    );
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'parking_alert_channel',
      'Parking Alert Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Alerte 🚗',
      message.notification?.body ?? 'Nouveau messsage reçu',
      details,
    );
  }

  static Future<void> updateTokenInBackend(String matricule) async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        log('FCM Token: $token');
        await ApiService.updateUser(matricule, {'fcmToken': token});
      }
    } catch (e) {
      log('Error updating FCM token: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Message en arrière-plan : ${message.messageId}");
}
