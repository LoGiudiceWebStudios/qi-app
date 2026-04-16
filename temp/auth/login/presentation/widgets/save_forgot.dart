import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../constants/text_font_style.dart';

class RememberAndForgetPassWidget extends StatefulWidget {
  const RememberAndForgetPassWidget({super.key, this.onTap, this.isFogot = true});

  final VoidCallback? onTap;
  final bool isFogot;

  @override
  State<RememberAndForgetPassWidget> createState() => _RememberAndForgetPassWidgetState();
}

class _RememberAndForgetPassWidgetState extends State<RememberAndForgetPassWidget> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isChecked = !isChecked;
            });
          },
          child: Container(
            width: 17.w, // Adjust width and height as per design
            height: 17.h,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(5), // Rounded square
              border: Border.all(color: Colors.white, width: 1), // Thicker border
            ),
            child: isChecked
                ? const Icon(Icons.check, size: 14, color: Colors.white) // Checkmark icon
                : null,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "Save Password",
          style: TextFontStyle.headline14StyleInter,
        ),
        const Spacer(),

        widget.isFogot
            ? GestureDetector(
          onTap: widget.onTap,
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFFFFFFFF), // White
                Color(0xFF999999), // Light gray
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              "Forgot Password?",
              style: TextFontStyle.headline14StyleInter.copyWith(
                color: Colors.white, // Set text color to white to show gradient
              ),
            ),
          ),
        )
            : const SizedBox.shrink(),
      ],
    );
  }
}


