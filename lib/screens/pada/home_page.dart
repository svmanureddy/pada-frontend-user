import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deliverapp/core/services/api_service.dart';
import 'package:deliverapp/core/services/notification_service.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:deliverapp/screens/pada/review_page.dart';
import 'package:deliverapp/screens/pada/subVehicle_list_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/providers/app_provider.dart';
import '../../core/services/storage_service.dart';
import '../../core/utils.dart';
import '../../widgets/alert_dialog_widget.dart';
import '../../widgets/loading_indicator.dart';
import 'map_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  var vehicleList;
  var bannerList = [];
  int? _selectedVehicle;
  int _currentBannerIndex = 0;
  late final PageController _bannerController;
  final List<Map<String, dynamic>> promoSlides = const [
    {
      'title': 'Top up your wallet',
      'subtitle': 'Enjoy instant discounts on rides',
      'colors': [Color(0xFF0057E7), Color(0xFF2A7BFF)],
      'asset': 'assets/images/percentage.svg',
    },
    {
      'title': 'Refer & earn',
      'subtitle': 'Invite friends and get rewards',
      'colors': [Color(0xFF00C6FF), Color(0xFF0072FF)],
      'asset': 'assets/images/wallet.svg',
    },
    {
      'title': 'Safe deliveries',
      'subtitle': 'Live tracking and verified partners',
      'colors': [Color(0xFF003D9E), Color(0xFF0066FF)],
      'asset': 'assets/images/truck.svg',
    },
  ];
  bool isLocationEnabled = false;
  bool isLocationEnabledChecked = false;
  bool isLoaded = false;
  double? latMe;
  double? longMe;
  TextEditingController fromLocController = TextEditingController();
  TextEditingController toLocController = TextEditingController();

  // Animation Controllers
  late AnimationController _cardEntranceController;
  late AnimationController _shadowPulseController;
  late AnimationController _iconPulseController;
  late AnimationController _gradientController;
  late AnimationController _breathingController;
  late AnimationController _particleController;

  // Animations
  late Animation<double> _cardEntranceAnimation;
  late Animation<double> _shadowPulseAnimation;
  late Animation<double> _iconPulseAnimation;
  late Animation<double> _gradientAnimation;
  late Animation<double> _breathingAnimation;

  // State variables
  bool _isFromFocused = false;
  bool _isToFocused = false;
  List<Particle> _particles = [];

  // BottomNavigationBar? _bottomNavigationBar;

  @override
  void initState() {
    super.initState();

    // Initialize Animation Controllers
    _cardEntranceController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _shadowPulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _iconPulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _gradientController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000))
      ..repeat();
    _breathingController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat(reverse: true);
    _particleController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100))
      ..repeat();

    // Initialize Animations
    _cardEntranceAnimation =
        CurvedAnimation(parent: _cardEntranceController, curve: Curves.easeOut);
    _shadowPulseAnimation =
        Tween<double>(begin: 8, end: 12).animate(_shadowPulseController);
    _iconPulseAnimation =
        Tween<double>(begin: 1.0, end: 1.15).animate(_iconPulseController);
    _gradientAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_gradientController);
    _breathingAnimation = Tween<double>(begin: 0.998, end: 1.002).animate(
        CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut));

    _initParticles();

    // Start entrance animation after first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _cardEntranceController.reset();
        _cardEntranceController.forward();
      }
    });

    _bannerController = PageController(viewportFraction: 0.92);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      handlePermissions();
    });
    getVehicleList();
    getBannerList();
  }

  void _initParticles() {
    _particles = List.generate(15, (index) {
      return Particle(
        position: Offset(
          (index * 40) % 300.0,
          (index * 60) % 400.0,
        ),
        velocity: Offset(
          (index % 2 == 0 ? 1 : -1) * (0.5 + (index % 3) * 0.3),
          (index % 3 == 0 ? 1 : -1) * (0.3 + (index % 2) * 0.2),
        ),
        color: primaryColor.withOpacity(0.1),
        size: 2.0 + (index % 3),
      );
    });
  }


  Future<void> handlePermissions() async {
    // Check location permissions first
    await checkIsLocationEnabled();
    // await Future.delayed(const Duration(milliseconds: 500));
    // After location permission is handled, request notification permission
    await requestNotificationPermissions();
  }

  Future<void> requestNotificationPermissions() async {
    while (true) {
      // Check the current permission status
      var status = await Permission.notification.status;
      var hasAskedForPermission =
          await storageService.getNotificationAsk() ?? "false";

      if (status.isGranted) {
        print('Notification permission granted');
        return;
      }
      if (hasAskedForPermission == "true") {
        print('Notification permission has already been requested.');
        return; // Exit if permission has already been requested
      }

      if (status.isPermanentlyDenied) {
        storageService.setNotificationAsk("true");
        print('Notification permission permanently denied');
        CustomAlertDialog().successDialog(
            context,
            "Alert",
            "Open settings to enable notification permission!",
            "Yes! Open",
            "No", () async {
          openAppSettings().then((onValue) {
            Navigator.of(context).pop();
          });
        }, () {
          Navigator.of(context).pop();
        });
        // Redirect to settings
        return; // Exit the loop after permanent denial
      }

      // Request permission
      var result = await Permission.notification.request();

      if (result.isGranted) {
        print('Notification permission granted');
        return;
      } else if (result.isDenied) {
        print('Notification permission denied, trying again...');
        // Loop will automatically continue for the next attempt
      }
    }
  }

  Future<void> checkIsLocationEnabled() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    if (Platform.isAndroid) {
      var statusPermission = await Permission.location.status;
      if (!statusPermission.isGranted || statusPermission.isLimited) {
        await Permission.location.request();
      }
    }

    isLocationEnabled = await Permission.location.serviceStatus.isEnabled;

    Permission.location.serviceStatus.asStream().listen((event) {
      isLocationEnabled = event != ServiceStatus.disabled;
    });

    if (isLocationEnabled) {
      var location = await geo.Geolocator.getCurrentPosition();
      await appProvider.setLatLong(
          lat: location.latitude, lng: location.longitude);

      Placemark address = await getAddressFromLatLong(
          lat: location.latitude, lng: location.longitude);
      appProvider.setCurrentLocationAddress(address: address);
    }

    setState(() {
      isLocationEnabledChecked = true;
    });
  }

  getVehicleList() async {
    var resp = await ApiService().getVehicleList(parentId: "");
    debugPrint("vehicle List::::: $resp");
    vehicleList = resp.data;
    // Future.delayed(const Duration(seconds: 1), () {
    isLoaded = true;
    // });
    setState(() {});
  }

  getBannerList() async {
    var resp = await ApiService().getBannerImage("external");
    debugPrint("banner List::::: $resp");
    bannerList = resp['data'];
    setState(() {});
  }

  @override
  void dispose() {
    _cardEntranceController.dispose();
    _shadowPulseController.dispose();
    _iconPulseController.dispose();
    _gradientController.dispose();
    _breathingController.dispose();
    _particleController.dispose();
    _bannerController.dispose();
    fromLocController.dispose();
    toLocController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_particleController.isAnimating) {
        setState(() {
          for (var particle in _particles) {
            particle.update();
            if (particle.isOffScreen(
                Size(MediaQuery.of(context).size.width * 0.92, 400))) {
              particle.position = Offset(
                  math.Random().nextDouble() *
                      MediaQuery.of(context).size.width *
                      0.92,
                  -10);
            }
          }
        });
      }
    });
    return Scaffold(
      // bottomNavigationBar: _bottomNavigationBar,
      backgroundColor: pureWhite,
      body: vehicleList == null || vehicleList.length == 0 || !isLoaded
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.10,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [primaryColor, primaryColor],
                              stops: [0.0, 1.0]),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [primaryColor, primaryColor],
                              stops: [0.0, 1.0]),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 0),
                        child: Center(
                          child: FadeTransition(
                            opacity: _cardEntranceAnimation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                      begin: const Offset(0, 0.3),
                                      end: Offset.zero)
                                  .animate(_cardEntranceAnimation),
                              child: AnimatedBuilder(
                                animation: _shadowPulseAnimation,
                                builder: (context, child) {
                                  return Card(
                                    elevation: _shadowPulseAnimation.value,
                                    shadowColor: Colors.black12,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        // Animated gradient background
                                        AnimatedBuilder(
                                          animation: _gradientAnimation,
                                          builder: (context, child) {
                                            return Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Color.lerp(
                                                                primaryColor
                                                                    .withOpacity(
                                                                        0.05),
                                                                secondaryColor
                                                                    .withOpacity(
                                                                        0.08),
                                                                _gradientAnimation
                                                                    .value) ??
                                                            primaryColor
                                                                .withOpacity(
                                                                    0.05),
                                                        pureWhite,
                                                      ],
                                                      stops: const [
                                                        0.0,
                                                        1.0
                                                      ]),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16)),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.92,
                                            );
                                          },
                                        ),
                                        // Breathing effect
                                        AnimatedBuilder(
                                          animation: _breathingAnimation,
                                          builder: (context, child) {
                                            return Transform.scale(
                                              scale: _breathingAnimation.value,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                    color: pureWhite,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16)),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.92,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    FadeTransition(
                                                      opacity:
                                                          _cardEntranceAnimation,
                                                      child: SlideTransition(
                                                        position: Tween<Offset>(
                                                                begin:
                                                                    const Offset(
                                                                        -0.3,
                                                                        0),
                                                                end:
                                                                    Offset.zero)
                                                            .animate(
                                                                _cardEntranceAnimation),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 6.0,
                                                                  left: 2.0),
                                                          child: Text("From",
                                                              style: GoogleFonts.inter(
                                                                  color:
                                                                      secondaryColor,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                        ),
                                                      ),
                                                    ),
                                                    AnimatedBuilder(
                                                      animation:
                                                          _iconPulseAnimation,
                                                      builder:
                                                          (context, child) {
                                                        return TextFormField(
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          readOnly: true,
                                                          onTap: () {
                                                            HapticFeedback
                                                                .selectionClick();
                                                            setState(() {
                                                              _isFromFocused =
                                                                  true;
                                                            });
                                                            Navigator.push(
                                                                context,
                                                                (MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        const AddressPage(
                                                                          locType:
                                                                              'pickup',
                                                                        )))).then(
                                                                (value) {
                                                              if (value ==
                                                                  true) {
                                                                fromLocController
                                                                        .text =
                                                                    appProvider
                                                                        .pickupAddress!
                                                                        .addressString!;
                                                                setState(() {
                                                                  _isFromFocused =
                                                                      false;
                                                                });
                                                              }
                                                            });
                                                          },
                                                          controller:
                                                              fromLocController,
                                                          onChanged: (_) =>
                                                              setState(() {}),
                                                          autovalidateMode:
                                                              AutovalidateMode
                                                                  .onUserInteraction,
                                                          validator: (str) {
                                                            if (str!.isEmpty) {
                                                              return 'This field must not be empty';
                                                            }
                                                            return null;
                                                          },
                                                          style:
                                                              GoogleFonts.inter(
                                                                  color:
                                                                      pureBlack,
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                          decoration:
                                                              InputDecoration(
                                                                  isDense: true,
                                                                  contentPadding: const EdgeInsets.symmetric(
                                                                      vertical:
                                                                          14,
                                                                      horizontal:
                                                                          0),
                                                                  filled: true,
                                                                  fillColor: const Color(
                                                                      0xFFF6F6F6),
                                                                  labelText:
                                                                      "Pick-up location",
                                                                  floatingLabelBehavior:
                                                                      FloatingLabelBehavior
                                                                          .auto,
                                                                  hintText:
                                                                      "Pick-up location",
                                                                  prefixIcon:
                                                                      Stack(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            12.0),
                                                                        child: Transform
                                                                            .scale(
                                                                          scale: _isFromFocused
                                                                              ? _iconPulseAnimation.value
                                                                              : 1.0,
                                                                          child:
                                                                              SvgPicture.asset(
                                                                            'assets/images/source_ring.svg',
                                                                            height:
                                                                                20,
                                                                            width:
                                                                                20,
                                                                            fit:
                                                                                BoxFit.contain,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  suffixIcon:
                                                                      fromLocController
                                                                              .text
                                                                              .isNotEmpty
                                                                          ? IconButton(
                                                                              icon: const Icon(Icons.close, size: 18, color: Color(0xFF9E9E9E)),
                                                                              onPressed: () {
                                                                                fromLocController.clear();
                                                                                setState(() {});
                                                                              },
                                                                            )
                                                                          : null,
                                                                  border: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12),
                                                                      borderSide: const BorderSide(
                                                                          color: Colors
                                                                              .transparent)),
                                                                  enabledBorder: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12),
                                                                      borderSide: BorderSide(
                                                                          color: _isFromFocused
                                                                              ? secondaryColor.withOpacity(0.3)
                                                                              : Colors.transparent,
                                                                          width: _isFromFocused ? 2 : 0)),
                                                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: secondaryColor, width: 2))),
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(height: 12),
                                                    FadeTransition(
                                                      opacity:
                                                          _cardEntranceAnimation,
                                                      child: SlideTransition(
                                                        position: Tween<Offset>(
                                                                begin:
                                                                    const Offset(
                                                                        -0.3,
                                                                        0),
                                                                end:
                                                                    Offset.zero)
                                                            .animate(
                                                                _cardEntranceAnimation),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 6.0,
                                                                  left: 2.0),
                                                          child: Text("To",
                                                              style: GoogleFonts.inter(
                                                                  color:
                                                                      secondaryColor,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600)),
                                                        ),
                                                      ),
                                                    ),
                                                    AnimatedBuilder(
                                                      animation:
                                                          _iconPulseAnimation,
                                                      builder:
                                                          (context, child) {
                                                        return TextFormField(
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          readOnly: true,
                                                          controller:
                                                              toLocController,
                                                          onChanged: (_) =>
                                                              setState(() {}),
                                                          onTap: () {
                                                            HapticFeedback
                                                                .selectionClick();
                                                            setState(() {
                                                              _isToFocused =
                                                                  true;
                                                            });
                                                            Navigator.push(
                                                                context,
                                                                (MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        const AddressPage(
                                                                          locType:
                                                                              'drop',
                                                                        )))).then(
                                                                (value) {
                                                              if (value ==
                                                                  true) {
                                                                toLocController
                                                                        .text =
                                                                    appProvider
                                                                        .dropAddress!
                                                                        .addressString!;
                                                                setState(() {
                                                                  _isToFocused =
                                                                      false;
                                                                });
                                                              }
                                                            });
                                                          },
                                                          autovalidateMode:
                                                              AutovalidateMode
                                                                  .onUserInteraction,
                                                          validator: (str) {
                                                            if (str!.isEmpty) {
                                                              return 'This field must not be empty';
                                                            }
                                                            return null;
                                                          },
                                                          style:
                                                              GoogleFonts.inter(
                                                                  color:
                                                                      pureBlack,
                                                                  fontSize: 15,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400),
                                                          decoration:
                                                              InputDecoration(
                                                                  isDense: true,
                                                                  contentPadding: const EdgeInsets.symmetric(
                                                                      vertical:
                                                                          14,
                                                                      horizontal:
                                                                          0),
                                                                  filled: true,
                                                                  fillColor: const Color(
                                                                      0xFFF6F6F6),
                                                                  labelText:
                                                                      "Drop-off location",
                                                                  floatingLabelBehavior:
                                                                      FloatingLabelBehavior
                                                                          .auto,
                                                                  hintText:
                                                                      "Drop-off location",
                                                                  prefixIcon:
                                                                      Stack(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            12.0),
                                                                        child: Transform
                                                                            .scale(
                                                                          scale: _isToFocused
                                                                              ? _iconPulseAnimation.value
                                                                              : 1.0,
                                                                          child:
                                                                              SvgPicture.asset(
                                                                            'assets/images/dest_marker.svg',
                                                                            height:
                                                                                20,
                                                                            width:
                                                                                20,
                                                                            fit:
                                                                                BoxFit.contain,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  suffixIcon:
                                                                      toLocController
                                                                              .text
                                                                              .isNotEmpty
                                                                          ? IconButton(
                                                                              icon: const Icon(Icons.close, size: 18, color: Color(0xFF9E9E9E)),
                                                                              onPressed: () {
                                                                                toLocController.clear();
                                                                                setState(() {});
                                                                              },
                                                                            )
                                                                          : null,
                                                                  border: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12),
                                                                      borderSide: const BorderSide(
                                                                          color: Colors
                                                                              .transparent)),
                                                                  enabledBorder: OutlineInputBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              12),
                                                                      borderSide: BorderSide(
                                                                          color: _isToFocused
                                                                              ? Colors.red.withOpacity(0.3)
                                                                              : Colors.transparent,
                                                                          width: _isToFocused ? 2 : 0)),
                                                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 2))),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        // Floating particles
                                        AnimatedBuilder(
                                          animation: _particleController,
                                          builder: (context, child) {
                                            return CustomPaint(
                                              painter: ParticlePainter(
                                                  particles: _particles),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.22,
                      child: PageView.builder(
                        controller: _bannerController,
                        onPageChanged: (i) =>
                            setState(() => _currentBannerIndex = i),
                        itemCount: promoSlides.length,
                        itemBuilder: (context, index) {
                          final slide = promoSlides[index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: List<Color>.from(
                                          slide['colors'] ??
                                              [
                                                Color(0xFF0057E7),
                                                Color(0xFF2A7BFF)
                                              ]),
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(slide['title'] ?? '',
                                                  style: GoogleFonts.inter(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              const SizedBox(height: 6),
                                              Text(slide['subtitle'] ?? '',
                                                  style: GoogleFonts.inter(
                                                      color: Colors.white
                                                          .withOpacity(0.9),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        SizedBox(
                                          width: 72,
                                          height: 72,
                                          child: slide['asset'] != null
                                              ? SvgPicture.asset(slide['asset'],
                                                  fit: BoxFit.contain)
                                              : const SizedBox.shrink(),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(promoSlides.length, (i) {
                        final active = i == _currentBannerIndex;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: active ? secondaryColor : greyBorderColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: Center(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.05,
                        ),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () async {
                              LoadingOverlay.of(context).show();
                              if (fromLocController.text != '' &&
                                  toLocController.text != '') {
                                var distance = await ApiService().distanceCalc([
                                  appProvider.pickupAddress!.latlng!.latitude,
                                  appProvider.pickupAddress!.latlng!.longitude,
                                ], [
                                  appProvider.dropAddress!.latlng!.latitude,
                                  appProvider.dropAddress!.latlng!.longitude,
                                ]);
                                if (distance['success']) {
                                  if (distance['data'] != null) {
                                    double calculatedTotal = double.parse(
                                            distance['data'].toString()) *
                                        double.parse(vehicleList[index]
                                            .price
                                            .toString());
                                    debugPrint("///////dist :: $distance");
                                    _selectedVehicle = index;
                                    setState(() {});
                                    if (appProvider.pickupAddress != null &&
                                        appProvider.dropAddress != null &&
                                        _selectedVehicle != null) {
                                      await ApiService()
                                          .getVehicleList(
                                              parentId: vehicleList[index].sId)
                                          .then((value) {
                                        LoadingOverlay.of(context).hide();
                                        if (value.success == true) {
                                          if (value.data!.isNotEmpty) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SubVehicleListPage(
                                                          vehicleList:
                                                              value.data,
                                                        )));
                                          } else {
                                            // Navigate directly to ReviewPage
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ReviewPage(
                                                  vehicleDetail: vehicleList[index],
                                                  price: calculatedTotal.ceilToDouble(),
                                                  distance: double.parse(
                                                    distance['data'].toString(),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      });
                                    }
                                  }
                                }
                              } else {
                                LoadingOverlay.of(context).hide();
                                notificationService.showToast(context,
                                    "Please enter both pickup and drop addresses",
                                    type: NotificationType.warning);
                              }
                            },
                            child: vehicleCard(vehicleList[index].name,
                                vehicleList[index].image, index),
                          );
                        },
                        itemCount: vehicleList.length,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  Padding carousalWidget(BuildContext context, image) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.15,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: secondaryColor, borderRadius: BorderRadius.circular(10)),
          child: Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Topup your wallet",
                      style: GoogleFonts.inter(
                          color: pureWhite,
                          fontSize: 20,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "To win Exiting Discounts !  ",
                      style: GoogleFonts.inter(
                          color: pureWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
                SizedBox(
                    child: SvgPicture.network('$imageUrl$image',
                        fit: BoxFit.contain)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Stack vehicleCard(String name, String image, int index) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.45,
          child: Card(
            elevation: _selectedVehicle == index ? 2 : 4,
            shadowColor: _selectedVehicle == index
                ? Colors.deepOrange
                : Colors.grey.shade200,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                    color: _selectedVehicle == index
                        ? Colors.deepOrange
                        : Colors.grey)),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      child: SvgPicture.network("$imageUrl$image",
                          fit: BoxFit.contain)),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            name,
                            style: GoogleFonts.inter(
                                color: pureBlack,
                                fontSize: 14,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Book Now ",
                              style: GoogleFonts.inter(
                                  color: pureBlack,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w300),
                            ),
                            SvgPicture.asset(
                              'assets/images/arrow_next.svg',
                              fit: BoxFit.fill,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        _selectedVehicle == index
            ? Positioned(
                right: 10,
                top: 10,
                child: Align(
                  alignment: Alignment.topRight,
                  child: SizedBox(
                      child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.deepOrangeAccent),
                          child: const Icon(
                            Icons.done,
                            color: pureWhite,
                            size: 18,
                          ))),
                ))
            : const Offstage()
      ],
    );
  }
}

class Particle {
  Offset position;
  Offset velocity;
  Color color;
  double size;

  Particle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
  });

  void update() {
    position = position + velocity;
  }

  bool isOffScreen(Size bounds) {
    return position.dx < 0 ||
        position.dx > bounds.width ||
        position.dy < 0 ||
        position.dy > bounds.height;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return oldDelegate.particles != particles;
  }
}

