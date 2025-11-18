import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deliverapp/core/services/api_service.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/providers/app_provider.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils.dart';
import 'bottom_navigation_page.dart';
import 'home_page.dart';

class OrderAcceptedPage extends StatefulWidget {
  const OrderAcceptedPage({super.key});

  @override
  State<OrderAcceptedPage> createState() => _OrderAcceptedPageState();
}

class _OrderAcceptedPageState extends State<OrderAcceptedPage> {
  CameraPosition? cameraPosition;
  Uint8List? greenMarker;
  Uint8List? redMarker;
  bool isLoaded = false;
  bool isExpanded = false;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(13.1344635197085, 77.6717135197085),
    zoom: 14.4746,
  );
  List<String> cancelReasonList = [
    "Driver taking too long",
    "Need to change order details",
  ];

  // Marker (fixed marker)
  late final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    connectAndListen();
    Future.delayed(const Duration(seconds: 2), () async {
      await setMarker();
    });
  }

  void connectAndListen() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    await appProvider.socketConnect();
    // try {
    debugPrint("=======> before getOrderComplete");

    appProvider.socketIO!.on('getOrderComplete', (data) async {
      debugPrint('<=========== GET RESULT OF getOrderComplete $data ===========>');
      debugPrint(
          '<=========== GET RESULT OF getOrderComplete ${data['orderData']} ===========>');
      if (data != null) {
        await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      }
      // debugPrint(
      // '<========================================================= ${data} ===========>');

      // if (data != null) {}
    });
  }

  setMarker() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    _markers.clear();
    final Uint8List redMarker =
        await getBytesFromAsset('assets/images/map_marker.png', 100);
    final Uint8List greenMarker =
        await getBytesFromAsset('assets/images/green_marker.png', 100);
    _markers.add(
      Marker(
        //add start location marker
        markerId: const MarkerId("Marker_2"),
        // markerId: MarkerId(widget.userData!.drop!.latitude.toString()),
        position: appProvider.dropAddress!.latlng!, //position of marker
        infoWindow: const InfoWindow(
          title: 'Destination',
          snippet: "Delivery Addresss",
        ),
        icon: BitmapDescriptor.fromBytes(redMarker),
      ),
    );

    _markers.add(
      Marker(
        markerId: const MarkerId("Marker_1"),
        // markerId: MarkerId(widget.userData!.source!.longitude.toString()),
        position: appProvider.pickupAddress!.latlng!,
        infoWindow: const InfoWindow(
          //popup info
          title: 'Source',
          snippet: 'Pickup Address',
        ),
        icon: BitmapDescriptor.fromBytes(greenMarker),
      ),
    );
    isLoaded = true;
    setState(() {});
    await getRoute(
        PointLatLng(_markers.first.position.latitude,
            _markers.first.position.longitude),
        PointLatLng(
            _markers.last.position.latitude, _markers.last.position.longitude),
        appProvider);
  }

  getRoute(PointLatLng start, PointLatLng end, AppProvider appProvider) async {
    polylines.clear();
    polylineCoordinates.clear();
    String? mapKey = await SecureStorageUtil.getValue("mapApiKey");

    while(mapKey==null){
      Future.delayed(const Duration(milliseconds: 100));
    }

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: mapKey,
        request: PolylineRequest(
          origin: start,
          destination: end,
          mode: TravelMode.driving,
        ));

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      debugPrint("polyline points:::$polylineCoordinates");
    } else {
      debugPrint("result error:::${result.errorMessage}");
    }

    addPolyLine(polylineCoordinates, appProvider);
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        // on below line we have given positions of Location 5
        CameraPosition(
          target: appProvider.pickupAddress!.latlng!,
          zoom: 16,
        ),
      ),
    );
    // await controller.showMarkerInfoWindow(const MarkerId('Marker_1'));
    // await controller.showMarkerInfoWindow(const MarkerId('Marker_2'));
    // setState(() {});
  }

  addPolyLine(List<LatLng> polylineCoordinates, AppProvider appProvider) {
    PolylineId id = const PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.black,
      points: polylineCoordinates,
      width: 2,
    );
    polylines[id] = polyline;
    setState(() {});
  }
  //
  // cancelDialog(BuildContext context) async {
  //   final appProvider = Provider.of<AppProvider>(context, listen: false);
  //   await ApiService()
  //       .cancelOrder(appProvider.acceptedData!.orderId.toString(),
  //           "Need to change order details")
  //       .then((value) {
  //     if (value['success']) {
  //       if (context.mounted) {
  //         Navigator.pushAndRemoveUntil(
  //           context,
  //           MaterialPageRoute(builder: (context) => const BottomNavPage()),
  //           ModalRoute.withName('/home'),
  //         );
  //
  //         // navigationService.navigatePushNamedAndRemoveUntilTo(
  //         //     homeScreenRoute, null);
  //       }
  //     } else {
  //       notificationService.showToast(context, "Something went wrong",
  //           type: NotificationType.error);
  //     }
  //   });
  // }

  Future<void> cancelDialog(BuildContext context, String? reason) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    try {
      // Make the API call
      final response = await ApiService().cancelOrder(
        appProvider.acceptedData!.orderId.toString(),
        reason ?? "Need to change order details",
      );

      // Check if the response indicates success
      if (response['success'] == true) {
        if (context.mounted) {
          // Navigate to home page on success
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavPage()),
            ModalRoute.withName('/home'),
          );
        }
      } else {
        // Handle API failure response
        notificationService.showToast(
          context,
          response['message'] ??
              "Something went wrong", // Use the message from the response
          type: NotificationType.error,
        );
      }
    } on DioException catch (dioError) {
      // Handle Dio-specific errors
      notificationService.showToast(
        context,
        dioError.response?.data['message'] ?? "Network error occurred",
        type: NotificationType.error,
      );
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

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    return Scaffold(
        backgroundColor: pureWhite,
        appBar: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height * 0.05),
          child: SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(100),
                bottomRight: Radius.circular(100),
              )),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // shape: const RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.only(
                  //   bottomLeft: Radius.circular(30),
                  //   bottomRight: Radius.circular(30),
                  // )),
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    //   child: InkWell(
                    //     child: const Icon(
                    //       Icons.arrow_back_ios,
                    //       color: pureBlack,
                    //     ),
                    //     onTap: () {
                    //       Navigator.pop(context);
                    //     },
                    //   ),
                    // ),
                    // Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Booking Confirmed",
                          style: GoogleFonts.inter(
                              color: pureBlack,
                              fontSize: 18,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: pureWhite,
                      ),
                    ),
                  ]),
            ),
          ),
        ),
        body: PopScope(
          canPop: false,
          onPopInvoked: (bool) async {
            // if (!bool) {
            //   CustomAlertDialog().successDialog(
            //       context,
            //       "Alert",
            //       "Do you want to cancel the order?",
            //       "Yes, Cancel",
            //       "No", () async {
            //     cancelDialog(context);
            //   }, () {
            Navigator.of(context, rootNavigator: true).pop();
            //   });
            // }
          },
          child: !isLoaded
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
                            markers: _markers,
                            onCameraMove: (CameraPosition position) async {},
                            mapType: MapType.normal,
                            initialCameraPosition: _kGooglePlex,
                            myLocationButtonEnabled: false,
                            polylines: Set<Polyline>.of(polylines.values),
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                          ),
                        ),
                        Positioned(
                            child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Card(
                              elevation: 4,
                              color: pureWhite,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: SizedBox(
                                height: !isExpanded
                                    ? MediaQuery.of(context).size.height * 0.25
                                    : MediaQuery.of(context).size.height * 0.45,
                                width: MediaQuery.of(context).size.width * 0.90,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Center(
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            isExpanded = !isExpanded;
                                          });
                                        },
                                        child: Icon(
                                          !isExpanded
                                              ? Icons.keyboard_arrow_up_sharp
                                              : Icons.keyboard_arrow_down_sharp,
                                          color: pureBlack,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                    isExpanded
                                        ? Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(15),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10.0),
                                                      child: SvgPicture.asset(
                                                          'assets/images/source_ring.svg',
                                                          width: 18,
                                                          height: 18,
                                                          fit: BoxFit.contain),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.7,
                                                      child: Text(
                                                        appProvider
                                                            .acceptedData!
                                                            .pickUp!
                                                            .address!,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 3,
                                                        style:
                                                            GoogleFonts.inter(
                                                                color:
                                                                    pureBlack,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(15),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10.0),
                                                      child: SvgPicture.asset(
                                                          'assets/images/dest_marker.svg',
                                                          width: 16,
                                                          height: 16,
                                                          fit: BoxFit.contain),
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.7,
                                                      child: Text(
                                                        appProvider
                                                            .acceptedData!
                                                            .drop!
                                                            .address!,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 3,
                                                        style:
                                                            GoogleFonts.inter(
                                                                color:
                                                                    pureBlack,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        : const Offstage(),
                                    isExpanded
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                CircleAvatar(
                                                  radius: 30,
                                                  backgroundColor: Colors
                                                      .transparent, // Optional: Set a background color if needed
                                                  child: ClipOval(
                                                    child: appProvider
                                                            .acceptedData!
                                                            .image!
                                                            .toString()
                                                            .contains(".svg")
                                                        ? SvgPicture.network(
                                                            "$imageUrl${appProvider.acceptedData!.image!}",
                                                            fit: BoxFit.cover)
                                                        : Image.network(
                                                            "$imageUrl${appProvider.acceptedData!.image!}",
                                                            fit: BoxFit
                                                                .cover, // Ensures the image is cropped to fill the circle
                                                            width:
                                                                60, // Match the CircleAvatar diameter (2 * radius)
                                                            height: 60,
                                                          ),
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text(
                                                          "${appProvider.acceptedData!.firstName!} ${appProvider.acceptedData!.lastName!}",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style:
                                                              GoogleFonts.inter(
                                                                  color:
                                                                      pureBlack,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                        ),
                                                        Text(
                                                          appProvider
                                                              .acceptedData!
                                                              .phoneNumber!,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          style:
                                                              GoogleFonts.inter(
                                                                  color:
                                                                      pureBlack,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 10.0),
                                                      child: InkWell(
                                                        onTap: () {
                                                          // "${appProvider.acceptedData?.vehicleNumber}";

                                                          launchURL(Uri.parse(
                                                              'tel:${appProvider.acceptedData?.phoneNumber}'));
                                                        },
                                                        child: const Icon(
                                                          Icons.call,
                                                          color: buttonColor,
                                                          size: 24,
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        : const Offstage(),
                                    !isExpanded
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0),
                                            child: Card(
                                              elevation: 3,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.37,
                                                      child: Text(
                                                        appProvider
                                                            .pickupAddress!
                                                            .addressString!,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style:
                                                            GoogleFonts.inter(
                                                                color:
                                                                    pureBlack,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                      ),
                                                    ),
                                                    const Icon(
                                                      Icons.arrow_forward,
                                                      color: pureBlack,
                                                      size: 24,
                                                      weight: 20,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.37,
                                                      child: Text(
                                                        appProvider.dropAddress!
                                                            .addressString!,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        style:
                                                            GoogleFonts.inter(
                                                                color:
                                                                    pureBlack,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ))
                                        : const Offstage(),
                                    !isExpanded
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 15.0, vertical: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${appProvider.acceptedData?.phoneNumber}", // "${appProvider.acceptedData?.vehicleNumber}", // "2 Wheeler - KA-05-MB-4116",
                                                      style: GoogleFonts.inter(
                                                          color: pureBlack,
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                    Text(
                                                      "${appProvider.acceptedData?.firstName} ${appProvider.acceptedData?.lastName}",
                                                      style: GoogleFonts.inter(
                                                          color: const Color(
                                                              0XFF939393),
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ],
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    // "${appProvider.acceptedData?.vehicleNumber}";

                                                    launchURL(Uri.parse(
                                                        'tel:${appProvider.acceptedData?.phoneNumber}'));
                                                  },
                                                  child: const Icon(
                                                    Icons.call,
                                                    color: buttonColor,
                                                    size: 24,
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        : const Offstage(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0, vertical: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Cash",
                                            style: GoogleFonts.inter(
                                                color: pureBlack,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          // Row(
                                          //   children: [
                                          Text(
                                            "$rupeeSymbol  ${appProvider.acceptedData?.totalAmount}",
                                            style: GoogleFonts.inter(
                                                color: pureBlack,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          //     const Padding(
                                          //       padding: EdgeInsets.only(left: 8.0),
                                          //       child: Icon(
                                          //         Icons.info_outline,
                                          //         // color: buttonColor,
                                          //         size: 24,
                                          //       ),
                                          //     )
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.30,
                                        child: InkWell(
                                          onTap: () {
                                            showModalBottomSheet(
                                                context: context,
                                                builder: (context2) {
                                                  return SizedBox(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.20,
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.95,
                                                    child:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(15.0),
                                                            child: Text(
                                                              "Reason For Cancellation",
                                                              style: GoogleFonts.inter(
                                                                  color:
                                                                      pureBlack,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          ),
                                                          ListView.builder(
                                                            shrinkWrap: true,
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            itemBuilder:
                                                                (context2,
                                                                    index) {
                                                              return ListTile(
                                                                onTap:
                                                                    () async {
                                                                  cancelDialog(
                                                                      context,
                                                                      cancelReasonList[
                                                                          index]);
                                                                  //appProvider.acceptedData?.orderId
                                                                },
                                                                leading: Text(
                                                                  cancelReasonList[
                                                                      index],
                                                                  style: GoogleFonts.inter(
                                                                      color:
                                                                          pureBlack,
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400),
                                                                ),
                                                                trailing:
                                                                    const Icon(
                                                                  Icons
                                                                      .arrow_forward,
                                                                  color: Color(
                                                                      0XFF939393),
                                                                  size: 20,
                                                                ),
                                                              );
                                                            },
                                                            itemCount:
                                                                cancelReasonList
                                                                    .length,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                });
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              const Icon(
                                                Icons.cancel,
                                                color: buttonColor,
                                                size: 18,
                                              ),
                                              Text(
                                                "Cancel Order",
                                                style: GoogleFonts.inter(
                                                    color: pureBlack,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
        ));
  }
}
