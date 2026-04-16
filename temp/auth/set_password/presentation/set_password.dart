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

class SetPasswordScreen extends StatefulWidget {
  final String email, otp;
  const SetPasswordScreen({super.key, required this.email, required this.otp});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _passwordCrtl = TextEditingController();
  final _newPasswordCrtl = TextEditingController();
  final _passwordFN = FocusNode();
  final _newPasswordFN = FocusNode();

  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);


  bool isPasswordVisible = false;
  bool isNewPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            //image: AssetImage(Assets.images.homeBg2.path),
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
                    color: AppColors.cFFFFFF.withOpacity(.7)
                  ),
                ),
                UIHelper.verticalSpace(19.h),
                // UIHelper.verticalSpaceSmall,
                passwordSection(),
                UIHelper.verticalSpace(27.h),

                newPasswordSection(),
                UIHelper.verticalSpace(27.h),
                ValueListenableBuilder(
                  valueListenable: _isLoading,
                  builder: (context, isLoading, child) {
                    return ActionButton(
                      isLoading: isLoading,
                      btnNm: "Reset Password",
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          _isLoading.value = true;
                          setNewPasswordRXOBJ.setNewPassword(
                            email: widget.email, 
                            otp: widget.otp, 
                            password: _passwordCrtl.text.trim(), 
                            confirmPassword: _newPasswordCrtl.text.trim() ).then((sucess){
                              if(sucess){
                                _isLoading.value = false;
                                NavigationService.navigateToReplacement(Routes.logInScreen);
                    
                              }
                              _isLoading.value = false;
                            });
                          
                          // NavigationService.navigateToWithArgs(Routes.verification,
                          //     {"email": _emailCrtl.text.toString().trim()});
                        }
                      },
                    );
                  }
                ),

                // Spacer(),
                // backToLogn(),
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
              height: 40.h,
              width: 40.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: AppColors.c5683A4, shape: BoxShape.circle),
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
            "Set New Password",
            style: TextFontStyle.headline20StyleInter,
          ),
        ],
      ),
    );
  }

  Widget passwordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password",
          style: TextFontStyle.headline14StyleInterSemiMedium,
        ),
        UIHelper.verticalSpaceSmall,
        CustomFormField2(
          borderColor: AppColors.cFFFFFF.withOpacity(.3),
          focusNode: _passwordFN,
          isObsecure: !isPasswordVisible,
          isPass: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please give new password";
            }
            if (value.length < 8) { // Minimum length validation
              return "Password must be at least 8 characters long";
            }
            return null;
          },
          hintText: "Enter Password",
          textEditingController: _passwordCrtl,
          inputType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                isPasswordVisible = !isPasswordVisible;
              });
            },
            child: Icon(
              isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: _passwordFN.hasFocus ? Colors.blue : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget newPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Password",
          style: TextFontStyle.headline14StyleInterSemiMedium,
        ),
        UIHelper.verticalSpaceSmall,
        CustomFormField2(
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please give confirm password";
            }
            if (value.length < 8) { // Minimum length validation
              return "Password must be at least 8 characters long";
            }
            return null;
          },
          textStyle: TextFontStyle.headline14StyleInter,
          borderColor: AppColors.cFFFFFF.withOpacity(.3),
          isObsecure: !isNewPasswordVisible,
          isPass: true,
          focusNode: _newPasswordFN,
          hintText: "Re-Enter Password",
          textEditingController: _newPasswordCrtl,
          inputType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          suffixIcon: GestureDetector(
            onTap: () {
              setState(() {
                isNewPasswordVisible = !isNewPasswordVisible;
              });
            },
            child: Icon(
              isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: _newPasswordFN.hasFocus ? Colors.blue : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
