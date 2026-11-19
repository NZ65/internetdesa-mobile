import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static const String channelLosId = 'los_emergency_alarm_v3';
  static const String channelLosName = '🚨 Alarm Darurat Pelanggan LOS (Kabel Putus)';
  static const String channelLosDesc = 'Notifikasi prioritas tertinggi bersuara lantang & bergetar saat kabel optik pelanggan terputus.';

  static const String channelGeneralId = 'general_alerts_channel_v3';
  static const String channelGeneralName = 'Pemberitahuan Internet Desa';
  static const String channelGeneralDesc = 'Pemberitahuan tiket gangguan, konfirmasi pembayaran, dan operasional jaringan.';

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

        // 1. High Priority LOS Channel with explicit ringtone sound & strong vibration pattern
        await androidImplementation.createNotificationChannel(
          AndroidNotificationChannel(
            channelLosId,
            channelLosName,
            description: channelLosDesc,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            vibrationPattern: Int64List.fromList([0, 500, 250, 500, 250, 800]),
            enableLights: true,
            audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
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
            enableVibration: true,
            audioAttributesUsage: AudioAttributesUsage.notification,
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
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelLosId,
        channelLosName,
        channelDescription: channelLosDesc,
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        enableLights: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 250, 500, 250, 800]),
        playSound: true,
        audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
        category: AndroidNotificationCategory.alarm,
        styleInformation: const BigTextStyleInformation(''),
      );

      final NotificationDetails platformDetails = NotificationDetails(
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
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelGeneralId,
        channelGeneralName,
        channelDescription: channelGeneralDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.notification,
        showWhen: true,
      );

      final NotificationDetails platformDetails = NotificationDetails(
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

  /// Uji nada dering & getar notifikasi dari aplikasi
  static Future<void> testNotificationSound() async {
    await showLosNotification(
      customerName: 'Uji Coba Alarm Suara',
      detail: 'Nada dering peringatan darurat & getaran bekerja sempurna!',
      notificationId: 99999,
    );
  }
}
