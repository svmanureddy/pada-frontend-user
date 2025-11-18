import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/colors.dart';
import '../../core/utils.dart';

class SupportPage extends StatefulWidget {
  // final dynamic vehicleList;
  const SupportPage({
    super.key,
  });

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,
      body: Column(
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
                  // Main content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                          "Support",
                          style: GoogleFonts.inter(
                            color: pureWhite,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 40), // Balance for back button
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Content Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Heading
                  Text(
                    "Get in touch with us",
                    style: GoogleFonts.inter(
                      color: pureBlack,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We're here to help! Contact us via phone or email.",
                    style: GoogleFonts.inter(
                      color: greyText,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Phone Contact Card
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: InkWell(
                      onTap: () {
                        launchURL(Uri.parse('tel:+918660626465'));
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: pureWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: greyBorderColor.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: buttonColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/images/call.svg',
                                  fit: BoxFit.contain,
                                  height: 24,
                                  width: 24,
                                  colorFilter: ColorFilter.mode(
                                    buttonColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Phone",
                                    style: GoogleFonts.inter(
                                      color: greyText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "+91 86606 26465",
                                    style: GoogleFonts.inter(
                                      color: pureBlack,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: secondaryColor,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Email Contact Card
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 700),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: child,
                        ),
                      );
                    },
                    child: InkWell(
                      onTap: () async {
                        final Uri emailUri = Uri.parse(
                          'mailto:gm.pada@snowcodestechbiz.com',
                        );
                        try {
                          // Directly launch the email URI - this will open the default email app
                          // or show a picker if multiple email apps are installed
                          final bool launched = await launchUrl(
                            emailUri,
                            mode: LaunchMode.externalApplication,
                          );
                          if (!launched && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Unable to open email app. Please install an email app or contact us at gm.pada@snowcodestechbiz.com',
                                ),
                                duration: Duration(seconds: 3),
                              ),
                            );
                          }
                        } catch (e) {
                          // Show error message to user
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Unable to open email app. Please contact us at gm.pada@snowcodestechbiz.com',
                                ),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: pureWhite,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: greyBorderColor.withOpacity(0.3),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: buttonColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/images/mail.svg',
                                  fit: BoxFit.contain,
                                  height: 24,
                                  width: 24,
                                  colorFilter: ColorFilter.mode(
                                    buttonColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Email",
                                    style: GoogleFonts.inter(
                                      color: greyText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "gm.pada@snowcodestechbiz.com",
                                    style: GoogleFonts.inter(
                                      color: pureBlack,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: secondaryColor,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
