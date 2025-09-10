import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static String? _fcmToken;
  static Function(String)? _onStatusChangeCallback;

  /// Initialize notification service
  static Future<void> initialize() async {
    print('🔔 Initializing notification service...');
    
    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('🔔 Notification permission granted');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('🔔 Provisional notification permission granted');
    } else {
      print('❌ Notification permission denied');
      return;
    }

    // Initialize local notifications (temporarily disabled)
    // await _initializeLocalNotifications();

    // Get FCM token
    _fcmToken = await _firebaseMessaging.getToken();
    print('🔔 FCM Token: $_fcmToken');

    // Configure message handlers
    await _configureMessageHandlers();

    // Send token to backend
    if (_fcmToken != null) {
      await _sendTokenToBackend(_fcmToken!);
    }
  }

  /// Initialize local notifications (temporarily disabled)
  static Future<void> _initializeLocalNotifications() async {
    print('🔔 Local notifications temporarily disabled for build compatibility');
    /*
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    */
  }

  /// Configure FCM message handlers
  static Future<void> _configureMessageHandlers() async {
    // Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle messages when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle messages when app is launched from notification
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('🔔 Foreground message received: ${message.notification?.title}');
    
    // Show local notification when app is in foreground (temporarily disabled)
    // await _showLocalNotification(message);
    print('🔔 Foreground notification would be shown: ${message.notification?.title}');
    
    // Handle status change notifications
    if (message.data['type'] == 'status_change') {
      String newStatus = message.data['status'] ?? '';
      if (_onStatusChangeCallback != null && newStatus.isNotEmpty) {
        _onStatusChangeCallback!(newStatus);
      }
    }
  }

  /// Handle notification tap (app opened from notification)
  static void _handleNotificationTap(RemoteMessage message) {
    print('🔔 Notification tapped: ${message.notification?.title}');
    print('🔔 Message data: ${message.data}');
    
    // Handle different notification types
    String? type = message.data['type'];
    switch (type) {
      case 'status_change':
        String newStatus = message.data['status'] ?? '';
        if (_onStatusChangeCallback != null && newStatus.isNotEmpty) {
          _onStatusChangeCallback!(newStatus);
        }
        break;
      case 'application_update':
        // Handle application updates
        break;
      default:
        print('🔔 Unknown notification type: $type');
    }
  }

  /// Handle local notification tap (temporarily disabled)
  static void _onNotificationTapped(dynamic response) {
    print('🔔 Local notification tapped: $response');
    // Temporarily disabled for build compatibility
  }

  /// Show local notification (temporarily disabled)
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    print('🔔 Would show local notification: ${message.notification?.title}');
    // Temporarily disabled for build compatibility
    /*
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'status_updates',
      'Status Updates',
      channelDescription: 'Notifications for application status changes',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'DigitalBoda Update',
      message.notification?.body ?? 'You have a new update',
      details,
      payload: message.data.toString(),
    );
    */
  }

  /// Send FCM token to backend
  static Future<void> _sendTokenToBackend(String token) async {
    try {
      print('🔔 Sending FCM token to backend...');
      
      // Note: This method will be called during app initialization
      // We'll need phone number and firebase token from the user context
      // For now, we'll just store the token locally and send it when user data is available
      _fcmToken = token;
      
      print('🔔 FCM token stored locally, will be sent when user authenticates');
    } catch (e) {
      print('❌ Error storing FCM token: $e');
    }
  }

  /// Send stored FCM token to backend with user credentials
  static Future<void> sendTokenToBackendWithCredentials({
    required String phoneNumber,
    required String firebaseToken,
  }) async {
    if (_fcmToken == null) return;
    
    try {
      print('🔔 Sending FCM token to backend for user: $phoneNumber');
      
      final result = await ApiService.updateFCMToken(
        fcmToken: _fcmToken!,
        phoneNumber: phoneNumber,
        firebaseToken: firebaseToken,
      );
      
      if (result['success']) {
        print('🔔 FCM token sent successfully to backend');
      } else {
        print('❌ Failed to send FCM token: ${result['error']}');
      }
    } catch (e) {
      print('❌ Error sending FCM token to backend: $e');
    }
  }

  /// Set callback for status changes
  static void setOnStatusChangeCallback(Function(String) callback) {
    _onStatusChangeCallback = callback;
  }

  /// Get current FCM token
  static String? get fcmToken => _fcmToken;

  /// Subscribe to topic (for broadcast notifications)
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('🔔 Subscribed to topic: $topic');
    } catch (e) {
      print('❌ Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('🔔 Unsubscribed from topic: $topic');
    } catch (e) {
      print('❌ Error unsubscribing from topic: $e');
    }
  }

  /// Show custom local notification (temporarily disabled)
  static Future<void> showCustomNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    print('🔔 Would show custom notification: $title - $body');
    // Temporarily disabled for build compatibility
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Background message received: ${message.notification?.title}');
  
  // Handle background messages here
  // Note: You can't update UI from background handle
  //
  // r
}