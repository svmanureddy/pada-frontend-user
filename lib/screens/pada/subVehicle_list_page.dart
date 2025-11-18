import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deliverapp/core/constants.dart';
import 'package:deliverapp/screens/pada/review_page.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/providers/app_provider.dart';
import '../../core/services/api_service.dart';

class SubVehicleListPage extends StatefulWidget {
  final dynamic vehicleList;
  const SubVehicleListPage({super.key, required this.vehicleList});

  @override
  State<SubVehicleListPage> createState() => _SubVehicleListPageState();
}

class _SubVehicleListPageState extends State<SubVehicleListPage>
    with TickerProviderStateMixin {
  int? _selectedVehicle;

  // Animation Controllers
  late AnimationController _headerController;

  // Animations
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).padding.top + 60,
        ),
        child: FadeTransition(
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
                  decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryColor, primaryColor],
            ),
          ),
                      child: Row(
                        children: [
                  InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: pureWhite.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: pureWhite,
                        size: 18,
                      ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "Select a vehicle",
                            style: GoogleFonts.inter(
                      color: pureWhite,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                          ),
                          const Spacer(),
                  // Placeholder to balance the layout
                  const SizedBox(width: 40),
                        ],
                      ),
                    ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: backgroundColor,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Vehicle List
                ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.vehicleList.length,
                        itemBuilder: (context, index) {
                    return TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 600 + (index * 100)),
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
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: InkWell(
                            onTap: () async {
                              var distance = await ApiService().distanceCalc([
                                appProvider.pickupAddress!.latlng!.latitude,
                                appProvider.pickupAddress!.latlng!.longitude,
                              ], [
                                appProvider.dropAddress!.latlng!.latitude,
                                appProvider.dropAddress!.latlng!.longitude,
                              ]);
                              if (distance['success']) {
                                if (distance['data'] != null) {
                                  double calculatedTotal = double.parse(
                                          distance['data'].toString()) *
                                      double.parse(widget
                                          .vehicleList[index].price
                                          .toString());
                                  debugPrint("///////dist :: $distance");
                                  _selectedVehicle = index;
                                  setState(() {});
                                // Navigate directly to ReviewPage
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                    builder: (context) => ReviewPage(
                                      vehicleDetail: widget.vehicleList[index],
                                      price: calculatedTotal.ceilToDouble(),
                                      distance: double.parse(
                                        distance['data'].toString(),
                                      ),
                                    ),
                                  ),
                                        );
                                }
                              }
                            },
                          borderRadius: BorderRadius.circular(16),
                          child: vehicleCard(
                            widget.vehicleList[index].name,
                            widget.vehicleList[index].name,
                            index,
                          ),
                        ),
                            ),
                          );
                        },
                      ),
              ],
                ),
              ),
            ),
      ),
    );
  }

  Widget vehicleCard(String name, String image, int index) {
    final isSelected = _selectedVehicle == index;
    return Container(
      decoration: BoxDecoration(
        color: pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? primaryColor : greyBorderColor,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? primaryColor.withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
      children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                // Vehicle Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                      child: SvgPicture.network(
                          "$imageUrl${widget.vehicleList[index].image}",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Vehicle Name
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                        color: pureBlack,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Tap to select",
                        style: GoogleFonts.inter(
                          color: addressTextColor,
                        fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                ],
              ),
            ),
                // Selection Indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                              shape: BoxShape.circle,
                    color: isSelected ? primaryColor : greyBorderColor,
                    border: Border.all(
                      color: isSelected ? primaryColor : greyBorderColor,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                            color: pureWhite,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),
          ),
      ],
      ),
    );
  }
}
