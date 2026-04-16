import 'dart:developer';

import 'package:aion_project/common_widgets/action_btn.dart';
import 'package:aion_project/networks/api_acess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:aion_project/providers/auth_provider.dart'; // Import the new provider

import '../../../../common_widgets/custom_text_field_2.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/navigation_service.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/auth_provider.dart';
import '../../login/presentation/widgets/save_forgot.dart';

class SignUpScreen extends StatelessWidget  {
  final _nameCrtl = TextEditingController();
  final _emailCrtl = TextEditingController();
  final _passCrtl = TextEditingController();
  final _conPassCrtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isPassVisible = ValueNotifier<bool>(false); // Added for password visibility
  final ValueNotifier<bool> _isConfPassVisible = ValueNotifier<bool>(false); // Added for confirm password visibility

  // Focus node
  final _nameFN = FocusNode();
  final _emailFN = FocusNode();
  final _passFN = FocusNode();
  final _conPassFN = FocusNode();

  @override
  Widget build(BuildContext context) {
    //final authState = ref.watch(authNotifierProvider); // Use the new provider
    final authProvider = Provider.of<AuthProvider>(context); // listen: true di default, per watchare

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(Assets.images.appBackground.path),
                fit: BoxFit.cover)),

        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(24.h),
            children: [
              UIHelper.verticalSpace(25.h),
              appbarSection(),
              UIHelper.verticalSpace(16.h),
              Text("We happy to see you here. Sign Up to your account",
                  style: TextFontStyle.headline16StyleInter),
              UIHelper.verticalSpace(40.h),
              nameSection(),
              UIHelper.verticalSpaceMedium,
              emailSection(),
              UIHelper.verticalSpaceMedium,
              passwordSection(context),
              UIHelper.verticalSpaceMedium,
              confirmPassSection(context),
              UIHelper.verticalSpace(12.h),
              const RememberAndForgetPassWidget(isFogot: false),
              UIHelper.verticalSpace(70.h),

              ValueListenableBuilder(
                  valueListenable: _isLoading,
                  builder: (context, isLoading, child) {
                    return ActionButton(
                      isLoading: isLoading,
                      btnNm: "Sign Up",
                      onTap: () async {

                        if (_formKey.currentState?.validate() ?? false) {
                          _isLoading.value = true;
                          await getRegistrationRXObj
                              .signup(
                                  userName: _nameCrtl.text.trim(),
                                  email: _emailCrtl.text.trim(),
                                  password: _passCrtl.text.trim(),
                                  confirmPw: _passCrtl.text.trim())
                              .then((sucess) {
                            if (sucess) {
                              _isLoading.value = false;
                              // NavigationService.navigateToReplacement(Routes.navigationScreen);
                              NavigationService.navigateToWithArgs(Routes.signUpVerifyCode,{
                                  "email": _emailCrtl.text});
                            }
                            _isLoading.value = false;
                          });
                        }
                      },
                    );
                  }),

              UIHelper.verticalSpace(16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextFontStyle.headline14StyleInter.copyWith(color: AppColors.cFFFFFF.withOpacity(.7)),
                  ),
                  GestureDetector(
                    onTap: () {
                      NavigationService.navigateTo(Routes.logInScreen);
                    },
                    child: Text(
                      "Sign In",
                      style: TextFontStyle.headline14StyleInterSemiBold,
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget passwordSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Password",
            style: TextFontStyle.headline14StyleInterSemiMedium),
        UIHelper.verticalSpaceSmall,
        ValueListenableBuilder<bool>(
          valueListenable: _isPassVisible,
          builder: (context, isPassVisible, child) {
            return CustomFormField2(
              textStyle: TextStyle(color: AppColors.cFFFFFF, fontSize: 14.sp, fontWeight: FontWeight.w400),
              borderColor: AppColors.cFFFFFF.withOpacity(.3),
              isPass: true,
              textEditingController: _passCrtl,
              isObsecure: !isPassVisible, // Default to dots
              suffixIcon: IconButton(
                onPressed: () {
                  _isPassVisible.value = !_isPassVisible.value; // Toggle visibility
                },
                icon: SvgPicture.asset(
                  isPassVisible ? Assets.icons.eyeOff : Assets.icons.eye,
                  height: 24.h,
                  width: 24.w,
                  fit: BoxFit.cover,
                ),
              ),
              focusNode: _passFN,
              inputType: TextInputType.text,
              hintText: 'Enter password',
              validator: (value) {
                  if (value == null || value.isEmpty || value.length < 8) {
                    return "Enter Minimum 8 Digit";
                  } else {
                    return null;
                  }
                }
            );
          },
        ),
      ],
    );
  }

  Widget confirmPassSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Confirm Password",
            style: TextFontStyle.headline14StyleInterSemiMedium),
        UIHelper.verticalSpaceSmall,
        ValueListenableBuilder<bool>(
          valueListenable: _isConfPassVisible,
          builder: (context, isConfPassVisible, child) {
            return CustomFormField2(
              textStyle: TextStyle(color: AppColors.cFFFFFF, fontSize: 14.sp, fontWeight: FontWeight.w400),
              borderColor: AppColors.cFFFFFF.withOpacity(.3),
              isPass: true,
              textEditingController: _conPassCrtl,
              isObsecure: !isConfPassVisible, // Default to dots
              suffixIcon: IconButton(
                onPressed: () {
                  _isConfPassVisible.value = !_isConfPassVisible.value; // Toggle visibility
                },
                icon: SvgPicture.asset(
                  isConfPassVisible ? Assets.icons.eyeOff : Assets.icons.eye,
                  height: 24.h,
                  width: 24.w,
                  fit: BoxFit.cover,
                ),
              ),
              focusNode: _conPassFN,
              inputType: TextInputType.text,
              hintText: 'Re-enter password',
              textInputAction: TextInputAction.done,
              validator: (value) {
                  if (value == null || value.isEmpty || value.length < 8) {
                    return "Enter Minimum 8 Digit";
                  } else if (_passCrtl.text.trim() !=
                      _conPassCrtl.text.trim()) {
                    return "Confirm password does not match";
                  } else {
                    return null;
                  }
                }

            );
          },
        ),
      ],
    );
  }

  Column emailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Email", style: TextFontStyle.headline14StyleInterSemiMedium),
        UIHelper.verticalSpaceSmall,
        CustomFormField2(
          textStyle: TextFontStyle.headline14StyleInter,
          borderColor: AppColors.cFFFFFF.withOpacity(.3),
          focusNode: _emailFN,
          hintText: "Enter your email",
          textEditingController: _emailCrtl,
          inputType: TextInputType.emailAddress,
          validator: (value) {
            final bool emailValid = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                .hasMatch(value ?? "");
            if (value == null || value.isEmpty) {
              return "Please enter your email";
            } else if (!emailValid) {
              return "Please enter a valid email";
            } else {
              return null;
            }
          },
        )
      ],
    );
  }


  Column nameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Name", style: TextFontStyle.headline14StyleInterSemiMedium),
        UIHelper.verticalSpaceSmall,
        CustomFormField2(
            textStyle: TextFontStyle.headline14StyleInter,
          borderColor: AppColors.cFFFFFF.withOpacity(.3),
            focusNode: _nameFN,
            hintText: "Enter your full name",
            textEditingController: _nameCrtl,
            inputType: TextInputType.name,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your name";
              } else {
                return null;
              }
            })
      ],
    );
  }

  SizedBox appbarSection() {
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
                  color: Color(0x1A201B1B),
                  // color: Color(0XFF201B1B),
                  shape: BoxShape.circle),
              child: SvgPicture.asset(
                Assets.icons.back,
                fit: BoxFit.cover,
                height: 24.h,
                width: 24.w,
              ),
              // ),
            ),
          ),
          UIHelper.horizontalSpace(12.w),
          Text(
            "Create Account",
            style: TextFontStyle.headline20StyleInter,
          ),
        ],
      ),
    );
  }
}
