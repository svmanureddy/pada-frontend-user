import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/colors.dart';
import '../../widgets/loading_indicator.dart';

class TermsAndConditionsPage extends StatefulWidget {
  // final dynamic vehicleList;
  const TermsAndConditionsPage({
    super.key,
  });

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
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
                          "Terms and Conditions",
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
            child: Container(
              margin: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 16),
              decoration: BoxDecoration(
                color: pureWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: InAppWebView(
                  onLoadStart: (con, uri) {
                    LoadingOverlay.of(context).show();
                  },
                  onLoadStop: (con, uri) {
                    LoadingOverlay.of(context).hide();
                  },
                  initialUrlRequest: URLRequest(
                    url: WebUri("https://snowcodestechbiz.com/portfolio/"),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
