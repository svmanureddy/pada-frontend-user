import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/colors.dart';

class CustomButton extends StatefulWidget {
  final String buttonLabel;
  final Color backGroundColor;
  final Color? textColor;
  final VoidCallback onTap;
  final bool loading;
  final FontWeight? fontWeight;
  final double buttonWidth, buttonTextSize, borderRadius;
  const CustomButton(
      {super.key,
      required this.buttonLabel,
      this.textColor,
      required this.backGroundColor,
      required this.onTap,
      this.fontWeight,
      required this.buttonWidth,
      this.buttonTextSize = 18,
      this.borderRadius = 5,
      this.loading = false});

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius)),
            fixedSize: Size(
                widget.buttonWidth,
                MediaQuery.of(context).size.height / 14 < 55
                    ? 55
                    : MediaQuery.of(context).size.height / 14),
            backgroundColor: widget.backGroundColor,
            textStyle: GoogleFonts.openSans(
                color: widget.textColor ?? pureWhite,
                fontSize: widget.buttonTextSize,
                fontWeight: widget.fontWeight ?? FontWeight.w600)),
        onPressed: widget.loading ? null : widget.onTap,
        child: Center(
          child: widget.loading
              ? const SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(color: pureWhite))
              : Text(widget.buttonLabel),
        ));
  }
}
