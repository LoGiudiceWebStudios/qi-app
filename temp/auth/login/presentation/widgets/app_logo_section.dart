import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../constants/text_font_style.dart';


class AppLogoSection extends StatelessWidget {
  const AppLogoSection({super.key,});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128.h,
      width: 134.w,
      decoration: const BoxDecoration(
        color: Color(0XFFD9D9D9),
        shape: BoxShape.circle
      ),
      child: Center(
        child: Text("Logo",
            textAlign: TextAlign.center,
            style: TextFontStyle.headline24StyleInter),
      ),
    );
  }
}