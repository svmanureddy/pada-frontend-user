// import 'package:deliverapp/routers/router.dart';
// import 'package:deliverapp/screens/splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import 'core/colors.dart';
// import 'core/providers/providers_list.dart';
//
// class App extends StatefulWidget {
//   App({super.key, this.navigatorKey});
//   GlobalKey<NavigatorState>? navigatorKey;
//
//   @override
//   AppState createState() => AppState();
// }
//
// class AppState extends State<App> {
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//   @override
//   Widget build(BuildContext context) {
//     ///Build a tree of providers from a list of SingleChildWidget.
//     return MultiProvider(
//       providers: providers(),
//
//       ///For internet connectivity check.
//       child: /*StreamProvider<ConnectivityStatus>(
//           initialData: ConnectivityStatus.wifi,
//           create: (context) {
//             return ConnectivityService().connectionStatusController.stream;
//           },
//           child:*/
//           MaterialApp(
//         builder: (context, child) {
//           final myMediaQuery = MediaQuery.of(context);
//           return MediaQuery(
//               data: MediaQuery.of(context).copyWith(
//                   textScaler: myMediaQuery.textScaler
//                       .clamp(minScaleFactor: 0.8, maxScaleFactor: 1.0)),
//               child: Stack(
//                 children: [
//                   child!,
//
//                   /// support minimizing
//                   // ZegoUIKitPrebuiltCallMiniOverlayPage(
//                   //   contextQuery: () {
//                   //     return widget.navigatorKey!.currentState!.context;
//                   //   },
//                   // ),
//                 ],
//               ));
//         },
//         title: "Pada Delivery",
//         theme: ThemeData(
//             useMaterial3: false,
//             // textTheme: const TextTheme(
//             //   bodySmall: TextStyle(fontSize: 14.0),
//             // ),
//             primaryColor: primaryColor,
//             scaffoldBackgroundColor: scaffoldBackgroundColor,
//             fontFamily: 'openSans',
//             colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
//                 .copyWith(secondary: accentColor)
//                 .copyWith(background: backgroundColor)),
//         debugShowCheckedModeBanner: false,
//         navigatorKey: navigatorKey, //navigationService.navigatorKey,
//         onGenerateRoute: generateRoute,
//         //initialRoute: orderScreenRoute,
//         home: const SplashScreen(),
//       ),
//       // ),
//     );
//   }
// }
