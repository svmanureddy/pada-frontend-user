import 'package:deliverapp/core/errors/exceptions.dart';
import 'package:deliverapp/core/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:deliverapp/screens/pada/login_page.dart';
import 'package:deliverapp/screens/pada/support_page.dart';
import 'package:deliverapp/screens/pada/termsAndContions_page.dart';
import 'package:provider/provider.dart';
import '../../core/colors.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/notification_service.dart';
import '../../widgets/alert_dialog_widget.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool success = false;
  List<dynamic> historyList = [];
  final ScrollController _scrollController = ScrollController();

  bool isLoading = false;

  // List<ConnectHistoryModel> names = [];
  int skip = 0;
  int limit = 10;
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1), getData()); // getData();
    // this._getMoreData();
    super.initState();
  }

  getData() {
    historyList = [
      {
        "label": "Edit Profile",
        "icon": 'assets/images/profile.svg',
        "onTap": () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const EditProfilePage()));
        }
      },
      {
        "label": "Terms and conditions",
        "icon": 'assets/images/terms.svg',
        "onTap": () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const TermsAndConditionsPage()));
        }
      },
      {
        "label": "Support",
        "icon": 'assets/images/mail.svg',
        "onTap": () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const SupportPage()));
        }
      },
      {
        "label": "Logout",
        "icon": 'assets/images/logout.svg',
        "onTap": () {
          CustomAlertDialog().successDialog(context, "Alert!",
              "Are you sure you want to logout?", "Confirm", "Cancel", () {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            authProvider.clearLoginCredentials();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (Route<dynamic> route) => false,
            );
          }, () {
            Navigator.pop(context);
          }, okBtnColor: Colors.red);
        }
      },
      {
        "label": "Delete user",
        "icon": 'assets/images/hand.svg',
        "onTap": () {
          CustomAlertDialog().successDialog(
              context,
              "Alert!",
              "Are you sure you want to delete your data?",
              "Confirm",
              "Cancel", () async {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            authProvider.clearLoginCredentials();
            try {
              await ApiService().deleteUser().then((value) {
                debugPrint("ress:: $value");
                if (value['success']) {
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (Route<dynamic> route) => false,
                    );
                  }
                } else {
                  if (mounted) {
                    notificationService.showToast(context, value['message'],
                        type: NotificationType.error);
                  }
                }
              });
            } catch (e) {
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
          }, () {
            Navigator.pop(context);
          }, okBtnColor: Colors.red);
        }
      },
    ];
    success = true;
    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    skip = 0;
    limit = 0;
    super.dispose();
  }

  bool _isDestructiveAction(String label) {
    return label == "Logout" || label == "Delete user";
  }

  Color _getIconColor(String label) {
    if (_isDestructiveAction(label)) {
      return Colors.red;
    }
    return buttonColor;
  }

  Color _getBackgroundColor(String label) {
    if (_isDestructiveAction(label)) {
      return Colors.red.withOpacity(0.1);
    }
    return buttonColor.withOpacity(0.1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: pureWhite,
      body: Column(
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
                  "Account",
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
            child: success
                ? SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: List.generate(
                        historyList.length,
                        (index) {
                          final item = historyList[index];
                          final label = item['label'];
                          final isDestructive = _isDestructiveAction(label);

                          return TweenAnimationBuilder<double>(
                            duration:
                                Duration(milliseconds: 300 + (index * 100)),
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
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: InkWell(
                                onTap: item['onTap'],
                                borderRadius: BorderRadius.circular(16),
                                child: Card(
                                  elevation: 2,
                                  shadowColor: Colors.black.withOpacity(0.05),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: isDestructive
                                          ? Colors.red.withOpacity(0.2)
                                          : Colors.transparent,
                                      width: 1,
                                    ),
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: pureWhite,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    child: Row(
                                      children: [
                                        // Icon Container
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: _getBackgroundColor(label),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              item['icon'],
                                              fit: BoxFit.contain,
                                              height: 24,
                                              width: 24,
                                              colorFilter: ColorFilter.mode(
                                                _getIconColor(label),
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Text Content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                label,
                                                style: GoogleFonts.inter(
                                                  color: isDestructive
                                                      ? Colors.red
                                                      : pureBlack,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Arrow Icon
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: isDestructive
                                                ? Colors.red.withOpacity(0.1)
                                                : secondaryColor
                                                    .withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.arrow_forward_ios_rounded,
                                            size: 14,
                                            color: isDestructive
                                                ? Colors.red
                                                : secondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                : Center(
                    child: CircularProgressIndicator(
                      color: secondaryColor,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
