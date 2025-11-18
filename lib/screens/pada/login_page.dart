import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/colors.dart';
import '../../core/errors/exceptions.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/api_service.dart';
import '../../core/utils.dart';
import '../../widgets/button.dart';
import 'otp_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController mobNumberController = TextEditingController();
  bool isFilled = false;
  bool submitting = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: pureWhite,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Header
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      Color(0xFF003D9E),
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
                                      width: MediaQuery.of(context).size.width *
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
                                          color: Colors.black.withOpacity(0.2),
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
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: Column(
                  children: [
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: SvgPicture.asset(
                                        'assets/images/hand.svg',
                                        fit: BoxFit.contain)),
                                const SizedBox(width: 8),
                                Text("Welcome",
                                    style: GoogleFonts.inter(
                                        color: const Color(0xFF737373),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text("Enter mobile number",
                                style: GoogleFonts.inter(
                                    color: const Color(0xFF8A8A8A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400)),
                            const SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: greyBorderColor),
                                  color: Colors.white),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/india_flag.svg',
                                    width: 24,
                                    height: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text('+91',
                                      style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: pureBlack)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: mobNumberController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 10,
                                      decoration: InputDecoration(
                                        hintText: 'Mobile Number',
                                        counterText: '',
                                        border: InputBorder.none,
                                      ),
                                      style: GoogleFonts.inter(
                                          color: pureBlack, fontSize: 16),
                                      readOnly: submitting,
                                      onChanged: (str) {
                                        isFilled = str.length == 10;
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.055,
                      child: CustomButton(
                        buttonLabel: 'Continue',
                        buttonWidth: double.infinity,
                        backGroundColor: isFilled
                            ? buttonColor
                            : greyBorderColor.withOpacity(0.6),
                        loading: submitting,
                        onTap: () async {
                          if (!isFilled || submitting) {
                            if (!isFilled) {
                              notificationService.showToast(
                                  context, "Enter valid mobile number",
                                  type: NotificationType.error);
                            }
                            return;
                          }
                          if (mounted) {
                            setState(() {
                              submitting = true;
                            });
                          }
                          try {
                            final resp = await ApiService()
                                .getOtp(mobileNumber: mobNumberController.text);

                            if (!mounted) return;

                            // Handle response - check if it's a Map or needs parsing
                            dynamic responseData = resp;
                            if (resp is String) {
                              try {
                                responseData = jsonDecode(resp);
                              } catch (e) {
                                debugPrint("Failed to parse response: $e");
                              }
                            }

                            // Check success condition - handle both bool and string "true"
                            bool isSuccess = false;
                            if (responseData != null && responseData is Map) {
                              final successValue = responseData['success'];
                              isSuccess = successValue == true ||
                                  successValue == 'true' ||
                                  successValue == 1;
                            }

                            // Hide loader before navigation
                            if (mounted) {
                              setState(() {
                                submitting = false;
                              });
                            }

                            if (isSuccess) {
                              // Navigate immediately after hiding loader
                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OtpScreen(
                                      mobNumber: mobNumberController.text,
                                    ),
                                  ),
                                );
                              }
                            } else {
                              final message = (responseData != null &&
                                      responseData is Map &&
                                      responseData['message'] != null)
                                  ? responseData['message'].toString()
                                  : 'Failed to send OTP';
                              notificationService.showToast(context, message,
                                  type: NotificationType.error);
                            }
                          } catch (e) {
                            if (!mounted) return;

                            setState(() {
                              submitting = false;
                            });

                            String errorMessage = 'Something went wrong';
                            if (e is ClientException) {
                              errorMessage =
                                  e.message ?? 'Something went wrong';
                            } else if (e is ServerException) {
                              errorMessage =
                                  e.message ?? 'Something went wrong';
                            } else if (e is HttpException) {
                              errorMessage =
                                  e.message ?? 'Something went wrong';
                            }

                            notificationService.showToast(context, errorMessage,
                                type: NotificationType.error);
                          }
                        },
                        borderRadius: 28,
                      ),
                    ),

                    /// ============== Social signin button start ==============
                    ///
                    /*  SizedBox(height: MediaQuery.of(context).size.height / 50),
                    Text("OR",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            color: const Color(0xFF737373),
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: MediaQuery.of(context).size.height / 50),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: SocialSignInButton(
                                  buttonImage: 'assets/images/google.svg',
                                  onTap: () async {
                                    // await signInWithGoogle().then((value) {
                                    //   ApiService()
                                    //       .socialSignIn(
                                    //           socialId:
                                    //               value.credential!.providerId,
                                    //           deviceToken: "deviceToken",
                                    //           email: value.user!.email,
                                    //           displayName:
                                    //               value.user!.displayName)
                                    //       .then((resp) async {
                                    //     if (resp!['success'] == true) {
                                    //       storageService
                                    //           .setActiveConnectionStatus(true);
                                    //       storageService.setAuthToken(
                                    //           resp!['data']['accessToken'] ??
                                    //               '');
                                    //       storageService.setRefreshToken(
                                    //           resp!['data']['refreshToken'] ??
                                    //               '');
                                    //       apiService.setAuthorisation(
                                    //           resp!['data']['accessToken'] ??
                                    //               '');
                                    //
                                    //       await Navigator.pushAndRemoveUntil(
                                    //         context,
                                    //         MaterialPageRoute(
                                    //             builder: (context) =>
                                    //             const DashboardPage()),
                                    //             (Route<dynamic> route) => false,
                                    //       );
                                    //       setState(() {});
                                    //     } else {
                                    //       notificationService.showToast(
                                    //           context, resp['message'],
                                    //           type: NotificationType.error);
                                    //     }
                                    //   });
                                    // });
                                  },
                                  borderColor: pureBlack,
                                  width: 30,
                                  height: 30,
                                  iconWidth: 22,
                                  iconHeight: 22),
                            ),
                            // Padding(
                            //   padding:
                            //       const EdgeInsets.symmetric(horizontal: 5.0),
                            //   child: SocialSignInButton(
                            //       buttonImage: 'assets/images/facebook.svg',
                            //       onTap: () async {
                            //         // await signInWithFacebook();
                            //       },
                            //       borderColor: pureBlack,
                            //       width: 30,
                            //       height: 30,
                            //       iconWidth: 22,
                            //       iconHeight: 22),
                            // ),
                          ]),
                    ),*/

                    /// ============== Social signin button end ==============
                    ///
                    SizedBox(height: MediaQuery.of(context).size.height / 50),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      width: MediaQuery.of(context).size.width,
                      child: Text.rich(
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 3,
                        TextSpan(
                          text: 'By clicking on log in, you agree to the ',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.black),
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  launchURL(Uri.parse(
                                      'https://snowcodestechbiz.com/portfolio/')); // Replace with your link URL
                                },
                            ),
                            TextSpan(
                              text: ' and ',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: 'privacy policy.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  launchURL(Uri.parse(
                                      'https://snowcodestechbiz.com/portfolio/')); // Replace with your link URL
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Future<UserCredential> signInWithGoogle() async {
  //   // Trigger the authentication flow
  //   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //
  //   // Obtain the auth details from the request
  //   final GoogleSignInAuthentication? googleAuth =
  //       await googleUser?.authentication;
  //
  //   // Create a new credential
  //   final credential = GoogleAuthProvider.credential(
  //     accessToken: googleAuth?.accessToken,
  //     idToken: googleAuth?.idToken,
  //   );
  //
  //   // Once signed in, return the UserCredential
  //   return await FirebaseAuth.instance.signInWithCredential(credential);
  // }

  // Future<UserCredential> signInWithFacebook() async {
  //   // Trigger the sign-in flow
  //   final LoginResult loginResult = await FacebookAuth.instance.login();
  //
  //   // Create a credential from the access token
  //   final OAuthCredential facebookAuthCredential =
  //       FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
  //
  //   // Once signed in, return the UserCredential
  //   return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  // }
}
