import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/event_model.dart';
import '../models/reminder_model.dart';
import 'hive_service.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    _isInitialized = true;
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    // Handle notification tap if needed
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidImplementation?.requestNotificationsPermission();
      final bool? canScheduleExact = await androidImplementation
          ?.canScheduleExactNotifications();

      if (canScheduleExact == false) {
        await androidImplementation?.requestExactAlarmsPermission();
      }
    }
  }

  Future<void> scheduleEventNotifications(
    EventModel event,
    List<ReminderModel> reminders,
  ) async {
    if (!event.notificationsEnabled) {
      await cancelEventNotifications(event, reminders);
      return;
    }

    // Attempt to cancel existing ones first to avoid duplicates if updating
    await cancelEventNotifications(event, reminders);

    for (final reminder in reminders) {
      if (!reminder.isEnabled) continue;

      final scheduleTime = event.targetDateTime.subtract(
        Duration(minutes: reminder.offsetMinutes),
      );

      // Don't schedule if it's already in the past
      if (scheduleTime.isBefore(DateTime.now())) continue;

      final tzScheduleTime = tz.TZDateTime.from(scheduleTime, tz.local);
      final notificationId = _stableId(reminder.id);
      final locale = HiveService.getSettings().locale;
      final isAr = locale == 'ar';

      String title = event.title;
      String body = '';

      if (reminder.offsetMinutes == 0) {
        body = isAr
            ? 'حان وقت ${event.title}!'
            : 'It is time for ${event.title}!';
      } else {
        final timeLabel = _getLocalizedTimeLabel(reminder.offsetMinutes, isAr);
        body = isAr
            ? 'بقي $timeLabel على ${event.title}!'
            : '${event.title} is coming up in $timeLabel!';
      }

      try {
        await _notificationsPlugin.zonedSchedule(
          notificationId,
          title,
          body,
          tzScheduleTime,
          _notificationDetails(),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e) {
        debugPrint('Error scheduling notification: $e');
      }
    }
  }

  Future<void> cancelEventNotifications(
    EventModel event,
    List<ReminderModel> reminders,
  ) async {
    for (final reminder in reminders) {
      final notificationId = _stableId(reminder.id);
      await _notificationsPlugin.cancel(notificationId);
    }
  }

  /// Shows an immediate notification (e.g. when a new event is added)
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'countdown_instant_channel',
        'Event Confirmations',
        channelDescription: 'Instant notifications when events are added',
        importance: Importance.high,
        priority: Priority.high,
        autoCancel: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    // Use current timestamp as unique ID for instant notifications
    final id = DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF;
    try {
      await _notificationsPlugin.show(id, title, body, details);
    } catch (e) {
      debugPrint('Error showing instant notification: $e');
    }
  }

  Future<void> cancelAll() async {
    ///await _notificationsPlugin.cancelAll();
  }

  String _getLocalizedTimeLabel(int minutes, bool isAr) {
    if (minutes < 60) {
      return isAr ? '$minutes دقيقة' : '$minutes min';
    }
    if (minutes < 1440) {
      final hours = minutes ~/ 60;
      return isAr ? '$hours ساعة' : '$hours hr';
    }
    final days = minutes ~/ 1440;
    return isAr ? '$days يوم' : '$days day';
  }

  int _stableId(String id) {
    var hash = 0x811c9dc5;
    for (final code in id.codeUnits) {
      hash ^= code;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash & 0x7FFFFFFF; // رقم موجب ضمن 32-bit
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'countdown_channel_id',
        'Countdown Reminders',
        channelDescription: 'Notifications for upcoming countdown events',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }
}
