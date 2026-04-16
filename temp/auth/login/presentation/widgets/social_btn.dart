import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialBtn extends StatelessWidget {
  const SocialBtn({super.key, this.iconNm, this.onTap,});

  final String? iconNm;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        alignment: Alignment.center,
        width: 68.w,
        height: 44.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.r),
          color: Colors.white.withOpacity(0.30),
        ),
        child: SvgPicture.asset(
          iconNm!,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
