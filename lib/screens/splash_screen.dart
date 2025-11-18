
import 'package:deliverapp/screens/pada/registration_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deliverapp/screens/pada/bottom_navigation_page.dart';
import 'package:deliverapp/screens/pada/onboarding_pada_1.dart';
import 'package:provider/provider.dart';

import '../core/colors.dart';
import '../core/providers/auth_provider.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _loadingAnimation;

  DateTime? _splashStartTime;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _splashStartTime = DateTime.now();

    // Logo Animation Controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Text Animation Controller
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Loading Animation Controller
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Logo Animations
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeIn,
      ),
    );

    // Text Animations
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    _textSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    // Loading Animation
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() {
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _textController.forward();
      }
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _loadingController.repeat();
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() async {
    _checkFirstLaunch();
    super.didChangeDependencies();
  }

  Future<void> _checkFirstLaunch() async {
    var isFirstTime = await storageService.getIsFirstTime() ?? "true";

    if (isFirstTime == 'true') {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.clearLoginCredentials();
      storageService.setIsFirstTime("false");
    }
    
    // Start auth check - it will ensure minimum 3 seconds before navigating
    await authCheck();
  }

  Future<void> _ensureMinimumDuration() async {
    final elapsed = DateTime.now().difference(_splashStartTime!);
    final remainingTime = const Duration(seconds: 3) - elapsed;
    
    if (remainingTime > Duration.zero) {
      await Future.delayed(remainingTime);
    }
  }

  authCheck() async {
    if (_hasNavigated || !mounted) return;
    
    // Ensure minimum 3 seconds before any navigation
    await _ensureMinimumDuration();
    
    if (_hasNavigated || !mounted) return;
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool authStatus = await authProvider.checkAuthState();
      var userDetails;

      if (authStatus) {
        // if (false) {
        storageService.setStartLocString("");
        storageService.setEndLocString("");
        if (mounted) {
          await ApiService().getUserProfile().then((value) {
            if (value['success']) {
              userDetails = value['data'];
              debugPrint("prof::===>> $value");
            }
          });
          
          if (!mounted || _hasNavigated) return;
          
          if (userDetails['firstName'] != null &&
              userDetails['firstName'] != '') {
            _hasNavigated = true;
            await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const BottomNavPage()),
              (Route<dynamic> route) => false,
            );
          } else {
            _hasNavigated = true;
            await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => RegistrationPage(
                      mobNumber: userDetails['phoneNumber'].toString())),
              (Route<dynamic> route) => false,
            );
          }
        }
      } else {
        if (mounted && !_hasNavigated) {
          _hasNavigated = true;
          await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint("error auth:: $e");
      // Even on error, ensure minimum splash duration
      if (!_hasNavigated && mounted) {
        await _ensureMinimumDuration();
        
        if (mounted && !_hasNavigated) {
          _hasNavigated = true;
          await Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const OnBoardingScreen()),
            (Route<dynamic> route) => false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: primaryColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: primaryColor,
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor,
              const Color(0xFF003D9E),
              secondaryColor,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // Logo with Animation (matching login screen style)
                AnimatedBuilder(
                  animation: _logoController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Opacity(
                        opacity: _logoOpacityAnimation.value,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.18,
                          height: MediaQuery.of(context).size.height * 0.08,
                          child: SvgPicture.asset(
                            'assets/images/pada_logo.svg',
                            fit: BoxFit.contain,
                            colorFilter: const ColorFilter.mode(
                              pureWhite,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                // App Name with Animation
                AnimatedBuilder(
                  animation: _textController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _textSlideAnimation.value),
                      child: Opacity(
                        opacity: _textFadeAnimation.value,
                        child: Column(
                          children: [
                            Text(
                              "Pada Delivery",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                color: pureWhite,
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(flex: 3),
                // Loading Indicator
                AnimatedBuilder(
                  animation: _loadingController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _loadingAnimation.value < 0.5
                          ? _loadingAnimation.value * 2
                          : (1.0 - _loadingAnimation.value) * 2,
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            pureWhite.withValues(alpha: 0.8),
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
