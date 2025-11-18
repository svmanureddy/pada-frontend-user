import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../core/colors.dart';
import '../core/constants.dart';
import '../core/models/history_model.dart' as order;

class ConnectHistoryListCardWidget extends StatelessWidget {
  const ConnectHistoryListCardWidget({required this.historyList, super.key});
  final order.Data historyList;

  String _getStatusText(num? status) {
    if (status == null) return "Unknown";
    switch (status.toString()) {
      case "1":
        return "Waiting";
      case "2":
        return "Accepted";
      case "3":
        return "On the way to pickup";
      case "4":
        return "Order collected";
      case "5":
        return "On the way to deliver";
      case "6":
        return "Reached destination";
      case "7":
        return "Completed";
      case "10":
        return "Expired";
      default:
        return "Cancelled";
    }
  }

  Color _getStatusColor(num? status) {
    if (status == null) return cancelStatusColor;
    if (status.toString() == "7") {
      return Colors.green;
    }
    return cancelStatusColor;
  }

  IconData _getStatusIcon(num? status) {
    if (status == null) return Icons.cancel;
    if (status.toString() == "7") {
      return Icons.done;
    }
    return Icons.cancel;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: pureWhite,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section - Vehicle Info
                Row(
                  children: [
                    // Vehicle Icon
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child:
                            historyList.vehicleImage.toString().contains(".svg")
                                ? SvgPicture.network(
                                    '$imageUrl${historyList.vehicleImage}',
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.contain)
                                : Image.network(
                                    '$imageUrl${historyList.vehicleImage}',
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Vehicle Name and Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            historyList.vehicleName ?? "Unknown Vehicle",
                            style: GoogleFonts.inter(
                              color: pureBlack,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat("MMM dd'th' yyyy")
                                .format(DateTime.parse(historyList.createdAt!)),
                            style: GoogleFonts.inter(
                              color: greyText,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Price
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "$rupeeSymbol ${historyList.totalAmount}",
                        style: GoogleFonts.inter(
                          color: secondaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Address Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icons Column
                    Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.green,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          width: 2,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.green.withOpacity(0.5),
                                Colors.red.withOpacity(0.5),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.location_on,
                            size: 18,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Addresses Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pickup Address
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${historyList.pickUp!.userName} : ${historyList.pickUp!.phoneNumber}",
                                  style: GoogleFonts.inter(
                                    color: pureBlack,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  historyList.pickUp!.address ?? "",
                                  style: GoogleFonts.inter(
                                    color: greyText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Dropoff Address
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${historyList.drop!.userName} : ${historyList.drop!.phoneNumber}",
                                  style: GoogleFonts.inter(
                                    color: pureBlack,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  historyList.drop!.address ?? "",
                                  style: GoogleFonts.inter(
                                    color: greyText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFEAEAEA),
                ),
                const SizedBox(height: 12),
                // Status and Payment Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(historyList.status)
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(historyList.status),
                            size: 16,
                            color: _getStatusColor(historyList.status),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getStatusText(historyList.status),
                            style: GoogleFonts.inter(
                              color: _getStatusColor(historyList.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Payment Type
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${historyList.paymentType ?? 'cash'}",
                        style: GoogleFonts.inter(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DottedWidget extends StatelessWidget {
  const DottedWidget({super.key, required this.len});
  final int len;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/icons/green_dot_icon.svg',
              width: 8, height: 8),
          for (int i = 0; i < len; i++) ...{
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.3),
                child: Container(
                  width: 1,
                  height: 1,
                  color: greyLight,
                ))
          },
          SvgPicture.asset('assets/icons/red_marker_icon.svg',
              width: 15, height: 15),
        ]);
  }
}
