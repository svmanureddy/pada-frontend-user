import 'dart:ui';

import 'package:deliverapp/core/errors/exceptions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deliverapp/core/services/api_service.dart';
import 'package:deliverapp/core/services/notification_service.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/constants.dart';
import '../../core/providers/app_provider.dart';
import '../../widgets/loading_indicator.dart';
import 'order_map_page.dart';

class ReviewPage extends StatefulWidget {
  final dynamic vehicleDetail;
  final dynamic price;
  final double distance;
  const ReviewPage(
      {super.key,
      required this.vehicleDetail,
      required this.price,
      required this.distance});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> with TickerProviderStateMixin {
  String validateStr = '';
  dynamic couponDetails;
  double totalPrice = 0.0;
  double couponPrice = 0.0;
  double netFare = 0.0;
  double payableAmount = 0.0;
  int? _selectedVehicle;
  TextEditingController fromLocController = TextEditingController();
  TextEditingController toLocController = TextEditingController();
  TextEditingController couponController = TextEditingController();
  FocusNode couponFocusNode = FocusNode();
  bool isEnabled = false;
  String? selectedPaymentMethod; // null = not selected, "cash" = cash selected
  bool _showSuccessAlert = false;

  // Animation Controllers
  late AnimationController _headerController;

  // Animations
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    totalPrice = double.parse(widget.price.toString());
    netFare = double.parse(widget.price.toString());
    payableAmount = double.parse(widget.price.toString());

    // Initialize Animation Controllers
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Initialize Animations
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOut,
    );

    // Start entrance animations after first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _headerController.forward();
      }
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    couponFocusNode.dispose();
    couponController.dispose();
    fromLocController.dispose();
    toLocController.dispose();
    super.dispose();
  }

  applyCoupon() async {
    couponPrice = 0.0;
    netFare = 0.0;
    payableAmount = 0.0;
    setState(() {});
    if (couponController.text != '') {
      try {
        LoadingOverlay.of(context).show();
        await ApiService().validateCoupon(couponController.text).then((value) {
          debugPrint("......// $value");
          LoadingOverlay.of(context).hide();
          if (value != null) {
            if (value['success'] == true) {
              if (value['data'] != null &&
                  value['message'].toString().toLowerCase() ==
                      'request was successfull') {
                setState(() {
                  _showSuccessAlert = true;
                });

                // Hide the animation after it completes
                Future.delayed(const Duration(seconds: 2), () {
                  setState(() {
                    _showSuccessAlert = false;
                  });
                });
                couponDetails = value['data'];
                couponPrice = double.parse((double.parse(
                            (double.parse(widget.price.toString()) *
                                    double.parse(
                                        couponDetails['discountPercentage']
                                            .toString()))
                                .toString()) /
                        100)
                    .ceilToDouble()
                    .toString());
                double.parse(couponDetails['discountPercentage'].toString());
                netFare = double.parse((double.parse(widget.price.toString()) -
                            double.parse(couponPrice.toString()))
                        .toString())
                    .ceilToDouble();
                payableAmount = netFare;
                debugPrint("/////// $couponDetails");
                debugPrint("/////// $netFare");
                setState(() {});
              } else {
                couponPrice = 0.0;
                netFare = double.parse((double.parse(widget.price.toString()) -
                            double.parse(couponPrice.toString()))
                        .toString())
                    .ceilToDouble();
                payableAmount = netFare;
                debugPrint("/////// $netFare");
                setState(() {});
                notificationService.showToast(context, value['message'],
                    type: NotificationType.error);
              }
            }
          }
        }).catchError((onError) {
          LoadingOverlay.of(context).hide();
        });
      } catch (e) {
        debugPrint("eeeeee::: $e");
        if (e is ClientException) {
          notificationService.showToast(context, e.message.toString(),
              type: NotificationType.error);
        }
      }
    } else {
      notificationService.showToast(context, "Enter valid coupon code",
          type: NotificationType.error);
    }

    couponFocusNode.unfocus();
    setState(() {});
  }

  book() async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);

    // Check if pickup and drop-off locations are the same
    if (appProvider.pickupAddress != null && appProvider.dropAddress != null) {
      final pickupLat = appProvider.pickupAddress!.latlng?.latitude;
      final pickupLng = appProvider.pickupAddress!.latlng?.longitude;
      final dropLat = appProvider.dropAddress!.latlng?.latitude;
      final dropLng = appProvider.dropAddress!.latlng?.longitude;

      if (pickupLat != null &&
          pickupLng != null &&
          dropLat != null &&
          dropLng != null &&
          pickupLat == dropLat &&
          pickupLng == dropLng) {
        notificationService.showToast(
          context,
          "Both locations shouldn't be same",
          type: NotificationType.error,
        );
        return;
      }
    }

    LoadingOverlay.of(context).show();
    debugPrint(".....vahicle ${widget.vehicleDetail.sId}");
    var paymentDet = {
      "paymentType":
          selectedPaymentMethod ?? "cash", // Use selected payment method
      "price": num.parse(totalPrice.toString()),
      "discountAmount": num.parse(couponPrice.toString()),
      "userPaid": num.parse(payableAmount.toString()),
    };
    try {
      await ApiService()
          .orderCreate(
              pickup: appProvider.pickupAddress!,
              drop: appProvider.dropAddress!,
              paymentDetails: paymentDet,
              distance: widget.distance,
              coupon: "",
              vehicleId: widget.vehicleDetail.sId)
          .then((value) {
        LoadingOverlay.of(context).hide();
        debugPrint("order resp:::::::$value");
        if (value['success']) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => OrderMapPage(
                        orderId: value['data']['_id'],
                        vehicleName: widget.vehicleDetail.name,
                      )));
        } else {
          debugPrint("error::::1 ${value['message']}");
          LoadingOverlay.of(context).hide();
          notificationService.showToast(context, value['message'],
              type: NotificationType.error);
        }
      });
    } catch (e) {
      debugPrint("error::::2 $e");
      if (context.mounted) {
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
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    fromLocController.text = appProvider.pickupAddress!.addressString!;
    toLocController.text = appProvider.dropAddress!.addressString!;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 12.0,
              bottom: 12.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Payment Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: selectedPaymentMethod == "cash"
                            ? [buttonColor, secondaryColor]
                            : [Colors.grey.shade400, Colors.grey.shade500],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: selectedPaymentMethod == "cash"
                          ? [
                              BoxShadow(
                                color: buttonColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (selectedPaymentMethod == "cash") {
                            book();
                          } else {
                            notificationService.showToast(
                              context,
                              "Select payment method",
                              type: NotificationType.error,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            "Continue",
                            style: GoogleFonts.inter(
                              color: pureWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: primaryColor,
      body: /*vehicleList == null || vehicleList.length == 0
          ? const SafeArea(
              child: Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            ))
          :*/
          GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryColor, primaryColor],
                ),
              ),
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  // Modern Header
                  FadeTransition(
                    opacity: _headerAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -0.3),
                        end: Offset.zero,
                      ).animate(_headerAnimation),
                      child: Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 12.0,
                          bottom: 12.0,
                          left: 16.0,
                          right: 16.0,
                        ),
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
                              "Review and place your order",
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
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Modern Address Cards Section
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
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Card(
                                elevation: 4,
                                shadowColor: Colors.black.withOpacity(0.08),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: pureWhite,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Pickup Location
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: secondaryColor
                                                  .withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                'assets/images/source_ring.svg',
                                                height: 24,
                                                width: 24,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Pick-up location",
                                                  style: GoogleFonts.inter(
                                                    color: secondaryColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  appProvider.pickupAddress!
                                                      .addressString!,
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.inter(
                                                    color: pureBlack,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  "${appProvider.pickupAddress!.name!} : ${appProvider.pickupAddress!.phone}",
                                                  style: GoogleFonts.inter(
                                                    color: addressTextColor,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Divider(
                                        color: greyBorderColor.withOpacity(0.3),
                                        height: 1,
                                      ),
                                      const SizedBox(height: 20),
                                      // Drop-off Location
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: SvgPicture.asset(
                                                'assets/images/dest_marker.svg',
                                                height: 24,
                                                width: 24,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Drop-off location",
                                                  style: GoogleFonts.inter(
                                                    color: Colors.red,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  appProvider.dropAddress!
                                                      .addressString!,
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.inter(
                                                    color: pureBlack,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  "${appProvider.dropAddress!.name!} : ${appProvider.dropAddress!.phone}",
                                                  style: GoogleFonts.inter(
                                                    color: addressTextColor,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Modern Fare Summary Section
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 800),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16.0,
                                    bottom: 12.0,
                                  ),
                                  child: Text(
                                    "Fare Summary",
                                    style: GoogleFonts.inter(
                                      color: pureWhite,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: Card(
                                    elevation: 4,
                                    shadowColor: Colors.black.withOpacity(0.08),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: pureWhite,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        children: [
                                          // Trip Fare
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Trip Fare (${widget.vehicleDetail.name ?? 'Motorcycle'})",
                                                  style: GoogleFonts.inter(
                                                    color: addressTextColor,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  "$rupeeSymbol ${double.parse(widget.price.toString())}",
                                                  style: GoogleFonts.inter(
                                                    color: pureBlack,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Divider(
                                            color: greyBorderColor
                                                .withOpacity(0.3),
                                            height: 1,
                                            thickness: 1,
                                          ),
                                          // Net Fare
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Net Fare",
                                                  style: GoogleFonts.inter(
                                                    color: addressTextColor,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  "$rupeeSymbol ${netFare.toStringAsFixed(1)}",
                                                  style: GoogleFonts.inter(
                                                    color: pureBlack,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Divider(
                                            color: greyBorderColor
                                                .withOpacity(0.3),
                                            height: 1,
                                            thickness: 1,
                                          ),
                                          // Amount Payable
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Amount payable",
                                                  style: GoogleFonts.inter(
                                                    color: pureBlack,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  "$rupeeSymbol ${payableAmount.toStringAsFixed(1)}",
                                                  style: GoogleFonts.inter(
                                                    color: primaryColor,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          // Disclaimer
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: lightWhiteColor,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Exclude extra fees (e.g. toll or parking fee). Please settle with the driver.',
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: addressTextColor,
                                                fontWeight: FontWeight.w400,
                                              ),
                                              textAlign: TextAlign.center,
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
                          // Payment Method Selection Section
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 900),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16.0,
                                    bottom: 12.0,
                                  ),
                                  child: Text(
                                    "Payment Method",
                                    style: GoogleFonts.inter(
                                      color: pureWhite,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: Card(
                                    elevation: 4,
                                    shadowColor: Colors.black.withOpacity(0.08),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: pureWhite,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            selectedPaymentMethod = "cash";
                                          });
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: selectedPaymentMethod ==
                                                      "cash"
                                                  ? secondaryColor
                                                  : greyBorderColor,
                                              width: selectedPaymentMethod ==
                                                      "cash"
                                                  ? 2
                                                  : 1,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            color:
                                                selectedPaymentMethod == "cash"
                                                    ? secondaryColor
                                                        .withOpacity(0.05)
                                                    : Colors.transparent,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color:
                                                        selectedPaymentMethod ==
                                                                "cash"
                                                            ? secondaryColor
                                                            : greyBorderColor,
                                                    width: 2,
                                                  ),
                                                  color:
                                                      selectedPaymentMethod ==
                                                              "cash"
                                                          ? secondaryColor
                                                          : Colors.transparent,
                                                ),
                                                child: selectedPaymentMethod ==
                                                        "cash"
                                                    ? const Icon(
                                                        Icons.check,
                                                        color: pureWhite,
                                                        size: 16,
                                                      )
                                                    : null,
                                              ),
                                              const SizedBox(width: 16),
                                              SvgPicture.asset(
                                                'assets/images/rupee.svg',
                                                height: 24,
                                                width: 24,
                                                fit: BoxFit.contain,
                                              ),
                                              const SizedBox(width: 16),
                                              Text(
                                                "Cash",
                                                style: GoogleFonts.inter(
                                                  color: pureBlack,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_showSuccessAlert)
              Center(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 50,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Lottie.asset(
                      'assets/images/succesGif.json', // Replace with your Lottie animation file
                      backgroundLoading: false,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      repeat: false, // Play only once
                    ),
                  ),
                ),
              ),
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
                // SizedBox(
                //     child: SvgPicture.network('$imageUrl$image',
                //         fit: BoxFit.contain)),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
