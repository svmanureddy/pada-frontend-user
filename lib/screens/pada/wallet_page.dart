import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deliverapp/core/constants.dart';
import 'package:lottie/lottie.dart';
import '../../core/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/errors/exceptions.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../widgets/loading_indicator.dart';

class WalletPage extends StatefulWidget {
  // final dynamic vehicleList;
  const WalletPage({
    super.key,
  });

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  num walletBal = 0.0;
  final TextEditingController _controller = TextEditingController();
  String amount1 = "100";
  String amount2 = "200";
  String amount3 = "500";
  bool isWeb = false;
  bool addSuccess = false;
  dynamic userDetails;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void _showAddMoneySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: pureWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: greyBorderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Add Money",
                style: GoogleFonts.inter(
                  color: pureBlack,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              // Amount Input
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                maxLength: 10,
                textAlign: TextAlign.start,
                style: GoogleFonts.inter(
                  color: pureBlack,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintStyle: GoogleFonts.inter(
                    color: greyText,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  counterText: '',
                  hintText: "Enter amount",
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      rupeeSymbol,
                      style: GoogleFonts.inter(
                        color: pureBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: greyBorderColor, width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: greyBorderColor, width: 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: secondaryColor, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                onChanged: (str) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              // Quick amount buttons
              Text(
                "Quick Amount",
                style: GoogleFonts.inter(
                  color: greyText,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _controller.text = amount1;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: _controller.text == amount1
                              ? secondaryColor.withOpacity(0.1)
                              : greyBorderColor.withOpacity(0.1),
                          border: Border.all(
                            color: _controller.text == amount1
                                ? secondaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "+ $rupeeSymbol$amount1",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _controller.text == amount1
                                  ? secondaryColor
                                  : pureBlack,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _controller.text = amount2;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: _controller.text == amount2
                              ? secondaryColor.withOpacity(0.1)
                              : greyBorderColor.withOpacity(0.1),
                          border: Border.all(
                            color: _controller.text == amount2
                                ? secondaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "+ $rupeeSymbol$amount2",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _controller.text == amount2
                                  ? secondaryColor
                                  : pureBlack,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _controller.text = amount3;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: _controller.text == amount3
                              ? secondaryColor.withOpacity(0.1)
                              : greyBorderColor.withOpacity(0.1),
                          border: Border.all(
                            color: _controller.text == amount3
                                ? secondaryColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "+ $rupeeSymbol$amount3",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _controller.text == amount3
                                  ? secondaryColor
                                  : pureBlack,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Proceed Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_controller.text == "" || _controller.text.isEmpty) {
                      if (mounted) {
                        notificationService.showToast(
                          context,
                          "Please enter amount to process",
                          type: NotificationType.error,
                        );
                      }
                    } else {
                      if (context.mounted) {
                        Navigator.pop(context);
                        LoadingOverlay.of(context).show();
                        try {
                          final value = await ApiService()
                              .postPaymentApi(amount: int.parse(_controller.text));
                          debugPrint("sksksk:: $value");
                          if (value['success'] == true) {
                            if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WalletWebView(
                                webUrl: value['data']['liink'],
                              ),
                            ),
                          ).then((onValue) {
                                if (context.mounted) {
                            LoadingOverlay.of(context).hide();
                            addSuccess = true;
                            setState(() {});
                            Future.delayed(const Duration(seconds: 2), () {
                              if (mounted) {
                                setState(() {
                                  addSuccess = false;
                                });
                              }
                            });
                                }
                          });
                            }
                          } else {
                            // Handle API response with success: false
                            if (context.mounted) {
                              LoadingOverlay.of(context).hide();
                              notificationService.showToast(
                                context,
                                value['message'] ?? "Something went wrong",
                                type: NotificationType.error,
                              );
                            }
                          }
                        } catch (e) {
                          debugPrint("error:::: $e");
                          if (context.mounted) {
                            LoadingOverlay.of(context).hide();
                            if (e is ClientException) {
                              notificationService.showToast(
                                context,
                                e.message,
                                type: NotificationType.error,
                              );
                            } else if (e is ServerException) {
                              notificationService.showToast(
                                context,
                                e.message,
                                type: NotificationType.error,
                              );
                            } else if (e is HttpException) {
                              notificationService.showToast(
                                context,
                                e.message,
                                type: NotificationType.error,
                              );
                            } else {
                              notificationService.showToast(
                                context,
                                "Something went wrong. Please try again.",
                                type: NotificationType.error,
                              );
                            }
                          }
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: pureWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    "Proceed",
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: pureWhite,
      body: FutureBuilder(
        future: ApiService().getUserProfile(),
        builder: (context, snapShotData) {
          if (snapShotData.hasData) {
            if (snapShotData.data['success']) {
              userDetails = snapShotData.data['data'];
              walletBal = userDetails['wallet'];
            }
            return Stack(
              children: [
                Column(
                  children: [
                    // Header Section
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(top: 20, bottom: 16),
                      decoration: const BoxDecoration(
                        color: primaryColor,
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Center(
                          child: Text(
                            "Wallet",
                            style: GoogleFonts.inter(
                              color: pureWhite,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Content Section
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: TweenAnimationBuilder<double>(
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
                          child: Card(
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    secondaryColor.withOpacity(0.1),
                                    secondaryColor.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color:
                                              secondaryColor.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.account_balance_wallet,
                                          color: secondaryColor,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Wallet Balance",
                                              style: GoogleFonts.inter(
                                                color: addressTextColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "$rupeeSymbol $walletBal",
                                              style: GoogleFonts.inter(
                                                color: pureBlack,
                                                fontSize: 32,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _showAddMoneySheet(context),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: buttonColor,
                                        foregroundColor: pureWhite,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_circle_outline,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Add Money",
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
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
                  ],
                ),
                // Success animation overlay
                if (addSuccess)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: Lottie.asset(
                        'assets/images/succesGif.json',
                        width: 200,
                        height: 200,
                        repeat: false,
                      ),
                    ),
                  ),
              ],
            );
          } else {
            return Scaffold(
              backgroundColor: pureWhite,
              body: Center(
                child: CircularProgressIndicator(
                  color: secondaryColor,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class WalletWebView extends StatefulWidget {
  const WalletWebView({super.key, required this.webUrl});
  final String webUrl;

  @override
  State<WalletWebView> createState() => _WalletWebViewState();
}

class _WalletWebViewState extends State<WalletWebView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: InAppWebView(
            onLoadStart: (con, uri) {
              LoadingOverlay.of(context).show();
            },
            onLoadStop: (con, uri) {
              LoadingOverlay.of(context).hide();
            },
            initialUrlRequest: URLRequest(url: WebUri(widget.webUrl)),
          ),
        ));
  }
}
