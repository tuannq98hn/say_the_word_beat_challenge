// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter/material.dart';
//
// class NotificationHelper {
//   static final FlutterLocalNotificationsPlugin _localNotifications =
//       FlutterLocalNotificationsPlugin();
//
//   static Future<void> initialize() async {
//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const iosSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//
//     const initSettings = InitializationSettings(
//       android: androidSettings,
//       iOS: iosSettings,
//     );
//
//     await _localNotifications.initialize(
//       initSettings,
//     );
//   }
//
//   static Future<void> showLocalNotification({
//     required int id,
//     required String title,
//     required String body,
//   }) async {
//     const androidDetails = AndroidNotificationDetails(
//       'channel_id',
//       'channel_name',
//       channelDescription: 'channel_description',
//       importance: Importance.high,
//       priority: Priority.high,
//     );
//
//     const iosDetails = DarwinNotificationDetails();
//
//     const notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
//
//     await _localNotifications.show(
//       id,
//       title,
//       body,
//       notificationDetails,
//     );
//   }
//
//   static void showTopSnackBarMessage(
//     BuildContext context,
//     String message, {
//     Color? backgroundColor,
//     Color? textColor,
//     Duration duration = const Duration(seconds: 3),
//   }) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: backgroundColor ?? Colors.red,
//         duration: duration,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }
// }
//
