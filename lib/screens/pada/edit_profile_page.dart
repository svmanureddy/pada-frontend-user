import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/notification_service.dart';
import '../../widgets/loading_indicator.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  dynamic userDetails;
  bool isLoaded = false;

  bool isFilled = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  loadData() async {
    await ApiService().getUserProfile().then((value) {
      if (value['success']) {
        userDetails = value['data'];
        debugPrint("prof:: $value");
        fNameController.text = userDetails['firstName'];
        lNameController.text = userDetails['lastName'];
        mailController.text = userDetails['email'];
      }
    });
    isLoaded = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: pureWhite,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: !isLoaded
            ? const Center(
                child: CircularProgressIndicator(
                  color: secondaryColor,
                ),
              )
            : Column(
                children: [
                  // Header Section
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.only(top: 20, bottom: 20),
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
                    child: SafeArea(
                      bottom: false,
                      child: Stack(
                        children: [
                          // Decorative circles in background
                          Positioned(
                            top: -60,
                            right: -50,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: pureWhite.withOpacity(0.08),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 30,
                            left: -30,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: pureWhite.withOpacity(0.06),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -40,
                            right: 20,
                            child: Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: pureWhite.withOpacity(0.05),
                              ),
                            ),
                          ),
                          // Main content
                          Column(
                            children: [
                              // Back button and title row
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: pureWhite.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_back_ios_rounded,
                                          color: pureWhite,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "Profile",
                                      style: GoogleFonts.inter(
                                        color: pureWhite,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const Spacer(),
                                    const SizedBox(
                                        width: 40), // Balance for back button
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Logo and branding with animation
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 800),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: 0.8 + (0.2 * value),
                                    child: Opacity(
                                      opacity: value,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Logo with glow effect
                                          Container(
                                            padding: const EdgeInsets.all(16),
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
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.16,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.07,
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
                                          const SizedBox(height: 16),
                                          // App name with better typography
                                          Text(
                                            "Pada Delivery",
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.inter(
                                              color: pureWhite,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.3,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
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
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Content Section
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 600),
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
                        child: Card(
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: pureWhite,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.all(24.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Form Title
                                  Text(
                                    "Edit Profile",
                                    style: GoogleFonts.inter(
                                      color: pureBlack,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // First Name and Last Name Row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TweenAnimationBuilder<double>(
                                          duration:
                                              const Duration(milliseconds: 400),
                                          tween: Tween(begin: 0.0, end: 1.0),
                                          curve: Curves.easeOut,
                                          builder: (context, value, child) {
                                            return Transform.translate(
                                              offset:
                                                  Offset(0, 15 * (1 - value)),
                                              child: Opacity(
                                                opacity: value,
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: TextFormField(
                                            controller: fNameController,
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            validator: (str) {
                                              if (str!.isEmpty) {
                                                return 'This field must not be empty';
                                              }
                                              return null;
                                            },
                                            style: GoogleFonts.inter(
                                              color: pureBlack,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            decoration: InputDecoration(
                                              labelText: "First name",
                                              labelStyle: GoogleFonts.inter(
                                                color: addressTextColor,
                                                fontSize: 14,
                                              ),
                                              prefixIcon: Icon(
                                                Icons.person_outline,
                                                color: secondaryColor,
                                              ),
                                              errorStyle: const TextStyle(
                                                fontSize: 12,
                                              ),
                                              filled: true,
                                              fillColor: greyBorderColor
                                                  .withOpacity(0.05),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                  color: greyBorderColor,
                                                  width: 1,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                  color: greyBorderColor,
                                                  width: 1,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                  color: secondaryColor,
                                                  width: 2,
                                                ),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: const BorderSide(
                                                  color: Colors.red,
                                                  width: 1,
                                                ),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TweenAnimationBuilder<double>(
                                          duration:
                                              const Duration(milliseconds: 500),
                                          tween: Tween(begin: 0.0, end: 1.0),
                                          curve: Curves.easeOut,
                                          builder: (context, value, child) {
                                            return Transform.translate(
                                              offset:
                                                  Offset(0, 15 * (1 - value)),
                                              child: Opacity(
                                                opacity: value,
                                                child: child,
                                              ),
                                            );
                                          },
                                          child: TextFormField(
                                            controller: lNameController,
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            validator: (str) {
                                              if (str!.isEmpty) {
                                                return 'This field must not be empty';
                                              }
                                              return null;
                                            },
                                            style: GoogleFonts.inter(
                                              color: pureBlack,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            decoration: InputDecoration(
                                              labelText: "Last name",
                                              labelStyle: GoogleFonts.inter(
                                                color: addressTextColor,
                                                fontSize: 14,
                                              ),
                                              prefixIcon: Icon(
                                                Icons.person_outline,
                                                color: secondaryColor,
                                              ),
                                              errorStyle: const TextStyle(
                                                fontSize: 12,
                                              ),
                                              filled: true,
                                              fillColor: greyBorderColor
                                                  .withOpacity(0.05),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                  color: greyBorderColor,
                                                  width: 1,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                  color: greyBorderColor,
                                                  width: 1,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                  color: secondaryColor,
                                                  width: 2,
                                                ),
                                              ),
                                              errorBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: const BorderSide(
                                                  color: Colors.red,
                                                  width: 1,
                                                ),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  // Email Field
                                  TweenAnimationBuilder<double>(
                                    duration: const Duration(milliseconds: 600),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    curve: Curves.easeOut,
                                    builder: (context, value, child) {
                                      return Transform.translate(
                                        offset: Offset(0, 15 * (1 - value)),
                                        child: Opacity(
                                          opacity: value,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: TextFormField(
                                      controller: mailController,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      validator: (str) {
                                        if (str!.isEmpty) {
                                          return 'This field must not be empty';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.emailAddress,
                                      style: GoogleFonts.inter(
                                        color: pureBlack,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
                                        labelText: "Email id",
                                        labelStyle: GoogleFonts.inter(
                                          color: addressTextColor,
                                          fontSize: 14,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: secondaryColor,
                                        ),
                                        errorStyle: const TextStyle(
                                          fontSize: 12,
                                        ),
                                        filled: true,
                                        fillColor:
                                            greyBorderColor.withOpacity(0.05),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                            color: greyBorderColor,
                                            width: 1,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                            color: greyBorderColor,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide(
                                            color: secondaryColor,
                                            width: 2,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: const BorderSide(
                                            color: Colors.red,
                                            width: 1,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Update Button
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          if (isEmail(mailController.text)) {
                                            LoadingOverlay.of(context).show();
                                            await ApiService()
                                                .updateProfile(
                                              firstName: fNameController.text,
                                              lastName: lNameController.text,
                                              email: mailController.text,
                                            )
                                                .then((value) async {
                                              LoadingOverlay.of(context).hide();
                                              if (value['success']) {
                                                notificationService.showToast(
                                                  context,
                                                  value['message'],
                                                  type:
                                                      NotificationType.success,
                                                );
                                                Navigator.pop(context);
                                              } else {
                                                notificationService.showToast(
                                                  context,
                                                  value['message'],
                                                  type: NotificationType.error,
                                                );
                                              }
                                            });
                                          } else {
                                            notificationService.showToast(
                                              context,
                                              "Enter valid email",
                                              type: NotificationType.error,
                                            );
                                          }
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: buttonColor,
                                        foregroundColor: pureWhite,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: Text(
                                        'Update',
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
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
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  bool isEmail(String mail) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(p);
    return regExp.hasMatch(mail);
  }
}
