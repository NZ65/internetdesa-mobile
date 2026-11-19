import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static const String channelLosId = 'los_alerts_channel_v2';
  static const String channelLosName = '🚨 Peringatan Pelanggan LOS (Kabel Putus)';
  static const String channelLosDesc = 'Notifikasi darurat bila terdeteksi kabel fiber optik pelanggan terputus atau hilang sinyal.';

  static const String channelGeneralId = 'general_alerts_channel_v2';
  static const String channelGeneralName = 'Notifikasi & Info Internet Desa';
  static const String channelGeneralDesc = 'Pemberitahuan tiket gangguan, pembayaran tagihan, dan operasional jaringan.';

  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      // Create Android Notification Channels
      final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        // Request runtime permission for Android 13+
        await androidImplementation.requestNotificationsPermission();

        // 1. High Priority LOS Channel
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            channelLosId,
            channelLosName,
            description: channelLosDesc,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            enableLights: true,
          ),
        );

        // 2. General Channel
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            channelGeneralId,
            channelGeneralName,
            description: channelGeneralDesc,
            importance: Importance.high,
            playSound: true,
          ),
        );
      }

      _isInitialized = true;
      debugPrint('✅ NotificationService initialized successfully');
    } catch (e) {
      debugPrint('⚠️ Error initializing NotificationService: $e');
    }
  }

  /// Tampilkan notifikasi darurat saat terdeteksi pelanggan LOS (Kabel Putus)
  static Future<void> showLosNotification({
    required String customerName,
    required String detail,
    int? notificationId,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelLosId,
        channelLosName,
        channelDescription: channelLosDesc,
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableLights: true,
        enableVibration: true,
        playSound: true,
        category: AndroidNotificationCategory.alarm,
        styleInformation: BigTextStyleInformation(''),
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      final id = notificationId ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await _notificationsPlugin.show(
        id,
        '🚨 ALERT: Pelanggan LOS Terdeteksi!',
        '$customerName: $detail',
        platformDetails,
        payload: 'los_detail',
      );
    } catch (e) {
      debugPrint('Error showing LOS notification: $e');
    }
  }

  /// Tampilkan notifikasi umum (Tiket baru / Tagihan / Sistem)
  static Future<void> showGeneralNotification({
    required String title,
    required String body,
    int? notificationId,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelGeneralId,
        channelGeneralName,
        channelDescription: channelGeneralDesc,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      final id = notificationId ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
      );
    } catch (e) {
      debugPrint('Error showing general notification: $e');
    }
  }
}
