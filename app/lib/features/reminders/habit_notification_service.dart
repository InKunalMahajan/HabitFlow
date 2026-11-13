import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'reminder_settings.dart';

/// Device-only daily notifications. No sound is required for a reminder.
/// Native setup and permission approval are required before delivery works.
class HabitNotificationService {
  HabitNotificationService._();
  static final HabitNotificationService instance = HabitNotificationService._();
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get supported => !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
       defaultTargetPlatform == TargetPlatform.android);

  Future<void> initialize() async {
    if (_initialized || !supported) return;
    tzdata.initializeTimeZones();
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (!supported) return false;
    await initialize();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: false, sound: false) ?? false;
    }
    return await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission() ?? false;
  }

  Future<bool> notificationsAllowed() async {
    if (!supported) return false;
    await initialize();
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final settings = await _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.checkPermissions();
      return settings?.isEnabled ?? false;
    }
    final allowed = await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    return allowed ?? false;
  }

  Future<void> scheduleDaily(ReminderSettings setting, String habitTitle) async {
    if (!supported) return;
    await initialize();
    await _plugin.cancel(id: setting.habitId);
    if (!setting.enabled || !await notificationsAllowed()) return;
    final now = tz.TZDateTime.now(tz.local);
    var at = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, setting.hour, setting.minute,
    );
    if (!at.isAfter(now)) {
      at = tz.TZDateTime(
        tz.local, now.year, now.month, now.day + 1,
        setting.hour, setting.minute,
      );
    }
    await _plugin.zonedSchedule(
      id: setting.habitId,
      title: 'HabitFlow reminder',
      body: 'Time for your habit: $habitTitle',
      scheduledDate: at,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'habitflow_daily_habits',
          'Daily habit reminders',
          channelDescription: 'Text reminders for daily habits',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          playSound: false,
        ),
        iOS: DarwinNotificationDetails(presentSound: false),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Pending IDs belonging to HabitFlow's daily reminder channel.
  /// The app currently schedules only habit reminders through this plugin.
  Future<Set<int>> pendingReminderIds() async {
    if (!supported) return <int>{};
    await initialize();
    final pending = await _plugin.pendingNotificationRequests();
    return pending.map((notification) => notification.id).toSet();
  }

  Future<void> cancel(int habitId) async {
    if (!supported) return;
    await initialize();
    await _plugin.cancel(id: habitId);
  }
}
