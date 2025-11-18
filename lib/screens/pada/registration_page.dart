import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/colors.dart';
import '../../core/services/api_service.dart';
import '../../core/services/notification_service.dart';
import '../../widgets/button.dart';
import '../../widgets/loading_indicator.dart';
import 'dashboard_page.dart';

class RegistrationPage extends StatefulWidget {
  final String mobNumber;
  const RegistrationPage({super.key, required this.mobNumber});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isFilled = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: pureWhite,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.35,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: primaryColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              height: MediaQuery.of(context).size.height * 0.06,
                              child: SvgPicture.asset(
                                  'assets/images/pada_logo.svg',
                                  fit: BoxFit.fill)),
                          Text("Pada Delivery",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  color: pureWhite,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                // height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: pureWhite,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height / 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.08,
                              height: MediaQuery.of(context).size.height * 0.02,
                              child: SvgPicture.asset(
                                  'assets/images/india_flag.svg',
                                  fit: BoxFit.fill)),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(widget.mobNumber,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                  color: pureBlack,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 30),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: TextFormField(
                                controller: fNameController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (str) {
                                  if (str!.isEmpty) {
                                    return 'This field must not be empty';
                                  }
                                  return null;
                                },
                                style: GoogleFonts.inter(
                                    color: pureBlack,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                                decoration: InputDecoration(
                                    errorStyle: const TextStyle(fontSize: 0.01),
                                    errorBorder: UnderlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 1,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    helperStyle: GoogleFonts.inter(
                                        color: pureBlack,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                    hintText: "First name",
                                    border: const UnderlineInputBorder()),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.45,
                              child: TextFormField(
                                controller: lNameController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (str) {
                                  if (str!.isEmpty) {
                                    return 'This field must not be empty';
                                  }
                                  return null;
                                },
                                style: GoogleFonts.inter(
                                    color: pureBlack,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                                decoration: InputDecoration(
                                    errorStyle: const TextStyle(fontSize: 0.01),
                                    errorBorder: UnderlineInputBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 1,
                                        style: BorderStyle.solid,
                                      ),
                                    ),
                                    helperStyle: GoogleFonts.inter(
                                        color: pureBlack,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400),
                                    hintText: "Last name",
                                    border: const UnderlineInputBorder()),
                              ),
                            ),
                          ]),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15.0, vertical: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
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
                            style: GoogleFonts.inter(
                                color: pureBlack,
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                            decoration: InputDecoration(
                                errorStyle: const TextStyle(fontSize: 0.01),
                                errorBorder: UnderlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                helperStyle: GoogleFonts.inter(
                                    color: pureBlack,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400),
                                hintText: "Email id",
                                border: const UnderlineInputBorder()),
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.05,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: CustomButton(
                              buttonLabel: 'Register',
                              buttonWidth: double.infinity,
                              backGroundColor:
                                  /*isFilled ? Colors.grey :*/ buttonColor,
                              onTap: () async {
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
                                      // debugPrint(value);
                                      LoadingOverlay.of(context).hide();
                                      if (value['success']) {
                                        await Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const DashboardPage()),
                                          (Route<dynamic> route) => false,
                                        );
                                      } else {
                                        // LoadingOverlay.of(context).hide();
                                        notificationService.showToast(
                                            context, value['message'],
                                            type: NotificationType.error);
                                      }
                                    });
                                  } else {
                                    // LoadingOverlay.of(context).hide();
                                    notificationService.showToast(
                                        context, "Enter valid email",
                                        type: NotificationType.error);
                                  }
                                }
                              }),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height / 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )),
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
