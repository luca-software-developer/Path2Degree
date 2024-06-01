import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/timezone.dart';

class EsameNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    tz.initializeTimeZones();
  }

  Future<void> scheduleExamNotification(
      String nome, DateTime dataOra, String luogo) async {
    if (dataOra.isBefore(DateTime.now())) return;
    await flutterLocalNotificationsPlugin.zonedSchedule(
        nome.hashCode,
        'Esame \'$nome\'',
        'L\'esame \'$nome\' è alle ${DateFormat('HH:mm').format(dataOra)} presso \'$luogo\'.',
        TZDateTime.from(dataOra.add(const Duration(days: -1)), tz.local),
        const NotificationDetails(
            android: AndroidNotificationDetails('esami', 'esami')),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> cancelExamNotification(String nome) async {
    await flutterLocalNotificationsPlugin.cancel(nome.hashCode);
  }
}
