import 'dart:async';
import 'package:deliverapp/widgets/alert_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deliverapp/core/models/create_connect_response.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/errors/exceptions.dart';
import '../../core/providers/app_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/services/navigation_service.dart';
import '../../core/services/notification_service.dart';
import '../../routers/routing_constants.dart';
import 'bottom_navigation_page.dart';

class OrderMapPage extends StatefulWidget {
  final String? orderId;
  final String? vehicleName;
  const OrderMapPage({
    super.key,
    required this.orderId,
    this.vehicleName,
  });

  @override
  State<OrderMapPage> createState() => _OrderMapPageState();
}

class _OrderMapPageState extends State<OrderMapPage>
    with TickerProviderStateMixin {
  // IO.Socket? socketi;
  double value = 0.0;
  late Timer timer;
  CameraPosition? cameraPosition;
  bool isloaded = true;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(13.1344635197085, 77.6717135197085),
    zoom: 12.4746,
  );
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Animation Controllers
  late AnimationController _headerController;

  // Animations
  late Animation<double> _headerAnimation;

  List<String> cancelReasonList = [
    "Driver taking too long",
    "Need to change order details",
  ];

  @override
  void initState() {
    super.initState();
    connectSocket();

    // Initialize Animation Controllers
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Initialize Animations
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );

    // Start entrance animations after first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _headerController.forward();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _headerController.dispose();
    super.dispose();
  }

  updateProgress() async {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (t) {
      setState(() {
        value += 0.00333;
        if (double.parse(value.toStringAsFixed(1)) >= 0.999) {
          t.cancel();

          navigationService.navigatePushNamedAndRemoveUntilTo(
              notAcceptScreenRoute, null);
          // Navigator.pushAndRemoveUntil<void>(
          //   context,
          //   MaterialPageRoute<void>(
          //       builder: (BuildContext context) => const NotAcceptedPage()),
          //   ModalRoute.withName('/'),
          // );
        }
      });
    });
  }

  cancelDialog(BuildContext context) async {
    try {
      await ApiService()
          .cancelOrder(
              widget.orderId.toString(), "Need to change order details")
          .then((value) {
        if (value['success']) {
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const BottomNavPage()),
              ModalRoute.withName('/home'),
            );

            // navigationService.navigatePushNamedAndRemoveUntilTo(
            //     homeScreenRoute, null);
          }
        } else {
          notificationService.showToast(context, "Something went wrong",
              type: NotificationType.error);
        }
      });
    } catch (e) {
      if (context.mounted) {
        if (e is ClientException) {
          notificationService.showToast(context, e.message,
              type: NotificationType.error);
        }
        if (e is HttpException) {
          notificationService.showToast(context, e.message,
              type: NotificationType.error);
        }
        if (e is ServerException) {
          notificationService.showToast(context, e.message,
              type: NotificationType.error);
        }
      }
    }
  }

  connectSocket() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    updateProgress();

    // try {
    await appProvider.socketConnect();
    appProvider.socketIO!.onConnect((_) {
      debugPrint(
          '<=========== SOCKET CONNECTED: ${appProvider.socketIO!.id}===========>');
      // socketi!.emit(
      //   'postLiveLocation',
      //   {
      //     "userDetails": {
      //       "location": [
      //         double.parse(appProvider.latitude),
      //         double.parse(appProvider.longitude)
      //       ]
      //     },
      //   },
      // );
      //
      //   debugPrint("=======> before getLiveLocation");
      //
      appProvider.socketIO!.on('getAcceptOrder', (data) {
        debugPrint(
            '<=========== GET LIVE LOCATION SOCKET LISTEN DATA $data ===========>');
        if (data.length != 0) {
          debugPrint('<=========== GET LIVE  DATA $data ===========>');
          debugPrint('<=========== GET ONE DATA ${data['userId']} ===========>');
          appProvider.setAcceptedData(
            ReqAcceptModel(
                userId: data['userId'],
                deliveryBoyId: data['deliveryBoy'],
                orderId: data['orderId'],
                firstName: data['firstName'],
                lastName: data['lastName'],
                phoneNumber: data['phoneNumber'],
                email: data['email'],
                image: data['image'],
                shortCode: data['shortCode'],
                gender: data['gender'],
                vehicleNumber: data['vehicleNumber'],
                vehicle: data['vehicle'],
                location: [data['location'][0], data['location'][1]],
                pickUp: PickUp(
                    address: data['pickUp']['address'],
                    location: [
                      data['pickUp']['location'][0],
                      data['pickUp']['location'][1]
                    ],
                    userName: data['pickUp']['userName'],
                    phoneNumber: data['pickUp']['phoneNumber']),
                drop: PickUp(
                    address: data['drop']['address'],
                    location: [
                      data['drop']['location'][0],
                      data['drop']['location'][1]
                    ],
                    userName: data['drop']['userName'],
                    phoneNumber: data['drop']['phoneNumber']),
                totalAmount: data["totalAmount"].toString(),
                discountAmount: data["discountAmount"].toString(),
                userPaid: data["userPaid"].toString()),
          );
          // if (context.mounted) {
          navigationService.navigatePushNamedAndRemoveUntilTo(
              onAcceptScreenRoute, null);
          // Navigator.pushAndRemoveUntil(
          //   context,
          //   MaterialPageRoute(builder: (context) => const OrderAcceptedPage()),
          //   ModalRoute.withName('/onAccepted'),
          // );
          // }
        } else {
          debugPrint('<=========== NO DATA ===========>');
        }
        // _add(appProvider);
      });
      // });

      appProvider.socketIO!.onDisconnect((_) {
        debugPrint('<=========== SOCKET DISCONNECTED ===========>');
      });
    });
    // } catch (e) {
    //   debugPrint("<============ SOCKET CONNECTION FAILED $e==============>");
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: primaryColor,
        appBar: PreferredSize(
          preferredSize: Size(
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).padding.top + 60,
          ),
          child: FadeTransition(
            opacity: _headerAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.3),
                end: Offset.zero,
              ).animate(_headerAnimation),
            child: Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12.0,
                  bottom: 12.0,
                  left: 16.0,
                  right: 16.0,
                ),
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [primaryColor, primaryColor],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Finding a Driver",
                      style: GoogleFonts.inter(
                        color: pureWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                  ),
                ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: PopScope(
          canPop: false,
          onPopInvoked: (bool) async {
            if (!bool) {
              CustomAlertDialog().successDialog(
                  context,
                  "Alert",
                  "Do you want to cancel the order?",
                  "Yes, Cancel",
                  "No", () async {
                cancelDialog(context);
              }, () {
                Navigator.of(context, rootNavigator: true).pop();
              });
            }
          },
          child: !isloaded
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SafeArea(
                  child: SizedBox(
                    child: Stack(
                      fit: StackFit.passthrough,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: GoogleMap(
                            // zoomControlsEnabled: true,
                            // markers: _markers,
                            onCameraMove: (CameraPosition position) async {},
                            mapType: MapType.normal,
                            initialCameraPosition: _kGooglePlex,
                            myLocationButtonEnabled: false,
                            // polylines: Set<Polyline>.of(polylines.values),
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 800),
                            tween: Tween(begin: 0.0, end: 1.0),
                            curve: Curves.easeOut,
                            builder: (context, animValue, child) {
                              return Transform.translate(
                                offset: Offset(0, 30 * (1 - animValue)),
                                child: Opacity(
                                  opacity: animValue,
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                            child: Card(
                                elevation: 8,
                                shadowColor: Colors.black.withOpacity(0.12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(24.0),
                                  decoration: BoxDecoration(
                              color: pureWhite,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                  children: [
                                      // Progress Bar
                                      Container(
                                        height: 8,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color: buttonColor.withOpacity(0.2),
                                        ),
                                        child: FractionallySizedBox(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: value.clamp(0.0, 1.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [buttonColor, secondaryColor],
                                              ),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      // Main Text
                                    Text(
                                        _getFindingDriverMessage(),
                                      style: GoogleFonts.inter(
                                          color: pureBlack,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                    ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      // Sub Text
                                    Text(
                                        "Please wait a moment",
                                      style: GoogleFonts.inter(
                                          color: addressTextColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                    ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      // Cancel Order Button
                                      Container(
                                        width: double.infinity,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: greyBorderColor,
                                            width: 1,
                                          ),
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                              // Navigate directly to home screen
                                                                            Navigator.pushAndRemoveUntil(
                                                                              context,
                                                MaterialPageRoute(
                                                  builder: (context) => const BottomNavPage(),
                                                ),
                                                                              ModalRoute.withName('/home'),
                                                                            );
                                            },
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                                vertical: 12.0,
                                                                ),
                                          child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                                  Icon(
                                                    Icons.close,
                                                    color: errorColor,
                                                    size: 20,
                                                ),
                                                  const SizedBox(width: 8),
                                              Text(
                                                "Cancel Order",
                                                style: GoogleFonts.inter(
                                                      color: errorColor,
                                                    fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                              ),
                                            ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
        ));
  }

  String _getFindingDriverMessage() {
    final vehicleName = widget.vehicleName?.toLowerCase() ?? '';
    
    // Check for common vehicle types and return appropriate message
    if (vehicleName.contains('500') || vehicleName.contains('kg') || 
        vehicleName.contains('truck') || vehicleName.contains('container')) {
      return "Finding drivers for heavy vehicles nearby";
    } else if (vehicleName.contains('2 wheeler') || vehicleName.contains('2wheeler') || 
               vehicleName.contains('scooter') || vehicleName.contains('bike')) {
      return "Finding 2 Wheeler drivers nearby";
    } else if (vehicleName.contains('3 wheeler') || vehicleName.contains('3wheeler') || 
               vehicleName.contains('auto')) {
      return "Finding 3 Wheeler drivers nearby";
    } else if (vehicleName.contains('4 wheeler') || vehicleName.contains('4wheeler') || 
               vehicleName.contains('car')) {
      return "Finding 4 Wheeler drivers nearby";
    } else if (vehicleName.isNotEmpty) {
      // Use vehicle name if available
      return "Finding ${widget.vehicleName} drivers nearby";
    } else {
      // Default message
      return "Finding drivers nearby";
    }
  }
}
