import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin? _plugin;

  static const String _stepChannelId = 'bcycle_steps';
  static const String _stepChannelName = 'BCycle Adım Sayacı';
  static const int _stepNotifId = 1001;

  static Future<void> initialize(FlutterLocalNotificationsPlugin plugin) async {
    _plugin = plugin;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await plugin.initialize(initSettings);

    // Android 13+ için izin iste
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Silinemeyen adım sayacı bildirimi (ongoing)
  static Future<void> showStepNotification({
    required int steps,
    required int goal,
    required double calories,
  }) async {
    if (_plugin == null) return;

    final double progress = (steps / goal).clamp(0.0, 1.0);
    final String progressBar = _buildProgressBar(progress);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _stepChannelId,
      _stepChannelName,
      channelDescription: 'BCycle adım sayacı bildirimi',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,              // ← Silinemiyor!
      autoCancel: false,
      showWhen: false,
      enableVibration: false,
      playSound: false,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF7C3AED),
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(''),
    );

    final NotificationDetails details =
        const NotificationDetails(android: androidDetails);

    await _plugin!.show(
      _stepNotifId,
      '🚴 BCycle — $steps adım',
      '$progressBar  •  ${calories.toStringAsFixed(0)} kcal  •  Hedef: $goal',
      details,
    );
  }

  static String _buildProgressBar(double progress) {
    final int filled = (progress * 10).round();
    final String bar = '█' * filled + '░' * (10 - filled);
    return '[$bar] ${(progress * 100).round()}%';
  }

  /// Normal bildirim gönder
  static Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    if (_plugin == null) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'bcycle_general',
      'BCycle Bildirimleri',
      channelDescription: 'Genel BCycle bildirimleri',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: Color(0xFF7C3AED),
    );

    final NotificationDetails details =
        const NotificationDetails(android: androidDetails);

    await _plugin!.show(id, title, body, details);
  }

  /// Adım bildirimini kaldır
  static Future<void> cancelStepNotification() async {
    await _plugin?.cancel(_stepNotifId);
  }

  /// Tüm bildirimleri kaldır
  static Future<void> cancelAll() async {
    await _plugin?.cancelAll();
  }
}
