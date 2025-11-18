import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/navigation_service.dart';
import '../../routers/routing_constants.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  var bannerList = [];
  int _currentBanner = 0;
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
      'colors': [Color(0xFFFF8A00), Color(0xFFFFC300)],
      'asset': 'assets/images/truck.svg',
    },
  ];
  getBannerList() async {
    var resp = await ApiService().getBannerImage("external");
    debugPrint("banner List::::: $resp");
    bannerList = resp['data'];
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bannerController = PageController(viewportFraction: 0.92);
    getBannerList();
  }

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pureWhite,
      body: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.30,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: primaryColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.15,
                            height: MediaQuery.of(context).size.height * 0.06,
                            child: SvgPicture.asset(
                                'assets/images/pada_logo.svg',
                                fit: BoxFit.fill)),
                        Text("Pada Delivery",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                                color: pureWhite,
                                fontSize: 24,
                                fontWeight: FontWeight.w900))
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.22,
                      child: PageView.builder(
                        controller: PageController(viewportFraction: 0.92),
                        onPageChanged: (i) =>
                            setState(() => _currentBanner = i),
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
                        final active = i == _currentBanner;
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
                  // Padding(
                  //   padding: const EdgeInsets.all(5.0),
                  //   child: SizedBox(
                  //     height: 50,
                  //     width: MediaQuery.of(context).size.width * 0.8,
                  //     child: CustomButton(
                  //         buttonLabel: "Goods Delivery",
                  //         backGroundColor: buttonColor,
                  //         onTap: () {
                  //           navigationService.navigatePushNamedAndRemoveUntilTo(
                  //               homeScreenRoute, null);
                  //           // if (context.mounted) {
                  //           //   Navigator.pushAndRemoveUntil(
                  //           //     context,
                  //           //     MaterialPageRoute(
                  //           //         builder: (context) => const BottomNavPage()),
                  //           //     (Route<dynamic> route) => false,
                  //           //   );
                  //           // }
                  //         },
                  //         fontWeight: FontWeight.bold,
                  //         buttonWidth: double.infinity),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: InkWell(
                        onTap: () {
                          navigationService.navigatePushNamedAndRemoveUntilTo(
                              homeScreenRoute, null);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Card(
                          elevation: 8,
                          shadowColor: Colors.black.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: pureWhite,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: secondaryColor.withOpacity(0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Illustration Container
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: secondaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        'assets/images/delivery_bike.svg',
                                        width: 64,
                                        height: 64,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Text Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Goods Delivery",
                                          style: GoogleFonts.inter(
                                            color: secondaryColor,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "Fast pickup and drop for your packages",
                                          style: GoogleFonts.inter(
                                            color: addressTextColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Arrow Icon Container
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: secondaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 18,
                                      color: secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(5.0),
                  //   child: SizedBox(
                  //     height: 50,
                  //     width: MediaQuery.of(context).size.width * 0.8,
                  //     child: CustomButton(
                  //         buttonLabel: "Express Delivery",
                  //         backGroundColor: buttonColor,
                  //         onTap: () async {
                  //           authProvider.clearLoginCredentials();
                  //           if (context.mounted) {
                  //             Navigator.pushAndRemoveUntil(
                  //               context,
                  //               MaterialPageRoute(
                  //                   builder: (context) =>
                  //                       const LoginPage()),
                  //               (Route<dynamic> route) => false,
                  //             );
                  //           }
                  //         },
                  //         fontWeight: FontWeight.bold,
                  //         buttonWidth: double.infinity),
                  //   ),
                  // ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
