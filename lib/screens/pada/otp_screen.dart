import 'dart:async';
import 'dart:convert';
import 'package:deliverapp/core/errors/exceptions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deliverapp/screens/pada/registration_page.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../core/colors.dart';
import '../../core/models/mobile_sign_in_response.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/services/firebase_options.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/storage_service.dart';
import '../../widgets/button.dart';
import '../../widgets/loading_indicator.dart';
import 'bottom_navigation_page.dart';
import 'login_page.dart';

class OtpScreen extends StatefulWidget {
  final String mobNumber;
  const OtpScreen({super.key, required this.mobNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  bool isFilled = false;
  bool buttonLoading = false;
  TextEditingController otpController = TextEditingController();
  String? otp = '';
  int _resendSeconds = 30;
  Timer? _resendTimer;
  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _resendSeconds = 30;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_resendSeconds <= 1) {
        t.cancel();
        setState(() {
          _resendSeconds = 0;
        });
      } else {
        setState(() {
          _resendSeconds -= 1;
        });
      }
    });
  }

  Future getOtp() async {
    String? token; // fetch asynchronously later; don't block UI
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      // Start FCM token fetch in background to avoid blocking OTP UI
      () async {
        try {
          await Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform);
          final t = await FirebaseMessaging.instance.getToken();
          token = t;
        } catch (_) {
          token = '';
        }
      }();

      otpController.clear();
      authProvider.otpReceived = '';
      var response = await authProvider.getOtp(phoneNumber: widget.mobNumber);
      debugPrint("ress:: $response");
      // Defensive parsing to avoid model issues
      final success = response is Map && response['success'] == true;
      if (success) {
        final data = (response['data'] as Map?) ?? {};
        final received = (data['verificationCode']?.toString() ?? '');
        final phone = (data['phoneNumber']?.toString() ?? '');
        authProvider.setPhoneNumber(phone: phone);
        authProvider.setOtp(otp: received);
        if (received.isNotEmpty) {
          otp = received;
          isFilled = true;
          setState(() {});
        } else if (authProvider.otpReceived != '') {
          otp = authProvider.otpReceived;
          isFilled = true;
          setState(() {});
        } else {
          notificationService.showToast(context, 'Failed to get OTP',
              type: NotificationType.error);
        }
        // Set device token last (when background fetch finishes). Provide fallback for simulators.
        authProvider.setDeviceToken(
            deviceTokenFromResponse: (token == null || token!.trim().isEmpty)
                ? 'simulator-${DateTime.now().millisecondsSinceEpoch}'
                : token!);
      } else {
        final msg = (response is Map)
            ? (response['message']?.toString() ?? 'Failed')
            : 'Failed';
        notificationService.showToast(context, msg,
            type: NotificationType.error);
      }
    } catch (e) {
      // notificationService.showToast(context, e.toString(), type: NotificationType.error);
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

  Future mobileSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      setState(() {
        buttonLoading = true;
      });
      LoadingOverlay.of(context).show();
      // Set phone number in provider before calling mobileSignIn
      authProvider.setPhoneNumber(phone: widget.mobNumber);
      var response = await authProvider.mobileSignIn(
          otp: otpController.text.trim().toString());
      LoadingOverlay.of(context).hide();
      debugPrint("resssss::::${response.toString()}");
      
      // Ensure response is a Map before parsing
      Map<String, dynamic> responseMap;
      if (response is Map<String, dynamic>) {
        responseMap = response;
      } else if (response is Map) {
        responseMap = Map<String, dynamic>.from(response);
      } else if (response is String) {
        responseMap = jsonDecode(response) as Map<String, dynamic>;
      } else {
        debugPrint("Invalid response type: ${response.runtimeType}");
        debugPrint("Response value: $response");
        throw Exception('Invalid response format: ${response.runtimeType}');
      }
      
      debugPrint("Response Map: $responseMap");
      
      MobileSignInResponse mobileSignInResponse;
      try {
        mobileSignInResponse = MobileSignInResponse.fromJson(responseMap);
      } catch (parseError) {
        debugPrint("Error parsing response: $parseError");
        debugPrint("Response data: $responseMap");
        setState(() {
          buttonLoading = false;
        });
        if (mounted) {
          LoadingOverlay.of(context).hide();
          notificationService.showToast(
            context,
            'Failed to parse response. Please try again.',
            type: NotificationType.error,
          );
        }
        return;
      }
      
      if (mobileSignInResponse.success ?? false) {
        storageService
            .setAuthToken(mobileSignInResponse.data?.accessToken ?? '');
        storageService
            .setRefreshToken(mobileSignInResponse.data?.refreshToken ?? '');
        apiService
            .setAuthorisation(mobileSignInResponse.data?.accessToken ?? '');
        setState(() {
          buttonLoading = false;
        });
        if (mobileSignInResponse.data?.user?.firstName == null || 
            mobileSignInResponse.data!.user!.firstName == '') {
          if (mounted) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RegistrationPage(
                          mobNumber: widget.mobNumber,
                        )));
          }
        } else {
          if (mounted) {
            storageService.setStartLocString("");
            storageService.setEndLocString("");

            await Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const BottomNavPage()),
              (Route<dynamic> route) => false,
            );
          }
        }
      } else {
        setState(() {
          buttonLoading = false;
        });
        if (mounted) {
          LoadingOverlay.of(context).hide();
          notificationService.showToast(
            context,
            mobileSignInResponse.message ?? 'Verification failed',
            type: NotificationType.error,
          );
        }
      }
    } catch (e) {
      setState(() {
        buttonLoading = false;
      });
      if (mounted) {
        LoadingOverlay.of(context).hide();
        if (e is ClientException) {
          debugPrint("errorr::::${e.message.toString()}");
          notificationService.showToast(context, e.message.toString(),
              type: NotificationType.error);
        } else if (e is ServerException) {
          debugPrint("errorr::::${e.message.toString()}");
          notificationService.showToast(context, e.message.toString(),
              type: NotificationType.error);
        } else if (e is HttpException) {
          debugPrint("errorr::::${e.message.toString()}");
          notificationService.showToast(context, e.message.toString(),
              type: NotificationType.error);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: pureWhite,
      body: SafeArea(
          child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor,
                        const Color(0xFF003D9E),
                        secondaryColor,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles in background
                      Positioned(
                        top: -80,
                        right: -60,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pureWhite.withOpacity(0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: -40,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pureWhite.withOpacity(0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -50,
                        right: 20,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: pureWhite.withOpacity(0.05),
                          ),
                        ),
                      ),
                      // Main content
                      Center(
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 800),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.8 + (0.2 * value),
                              child: Opacity(
                                opacity: value,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Logo with glow effect
                                    Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: pureWhite.withOpacity(0.15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: pureWhite.withOpacity(0.2),
                                            blurRadius: 30,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.18,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.08,
                                        child: SvgPicture.asset(
                                          'assets/images/pada_logo.svg',
                                          fit: BoxFit.contain,
                                          colorFilter: ColorFilter.mode(
                                            pureWhite,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    // App name with better typography
                                    Text(
                                      "Pada Delivery",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.inter(
                                        color: pureWhite,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.5,
                                        shadows: [
                                          Shadow(
                                            color:
                                                Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset('assets/images/india_flag.svg',
                                  width: 24, height: 16),
                              const SizedBox(width: 8),
                              Text(widget.mobNumber.toString(),
                                  style: GoogleFonts.inter(
                                      color: pureBlack,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginPage()),
                                    (Route<dynamic> route) => false,
                                  );
                                },
                                child: Text('CHANGE',
                                    style: GoogleFonts.inter(
                                        color: changeOTPColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                              'One Time Password (OTP) has been sent to this number',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400)),
                          const SizedBox(height: 20),
                          Center(
                            child: PinCodeTextField(
                              appContext: context,
                              pastedTextStyle: GoogleFonts.poppins(
                                  color: pureBlack,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400),
                              textStyle: GoogleFonts.poppins(
                                  color: pureBlack,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                              backgroundColor: pureWhite,
                              length: otp != null && otp!.isNotEmpty
                                  ? otp!.length
                                  : 5,
                              obscureText: false,
                              blinkWhenObscuring: true,
                              animationType: AnimationType.fade,
                              validator: (v) {
                                if (v == null || v.length < 5) {
                                  return '';
                                }
                                return null;
                              },
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(10),
                                fieldHeight: 54,
                                fieldWidth: 54,
                                activeFillColor: pureWhite,
                                selectedColor: buttonColor,
                                selectedFillColor: pureWhite,
                                inactiveColor: greyBorderColor,
                                disabledColor: greyBorderColor,
                                activeColor: buttonColor,
                                inactiveFillColor: pureWhite,
                                errorBorderColor: Colors.red,
                              ),
                              cursorColor: pureBlack,
                              animationDuration:
                                  const Duration(milliseconds: 250),
                              enableActiveFill: true,
                              controller: otpController,
                              keyboardType: TextInputType.number,
                              boxShadows: const [
                                BoxShadow(
                                    offset: Offset(0, 0),
                                    color: greyColor,
                                    blurRadius: 0.5),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  // Check if 5 digits are entered (since otp might be empty string)
                                  isFilled = value.length == 5;
                                });
                              },
                              beforeTextPaste: (text) => true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.055,
                            child: CustomButton(
                              loading: buttonLoading,
                              buttonLabel: 'Verify',
                              buttonWidth: double.infinity,
                              backGroundColor: isFilled
                                  ? buttonColor
                                  : greyBorderColor.withOpacity(0.6),
                              onTap: isFilled
                                  ? () async {
                                      await mobileSignIn();
                                    }
                                  : () {},
                              borderRadius: 28,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: InkWell(
                              onTap: _resendSeconds == 0
                                  ? () async {
                                      await getOtp();
                                      _startResendTimer();
                                    }
                                  : null,
                              child: Text(
                                _resendSeconds == 0
                                    ? 'Resend OTP'
                                    : 'Resend OTP in 00:${_resendSeconds.toString().padLeft(2, '0')}',
                                style: GoogleFonts.inter(
                                    color: _resendSeconds == 0
                                        ? resendOTPColor
                                        : Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
