import 'dart:convert';

import 'package:deliverapp/core/colors.dart';
import 'package:deliverapp/screens/pada/wallet_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push/push.dart';
import 'package:flutter/material.dart';

import '../../routers/routing_constants.dart';
import '../../screens/pada/bottom_navigation_page.dart';
import 'navigation_service.dart';

class PushNotificationServiceByPush {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> setupInteractedMessage() async {
    await _initializePushNotifications();
  }

  Future<void> _initializePushNotifications() async {
    // Initialize the Push package
    await Push.instance.requestPermission();

    // Handle notification launching app from terminated state
    Push.instance.notificationTapWhichLaunchedAppFromTerminated.then((data) {
      if (data == null) {
        debugPrint("App was not launched by tapping a notification");
      } else {
        _handleNavigation(data);
      }
    });

    // Handle notification taps
    Push.instance.onNotificationTap.listen((data) {
      debugPrint('Notification was tapped:\nData: $data');
      _handleNavigation(data);
        });

    // Handle push notifications received while app is in foreground
    Push.instance.addOnMessage((message) {
      debugPrint('Notification received in foreground:\nData: ${message.data}');
      if (message.notification != null) {
        final Map<String, dynamic> body =
            json.decode(message.data!['body'] as String);
        final String? title = body['title'] as String?;
        final String? description = body['description'] as String?;
        showNotification(
          title: title,
          body: description,
          data: message.data,
        );
      }
    });

    // Handle background notifications
    Push.instance.addOnBackgroundMessage((message) {
      debugPrint('Notification received in background:\nData: ${message.data}');
      if (message.notification != null) {
        final Map<String, dynamic> body =
            json.decode(message.data!['body'] as String);
        final String? title = message.data!['title'] as String?;
        final String? description = body['description'] as String?;
        showNotification(
          title: title,
          body: description,
          data: message.data,
        );
      }
    });

    // Initialize local notifications
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(
        android: androidInitSettings, iOS: initializationSettingsIOS);
    await _localNotificationsPlugin.initialize(initSettings);
  }

  static void showNotification({
    required String? title,
    required String? body,
    required Map<String?, Object?>? data,
  }) {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      color: primaryColor,
      icon: '@mipmap/ic_launcher',
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    _localNotificationsPlugin.show(
      0, // Notification ID
      title,
      body,
      platformDetails,
      payload: json.encode(data), // Pass data as a JSON string
    );
  }

  void _handleNavigation(Map<String?, dynamic> data) {
    debugPrint("Handling navigation with data: $data");

    if (data.containsKey('payload')) {
      Map<String, dynamic> payload = json.decode(data['payload']);
      if (payload.containsKey('body')) {
        Map<String, dynamic> body = json.decode(payload['body']);
        String? type = body['type']?.toString();

        if (type == '1') {
          debugPrint("Navigating to Home Screen");
          navigationService.navigatePushNamedAndRemoveUntilTo(
              homeScreenRoute, null);
        } else if (type == '4') {
        } else if (type == '5') {
          debugPrint("Navigating to Dashboard Screen");
          Navigator.pushAndRemoveUntil(
            navigationService.currentContext,
            MaterialPageRoute(builder: (context) => const WalletPage()),
            (Route<dynamic> route) => false,
          );
        } else if (type == '6') {
          debugPrint("Navigating to Promotions Screen");
          Navigator.pushAndRemoveUntil(
            navigationService.currentContext,
            MaterialPageRoute(builder: (context) => const BottomNavPage()),
            (Route<dynamic> route) => false,
          );
        } else {
          debugPrint("Unhandled notification type");
        }
      }
    }
  }
}

// import 'dart:convert';
//
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:push/push.dart';
// import 'package:flutter/material.dart';
//
// import '../../routers/routing_constants.dart';
// import '../../screens/pada/dashboard_page.dart';
// import '../../screens/pada/order_history_page.dart';
// import 'navigation_service.dart';
//
// class PushNotificationServiceByPush {
//   static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   Future<void> setupInteractedMessage() async {
//     await _initializePushNotifications();
//   }
//
//   Future<void> _initializePushNotifications() async {
//     // Initialize the Push package
//     await Push.instance.requestPermission();
//
//     // Handle notification launching app from terminated state
//     Push.instance.notificationTapWhichLaunchedAppFromTerminated.then((data) {
//       if (data == null) {
//         debugPrint("App was not launched by tapping a notification");
//       } else {
//         _handleNavigation(data as RemoteMessage);
//       }
//     });
//
//     // Handle notification taps
//     Push.instance.onNotificationTap.listen((data) {
//       debugPrint('Notification was tapped:\n'
//           'Data: ${data} \n');
//       if (data == null) {
//         debugPrint("App was not launched by tapping a notification");
//       } else {
//         _handleNavigation(data as RemoteMessage);
//       }
//     });
//
//     // Handle push notifications
//     Push.instance.addOnMessage((message) {
//       debugPrint('RemoteMessage received while app is in foreground:\n'
//           'RemoteMessage.Notification: ${message.notification} \n'
//           ' title: ${message.notification?.title.toString()}\n'
//           ' body: ${message.notification?.body.toString()}\n'
//           'RemoteMessage.Data: ${message.data}');
//
//       debugPrint("firebase notification listening::=======> ${message.data}");
//       if (message.notification != null) {
//         showNotification(
//           title: message.notification!.title,
//           body: message.notification!.body,
//           data: message.data,
//         );
//       }
//     });
//
//     // Handle push notifications
//     Push.instance.addOnBackgroundMessage((message) {
//       debugPrint('RemoteMessage received while app is in background:\n'
//           'RemoteMessage.Notification: ${message.notification} \n'
//           ' title: ${message.notification?.title.toString()}\n'
//           ' body: ${message.notification?.body.toString()}\n'
//           'RemoteMessage.Data: ${message.data}');
//     });
//
//     // Initialize local notifications
//     const AndroidInitializationSettings androidInitSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidInitSettings,
//     );
//     await _localNotificationsPlugin.initialize(initSettings);
//   }
//
//   static void showNotification({
//     required String? title,
//     required String? body,
//     required Map<String?, Object?>? data,
//   }) {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'high_importance_channel',
//       'High Importance Notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const NotificationDetails platformDetails =
//         NotificationDetails(android: androidDetails);
//
//     _localNotificationsPlugin.show(
//       0, // Notification ID
//       title,
//       body,
//       platformDetails,
//       payload: data.toString(),
//     );
//   }
//
//   void _handleNavigation(RemoteMessage data) {
//     if (data == null) return;
//     debugPrint("Handling navigation for type: ${data.data}");
//
//     String? type = data.data.toString();
//     dynamic encode = json.decode(type);
//     debugPrint("json decode: ${encode}");
//
//     if (type == '1') {
//       debugPrint("Navigating to Home Screen");
//       navigationService.navigatePushNamedAndRemoveUntilTo(
//           homeScreenRoute, null);
//     } else if (type == '4') {
//       debugPrint("Navigating to Order History Screen");
//       Navigator.pushAndRemoveUntil(
//         navigationService.currentContext,
//         MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
//         (Route<dynamic> route) => false,
//       );
//     } else if (type == '5') {
//       debugPrint("Navigating to Dashboard Screen");
//       Navigator.pushAndRemoveUntil(
//         navigationService.currentContext,
//         MaterialPageRoute(builder: (context) => const DashboardPage()),
//         (Route<dynamic> route) => false,
//       );
//     } else if (type == '6') {
//       debugPrint("Navigating to Promotions Screen");
//       Navigator.pushAndRemoveUntil(
//         navigationService.currentContext,
//         MaterialPageRoute(builder: (context) => const DashboardPage()),
//         (Route<dynamic> route) => false,
//       );
//     } else {
//       debugPrint("Unhandled notification type");
//     }
//   }
// }
