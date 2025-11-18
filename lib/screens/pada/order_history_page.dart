import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deliverapp/core/services/notification_service.dart';
import '../../core/colors.dart';
import '../../core/models/history_model.dart';
import '../../core/services/api_service.dart';
import '../../widgets/order_history_card_widget.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({
    super.key,
  });
  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  bool success = false;
  OrderHistoryModel? historyList;
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  int skip = 0;
  final int limit = 10;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _getMoreData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Fetch paginated data
  Future<void> _getMoreData() async {
    if (isLoading || !hasMoreData) return;

    setState(() {
      isLoading = true;
    });

    // try {
    final response = await ApiService().getOrderHistory(
      skip: skip.toString(),
      limit: limit.toString(),
    );
    // debugPrint("order history List:::::::::: ${response['data'][0]['vehicleImage']}");

    if (response['success']) {
      OrderHistoryModel tempList = OrderHistoryModel.fromJson(response);

      setState(() {
        success = true;
        if (historyList == null) {
          historyList = tempList;
        } else {
          historyList!.data!.addAll(tempList.data!);
        }
        if (tempList.data!.length < limit) {
          hasMoreData = false;
        } else {
          skip += limit;
        }
      });
    } else {
      notificationService.showToast(context, response['message'],
          type: NotificationType.error);
    }
    setState(() {
      isLoading = false;
    });
  }

  /// Scroll listener to trigger pagination
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !isLoading &&
        hasMoreData) {
      _getMoreData();
    }
  }

  /// Builds loading indicator for pagination
  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator(
                color: secondaryColor,
              )
            : hasMoreData
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      "No more orders",
                      style: GoogleFonts.inter(
                        color: greyText,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
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
      body: success
          ? Column(
              children: [
                // Header Section
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.only(top: 20, bottom: 16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [primaryColor, primaryColor],
                      stops: [0.0, 1.0],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Center(
                      child: Text(
                        "Orders",
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
                  child: historyList == null || historyList!.data!.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: greyText,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No Orders",
                                style: GoogleFonts.inter(
                                  color: pureBlack,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "You don't have any orders yet",
                                style: GoogleFonts.inter(
                                  color: greyText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: historyList!.data!.length + 1,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 16.0,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            if (index == historyList!.data!.length) {
                              return _buildProgressIndicator();
                            }

                            return TweenAnimationBuilder<double>(
                              duration:
                                  Duration(milliseconds: 300 + (index * 50)),
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
                              child: ConnectHistoryListCardWidget(
                                historyList: historyList!.data![index],
                              ),
                            );
                          },
                        ),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(
                color: secondaryColor,
              ),
            ),
    );
  }
}
