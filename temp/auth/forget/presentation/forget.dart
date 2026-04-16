import 'package:aion_project/common_widgets/action_btn.dart';
import 'package:aion_project/constants/text_font_style.dart';
import 'package:aion_project/gen/assets.gen.dart';
import 'package:aion_project/gen/colors.gen.dart';
import 'package:aion_project/helpers/all_routes.dart';
import 'package:aion_project/helpers/navigation_service.dart';
import 'package:aion_project/helpers/ui_helpers.dart';
import 'package:aion_project/networks/api_acess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../common_widgets/custom_text_field_2.dart';

class ForgetScreen extends StatefulWidget {
  const ForgetScreen({super.key});

  @override
  State<ForgetScreen> createState() => _ForgetScreenState();
}

class _ForgetScreenState extends State<ForgetScreen> {
  final _emailCrtl = TextEditingController();
  final _emailFN = FocusNode();

  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _emailCrtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
           // image: AssetImage(Assets.images.homeBg2.path),
            image: AssetImage(Assets.images.appBackground.path),
            fit: BoxFit.cover,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(24.h),
            child: Column(
              children: [
                UIHelper.verticalSpace(25.h),
                appbarSection(),
                UIHelper.verticalSpace(16.h),
                Text(
                  "Enter the email address. A 4-digit code will be sent to the entered Email.",
                  style: TextFontStyle.headline16StyleInter.copyWith(
                      fontSize: 15.sp,
                      color: AppColors.cFFFFFF.withOpacity(.7)),
                ),
                UIHelper.verticalSpace(19.h),
                // UIHelper.verticalSpaceSmall,
                emailSection(),
                UIHelper.verticalSpace(27.h),
                ValueListenableBuilder(
                  valueListenable: _isLoading,
                  builder: (context, isLoading, child) {
                    return ActionButton(
                      isLoading: isLoading,
                      btnNm: "Get Code",
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          _isLoading.value = true;
                          resetPasswordRXObj
                              .resetPassword(email: _emailCrtl.text.trim())
                              .then(
                            (sucess) {
                              if (sucess) {
                                _isLoading.value = false;
                                NavigationService.navigateToWithArgs(
                                    Routes.forgetPasswordVerification, {
                                  "email": _emailCrtl.text.trim().toString()
                                });
                              }
                              _isLoading.value = false;
                            },
                          );
                        }
                      },
                    );
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget appbarSection() {
    return SizedBox(
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              NavigationService.goBack;
            },
            child: Container(
              height: 48.h,
              width: 48.w,
              alignment: Alignment.center,
              decoration:  BoxDecoration(
                  color: Colors.white.withOpacity(.2), shape: BoxShape.circle),
              child: SvgPicture.asset(
                Assets.icons.back,
                fit: BoxFit.cover,
                height: 24.h,
                width: 24.w,
              ),
            ),
          ),
          UIHelper.horizontalSpace(12.w),
          Text(
            "Forget Password",
            style: TextFontStyle.headline20StyleInter,
          ),
        ],
      ),
    );
  }

  Widget emailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email",
          style: TextFontStyle.headline14StyleInterSemiMedium,
        ),
        UIHelper.verticalSpaceSmall,
        CustomFormField2(
          textStyle: TextFontStyle.headline14StyleInter,
          borderColor: AppColors.cFFFFFF.withOpacity(.3),
          focusNode: _emailFN,
          hintText: "Enter your email",
          textEditingController: _emailCrtl,
          inputType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          validator: (value) {
            bool isEmailValidate =
                RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
                    .hasMatch(value.toString());
            if (isEmailValidate) {
              return null;
            } else {
              // log(emailValid);
              return "Validate Email";
            }
            // print(emailValid);
            // return "Validate Email";
          },
        )
      ],
    );
  }

  Widget backToLogn() {
    return GestureDetector(
      onTap: () {
        NavigationService.navigateToReplacement(Routes.logInScreen);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_back,
            size: 16.sp,
            color: AppColors.cFFFFFF.withOpacity(.7),
          ),
          UIHelper.horizontalSpaceSmall,
          Text(
            "Back to log in",
            style: TextFontStyle.headline11StyleInter.copyWith(
                fontSize: 14.sp, color: AppColors.cFFFFFF.withOpacity(.7)),
          ),
        ],
      ),
    );
  }
}
