import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();
  final plugin = FlutterLocalNotificationsPlugin();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'operon_timers',
      'Operator timers',
      channelDescription: 'Operational timer reminders',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> initialize() async {
    tz_data.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  Future<void> requestPermissions() async {
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleTimer(
    int id,
    String title,
    String? tag,
    DateTime dueAt,
  ) async {
    await cancelTimer(id);
    final when = tz.TZDateTime.from(dueAt, tz.local);
    if (!when.isAfter(tz.TZDateTime.now(tz.local))) {
      await showDue(id, title, tag);
      return;
    }
    await plugin.zonedSchedule(
      id,
      'OPERON timer due',
      tag == null ? title : '$tag · $title',
      when,
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'timer:$id',
    );
  }

  Future<void> cancelTimer(int id) => plugin.cancel(id);

  Future<void> showDue(int id, String title, String? tag) => plugin.show(
        id,
        'OPERON timer due',
        tag == null ? title : '$tag · $title',
        _details,
        payload: 'timer:$id',
      );
}
