// import 'package:deliverapp/screens/pada/dashboard_page.dart';
// import 'package:deliverapp/screens/pada/order_history_page.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// import '../../routers/routing_constants.dart';
// import '../../screens/pada/home_page.dart';
// import 'navigation_service.dart';
//
// // ignore: slash_for_doc_comments
// /**
//  * Documents added by Alaa, enjoy ^-^:
//  * There are 3 major things to consider when dealing with push notification :
//  * - Creating the notification
//  * - Hanldle notification click
//  * - App status (foreground/background and killed(Terminated))
//  *
//  * Creating the notification:
//  *
//  * - When the app is killed or in background state, creating the notification is handled through the back-end services.
//  *   When the app is in the foreground, we have full control of the notification. so in this case we build the notification from scratch.
//  *
//  * Handle notification click:
//  *
//  * - When the app is killed, there is a function called getInitialMessage which
//  *   returns the remoteMessage in case we receive a notification otherwise returns null.
//  *   It can be called at any point of the application (Preferred to be after defining GetMaterialApp so that we can go to any screen without getting any errors)
//  * - When the app is in the background, there is a function called onMessageOpenedApp which is called when user clicks on the notification.
//  *   It returns the remoteMessage.
//  * - When the app is in the foreground, there is a function flutterLocalNotificationsPlugin, is passes a future function called onSelectNotification which
//  *   is called when user clicks on the notification.
//  *
//  * */
// class PushNotificationService {
//   static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//    Future<void> initialize() async {
//     // Request notification permissions
//     await FirebaseMessaging.instance.requestPermission();
//
//     // Handle foreground notifications
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
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
//     // Handle background notification taps
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       debugPrint("Notification data: ${message.data}");
//       handleNotificationTap(message.data);
//     });
//
//     // push.Push.instance.notificationTapWhichLaunchedAppFromTerminated
//     //     .then((data) {
//     //   if (data == null) {
//     //     debugPrint("App was not launched by tapping a notification");
//     //   } else {
//     //     debugPrint('Notification tap launched app from terminated state:\n'
//     //         'Data: $data \n');
//     //   }
//     //   // notificationWhichLaunchedApp.value = data;
//     // });
//     //
//     // // Handle notification taps
//     // final onNotificationTapSubscription =
//     // push.Push.instance.onNotificationTap.listen((data) {
//     //   debugPrint('Notification was tapped:\n'
//     //       'Data: $data \n');
//     //   // RemoteMessage message = data
//     //
//     //   // debugPrint("Notification data: $data");
//     //   // int type = data.keys.['payload']['body']['type'];
//     //   // debugPrint("data id 2: ---------- $type");
//     //   // if (type == 1) {
//     //   //   debugPrint("push notification::=>.............. Account created");
//     //
//     //   // navigationService.navigatePushNamedAndRemoveUntilTo(
//     //   //     homeScreenRoute, null);
//     //
//     //   Navigator.pushAndRemoveUntil(
//     //     navigationService.currentContext,
//     //     MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
//     //         (Route<dynamic> route) => false,
//     //   );
//     //   // } else if (type == 4) {
//     //   //   debugPrint("push notification::=>.............. order status");
//     //   //   Navigator.pushAndRemoveUntil(
//     //   //     navigationService.currentContext,
//     //   //     MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
//     //   //         (Route<dynamic> route) => false,
//     //   //   );
//     //   // } else if (type == 5) {
//     //   //   debugPrint("push notification::=>.............. payment completed");
//     //   //   Navigator.pushAndRemoveUntil(
//     //   //     navigationService.currentContext,
//     //   //     MaterialPageRoute(builder: (context) => const DashboardPage()),
//     //   //         (Route<dynamic> route) => false,
//     //   //   );
//     //   // } else if (type == 6) {
//     //   //   debugPrint("push notification::=>.............. promotion notify");
//     //   //   Navigator.pushAndRemoveUntil(
//     //   //     navigationService.currentContext,
//     //   //     MaterialPageRoute(builder: (context) => const DashboardPage()),
//     //   //         (Route<dynamic> route) => false,
//     //   //   );
//     //   // } else {
//     //   //   debugPrint("push notification::=>.............. notification added");
//     //   // }
//     //   // tappedNotificationPayloads.value += [data];
//     // });
//
//
//     // Handle terminated state notification taps
//     RemoteMessage? initialMessage =
//     await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       handleNotificationTap(initialMessage.data);
//     }
//
//     // Initialize local notifications
//     const AndroidInitializationSettings androidInitSettings =
//     AndroidInitializationSettings('@mipmap/ic_launcher');
//     const InitializationSettings initSettings = InitializationSettings(
//       android: androidInitSettings,
//     );
//     await _localNotificationsPlugin.initialize(initSettings);
//   }
//
//   static void showNotification({
//     required String? title,
//     required String? body,
//     required Map<String, dynamic> data,
//   }) {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'high_importance_channel',
//       'High Importance Notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const NotificationDetails platformDetails =
//     NotificationDetails(android: androidDetails);
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
//    void handleNotificationTap(Map<String, dynamic> data) {
//     // Navigate or perform actions based on data
//     debugPrint("Notification data: $data");
//     int type = data['body']['type'];
//     debugPrint("data id 2: ---------- $type");
//     if (type == 1) {
//       debugPrint("push notification::=>.............. Account created");
//
//       // navigationService.navigatePushNamedAndRemoveUntilTo(
//       //     homeScreenRoute, null);
//
//       Navigator.pushAndRemoveUntil(
//         navigationService.currentContext,
//         MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
//             (Route<dynamic> route) => false,
//       );
//     } else if (type == 4) {
//       debugPrint("push notification::=>.............. order status");
//       Navigator.pushAndRemoveUntil(
//         navigationService.currentContext,
//         MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
//             (Route<dynamic> route) => false,
//       );
//     } else if (type == 5) {
//       debugPrint("push notification::=>.............. payment completed");
//       Navigator.pushAndRemoveUntil(
//         navigationService.currentContext,
//         MaterialPageRoute(builder: (context) => const DashboardPage()),
//             (Route<dynamic> route) => false,
//       );
//     } else if (type == 6) {
//       debugPrint("push notification::=>.............. promotion notify");
//       Navigator.pushAndRemoveUntil(
//         navigationService.currentContext,
//         MaterialPageRoute(builder: (context) => const DashboardPage()),
//             (Route<dynamic> route) => false,
//       );
//     } else {
//       debugPrint("push notification::=>.............. notification added");
//     }
//   }
// }
//
// /*
// class PushNotificationService {
//   Future<void> setupInteractedMessage() async {
//     await setupForegroundNotification();
//     await registerNotificationListeners();
//     FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
//       if (message != null) {
//         debugPrint("setupNotificationHandler function ");
//         debugPrint("App launched from notification: ${message.data}");
//       }
//     });
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//
//       debugPrint("message opened: ---------- $message");
//       var data = message.data;
//       int type = data['body']['type'];
//       debugPrint("data id 2: ---------- $type");
//       if (type == 1) {
//         debugPrint("push notification::=>.............. Account created");
//
//         // navigationService.navigatePushNamedAndRemoveUntilTo(
//         //     homeScreenRoute, null);
//
//         Navigator.pushAndRemoveUntil(
//           navigationService.currentContext,
//           MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
//               (Route<dynamic> route) => false,
//         );
//       } else if (type == 4) {
//         debugPrint("push notification::=>.............. order status");
//         Navigator.pushAndRemoveUntil(
//           navigationService.currentContext,
//           MaterialPageRoute(builder: (context) => const OrderHistoryPage()),
//               (Route<dynamic> route) => false,
//         );
//       } else if (type == 5) {
//         debugPrint("push notification::=>.............. payment completed");
//         Navigator.pushAndRemoveUntil(
//           navigationService.currentContext,
//           MaterialPageRoute(builder: (context) => const DashboardPage()),
//               (Route<dynamic> route) => false,
//         );
//       } else if (type == 6) {
//         debugPrint("push notification::=>.............. promotion notify");
//         Navigator.pushAndRemoveUntil(
//           navigationService.currentContext,
//           MaterialPageRoute(builder: (context) => const DashboardPage()),
//               (Route<dynamic> route) => false,
//         );
//       } else {
//         debugPrint("push notification::=>.............. notification added");
//       }
//     });
//   }
//
//   registerNotificationListeners() async {
//     // await requestNotificationPermissions();
//     AndroidNotificationChannel channel = androidNotificationChannel();
//     final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//         FlutterLocalNotificationsPlugin();
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//     var androidSettings =
//         const AndroidInitializationSettings('@mipmap/ic_launcher');
//     var iOSSettings = const DarwinInitializationSettings(
//       requestSoundPermission: true,
//       requestBadgePermission: true,
//       requestAlertPermission: true,
//     );
//     var initSettings =
//         InitializationSettings(android: androidSettings, iOS: iOSSettings);
//     flutterLocalNotificationsPlugin.initialize(initSettings,
//         onDidReceiveNotificationResponse: (message) async {
//       // This function handles the click in the notification when the app is in foreground
//       // if (NotificationObject.notificationInfo.notificationType == "1") {
//       // } else if (NotificationObject.notificationInfo.notificationType == "2") {}
//     });
//
// // onMessage is called when the app is in foreground and a notification is received
//     FirebaseMessaging.onMessage.listen((RemoteMessage? message) {
//       // Get.find<HomeController>().getNotificationsNumber();
//       // message!.notification!.android!.sound! =
//       RemoteNotification? notification = message!.notification;
//       AndroidNotification? android = message.notification?.android;
//       AppleNotification? apple = message.notification?.apple;
//
// // If `onMessage` is triggered with a notification, construct our own
//       // local notification to show to users using the created channel.
//       if (notification != null && android != null) {
//         debugPrint(".........///////..... ${android.sound}");
//         debugPrint("data id 1: ---------- ${message.data}");
//         // Get.toNamed(ROUTE_BOOK_INTRO,
//         //         arguments: message.data['id'])
//         flutterLocalNotificationsPlugin.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           NotificationDetails(
//             android: AndroidNotificationDetails(
//               channel.id,
//               channel.name,
//               icon: android.smallIcon,
//               playSound: true,
//             ),
//           ),
//         );
//       }
//     });
//   }
//
//   Future<void> setupForegroundNotification() async {
//     try {
//       // Ensure Firebase is initialized before calling Firebase services
//       await Firebase.initializeApp();
//       NotificationSettings settings =
//           await FirebaseMessaging.instance.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
//
//       if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//         debugPrint('User granted permission');
//       } else if (settings.authorizationStatus ==
//           AuthorizationStatus.provisional) {
//         debugPrint('User granted provisional permission');
//       } else {
//         debugPrint('User declined or has not accepted permission');
//       }
//       await FirebaseMessaging.instance
//           .setForegroundNotificationPresentationOptions(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
//       // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//       debugPrint("Foreground notification settings applied successfully.");
//     } catch (e) {
//       debugPrint("Error setting foreground notification options: $e");
//     }
//   }
//
//   androidNotificationChannel() => const AndroidNotificationChannel(
//         'high_importance_channel', // id
//         'High Importance Notifications', // title // description
//         importance: Importance.max,
//       );
// }*/
