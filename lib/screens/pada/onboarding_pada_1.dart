import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';
import '../../core/services/navigation_service.dart';
import '../../routers/routing_constants.dart';
import '../../widgets/button.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_Slide> _slides = const [
    _Slide(
      asset: 'assets/images/onboarding_1.svg',
      title: 'Pickup anywhere',
      subtitle:
          'Book a pickup from your doorstep or any saved address in seconds.',
    ),
    _Slide(
      asset: 'assets/images/onboarding_2.svg',
      title: 'Delivery anywhere',
      subtitle:
          'Send packages across town with transparent pricing and tracking.',
    ),
    _Slide(
      asset: 'assets/images/delivery_bike.svg',
      title: 'Fast and reliable',
      subtitle: 'Choose a vehicle and we’ll match the nearest rider for you.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: greyLight1.withOpacity(0.7)));
    return Scaffold(
        backgroundColor: pureWhite,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentIndex = i),
                  itemCount: _slides.length,
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.34,
                          child: Center(
                            child: SvgPicture.asset(
                              slide.asset,
                              // Constrain both width and height so visuals are consistent across SVGs
                              width: MediaQuery.of(context).size.width * 0.72,
                              height: MediaQuery.of(context).size.height * 0.28,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.04),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(slide.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  color: pureBlack,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(slide.subtitle,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  color: const Color(0xFF6B6B6B),
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400)),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _currentIndex ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color:
                          i == _currentIndex ? secondaryColor : greyBorderColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.055,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: CustomButton(
                    buttonLabel: _currentIndex == _slides.length - 1
                        ? 'Get started'
                        : 'Next',
                    backGroundColor: buttonColor,
                    borderRadius: 28,
                    onTap: () {
                      if (_currentIndex < _slides.length - 1) {
                        _pageController.animateToPage(
                          _currentIndex + 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      } else {
                        navigationService.navigatePushNamedAndRemoveUntilTo(
                            loginScreenRoute, null);
                      }
                    },
                    buttonWidth: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        )));
  }
}

class _Slide {
  final String asset;
  final String title;
  final String subtitle;
  const _Slide(
      {required this.asset, required this.title, required this.subtitle});
}
