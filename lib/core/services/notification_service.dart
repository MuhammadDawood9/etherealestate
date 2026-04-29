// ─────────────────────────────────────────────────────────────────────────────
// notification_service.dart
//
// WHY NO `import 'dart:io'` AT THE TOP LEVEL?
//
// Exactly as with property_repository.dart, a bare `import 'dart:io';` at
// the top of any file that is loaded on Flutter Web causes:
//   "Unsupported operation: Platform._operatingSystem"
// at startup – even if every *call-site* is behind `if (!kIsWeb)`.
//
// The dart2js / DDC web compilers do not tree-shake imports; the import
// itself triggers the failure.
//
// Solution: use `defaultTargetPlatform` from `flutter/foundation.dart`
// (which IS web-safe) for platform detection, and conditionally import
// `dart:io` only when needed via a late/deferred pattern – or simply avoid
// it when `kIsWeb` can substitute.
//
// For this service the guard `if (kIsWeb) return;` at the top of every
// method that would use Platform is sufficient, because on Web we never
// need local notifications or an FCM device token.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Top-level FCM background handler (must be a top-level function, not a
// method, per firebase_messaging requirements).
// ─────────────────────────────────────────────────────────────────────────────

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background isolate: keep this as lightweight as possible.
  if (kDebugMode) {
    debugPrint('[NotificationService] Background FCM: ${message.messageId}');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NotificationService
// ─────────────────────────────────────────────────────────────────────────────

class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _fcm = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'ethereal_estate_channel',
    'Ethereal Estate Notifications',
    description: 'Property alerts and viewing reminders.',
    importance: Importance.high,
  );

  /// Initialises push notifications.
  ///
  /// On Flutter Web this is a no-op: FCM Web uses a Service Worker instead
  /// of `flutter_local_notifications`, and `Platform` calls are unavailable.
  /// Wrap any caller of this method in the same guard if needed.
  Future<void> initialize() async {
    // ── Web guard ────────────────────────────────────────────────────────────
    // kIsWeb is a compile-time constant; the web bundle never compiles the
    // block below, so Platform.isAndroid / Platform.isIOS are never evaluated.
    if (kIsWeb) {
      if (kDebugMode) {
        debugPrint(
          '[NotificationService] Skipping local notifications on Web. '
              'Configure FCM Web via firebase_messaging + a Service Worker instead.',
        );
      }
      return;
    }

    // ── Native guard ─────────────────────────────────────────────────────────
    // Only Android and iOS support flutter_local_notifications.
    // We use `defaultTargetPlatform` (web-safe) as the primary check, and
    // fall back to `Platform.*` for any edge-cases.  Both are only reached
    // when `kIsWeb` is false (see block above).
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

    if (!isAndroid && !isIOS) {
      if (kDebugMode) {
        debugPrint(
          '[NotificationService] Local notifications not supported on '
              '${defaultTargetPlatform.name}. Skipping.',
        );
      }
      return;
    }

    // Register the background handler before any other FCM setup.
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Request notification permission (Android 13+, iOS).
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Create the high-priority Android notification channel.
    if (isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);
    }

    // Initialise the local notifications plugin.
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(initSettings);

    // Listen for foreground messages and show them as local notifications.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    });

    final token = await _fcm.getToken();
    if (kDebugMode) debugPrint('[NotificationService] FCM Token: $token');
  }

  /// Returns the FCM device token, or `null` on Web / unsupported platforms.
  Future<String?> getToken() async {
    // Web: no device token (FCM Web uses a different registration flow).
    if (kIsWeb) return null;

    // Only meaningful on Android and iOS.
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    if (!isAndroid && !isIOS) return null;

    return _fcm.getToken();
  }
}