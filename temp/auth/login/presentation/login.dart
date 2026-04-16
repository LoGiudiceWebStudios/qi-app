import 'dart:developer';
import 'package:aion_project/helpers/social_auth.dart';
import 'package:aion_project/helpers/toast.dart';
import 'package:aion_project/networks/api_acess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
//import 'package:provider/provider.dart' as provider;
//import '../../../../providers/auth_provider.dart'; // Ensure AuthProvider is imported
import 'package:aion_project/providers/auth_provider.dart'; // Correct import for AuthProvider
//import 'package:provider/provider.dart'; // Import the provider package
import '../../../../common_widgets/action_btn.dart';
import '../../../../common_widgets/custom_field.dart';
import '../../../../constants/text_font_style.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/navigation_service.dart';
import '../../../../helpers/ui_helpers.dart';
//import '../../../../providers/auth_provider.dart';
import 'widgets/save_forgot.dart';
import 'widgets/social_btn.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:flutter_riverpod/flutter_riverpod.dart';

// Funzione per aprire un link nel browser
Future<void> _launchURL(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $url';
  }
}

class LoginScreen extends StatefulWidget  {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _passFN = FocusNode();
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isPassVisible = ValueNotifier<bool>(false); // Added local ValueNotifier

  @override
  void dispose() {
    log("dispose calling");
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _isPassVisible.dispose(); // Dispose the ValueNotifier
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.images.splashBg.path),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                
                GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(), // Chiude la tastiera toccando fuori
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: IntrinsicHeight(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Spacer(),
                                  SizedBox(
                                    height: 250.h,
                                    child: Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        Positioned(
                                          top: 16.h,
                                          child: Image.asset(Assets.images.appLogo.path, height: 200.h, width: 200.w),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          child: Image.asset(Assets.images.appName.path, height: 50.h, width: 200.w),
                                        ),
                                      ],
                                    ),
                                  ),
                                  UIHelper.verticalSpace(20.h),
                                  socialLoginSection(),
                                  UIHelper.verticalSpace(20.h),
                                  Text("Or", textAlign: TextAlign.center, style: TextFontStyle.headline20StyleInter),
                                  UIHelper.verticalSpace(20.h),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                                    child: Column(
                                      children: [
                                        emailInputField(),
                                        UIHelper.verticalSpaceMedium,
                                        passInputField(),
                                        UIHelper.verticalSpace(12.h),
                                        RememberAndForgetPassWidget(
                                          onTap: () => NavigationService.navigateTo(Routes.forget),
                                        ),
                                        UIHelper.verticalSpaceMediumLarge,
                                        ValueListenableBuilder(
                                          valueListenable: _isLoading,
                                          builder: (context, isLoading, child) {
                                            return ActionButton(
                                              isLoading: isLoading,
                                              btnNm: "Log In",
                                              onTap: () async {
                                                if (_formKey.currentState?.validate() ?? false) {
                                                  _isLoading.value = true;
                                                  try {
                                                    await getLoginRXObj.logIn(
                                                      email: _emailCtrl.text.trim(),
                                                      password: _passCtrl.text.trim(),
                                                    ).then((success) {
                                                      _isLoading.value = false;
                                                      if (success) {
                                                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                                        authProvider.setAuthenticated(); // Set authenticated state
                                                        NavigationService.navigateToReplacement(Routes.navigationScreen);
                                                      } else {
                                                        ToastUtil.showShortToast("Invalid credentials"); // Show feedback for invalid credentials
                                                      }
                                                    });
                                                  } catch (error) {
                                                    _isLoading.value = false;
                                                    ToastUtil.showShortToast("Invalid credentials"); // Show feedback for invalid credentials
                                                  }
                                                }
                                              },
                                            );
                                          },
                                        ),
                                        UIHelper.verticalSpace(16.h),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text("Don’t have an account? ",
                                                style: TextFontStyle.headline14StyleInter.copyWith(color: Colors.white.withOpacity(0.7))),
                                            GestureDetector(
                                              onTap: () {
                                                _passCtrl.clear();
                                                _emailCtrl.clear();
                                                NavigationService.navigateTo(Routes.signUp);
                                              },
                                              child: Text("Sign Up", style: TextFontStyle.headline14StyleInterSemiBold),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10.h),
                                        Container(
                                          width: double.infinity,
                                          height: 1.h,
                                          margin: EdgeInsets.symmetric(horizontal: 30.w),
                                          color: Colors.white.withOpacity(0.5),
                                        ),
                                        SizedBox(height: 10.h),
                                        Text("By continuing, you agree to our ",
                                            style: TextFontStyle.headline11StyleInter.copyWith(color: Colors.white.withOpacity(0.7)),
                                            textAlign: TextAlign.center),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () => _launchURL("https://clubify.it/terms-of-service"),
                                              child: Text("Terms of Service", style: TextFontStyle.headline11StyleInter.copyWith(color: Colors.blue)),
                                            ),
                                            Text(" and ", style: TextFontStyle.headline11StyleInter),
                                            GestureDetector(
                                              onTap: () => _launchURL("https://clubify.it/privacy-policy"),
                                              child: Text("Privacy Policy", style: TextFontStyle.headline12StyleInter.copyWith(color: Colors.blue)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16.h,
            right: 16.w,
            child: TextButton(
              onPressed: () {
                //ref.read(authNotifierProvider.notifier).setGuestMode(); // Use the new provider
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                authProvider.setGuestMode();
                NavigationService.navigateTo(Routes.navigationScreen);
              },
              child: const Text(
                'Skip',
                style: TextStyle(color: Colors.white), // Cambia il colore del testo in bianco
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget emailInputField() {
    
    return CustomFormField(
      textEditingController: _emailCtrl,
      hintText: 'Email',
      hintTextColor: Colors.white.withOpacity(0.7),
      inputType: TextInputType.emailAddress,
      hintFontWeight: FontWeight.w600, // Aggiorna il font per corrispondere a "Sign Up"
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter your email";
        }
        return null;
      },
    );
  }

  Widget passInputField() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isPassVisible,
      builder: (context, isPassVisible, child) {
        return CustomFormField(
          textEditingController: _passCtrl,
          hintText: 'Password',
          hintTextColor: Colors.white.withOpacity(0.7),
          inputType: TextInputType.text,
          isPass: true,
          isObsecure: !isPassVisible, // Toggle visibility
          hintFontWeight: FontWeight.w600,
          suffixIcon: IconButton(
            onPressed: () {
              _isPassVisible.value = !_isPassVisible.value; // Toggle state
            },
            icon: SvgPicture.asset(
              isPassVisible ? Assets.icons.eyeOff : Assets.icons.eye, // Update icon
              height: 24.h,
              width: 24.w,
              fit: BoxFit.cover,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty || value.length < 8) {
              return "Enter Minimum 8 Digit";
            }
            return null;
          },
        );
      },
    );
  }

  Widget socialLoginSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 69.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SocialBtn(iconNm: Assets.icons.google, onTap: () => SocialAuthData.signInWithGoogle(context)),
          UIHelper.horizontalSpace(16.w),
          SocialBtn(iconNm: Assets.icons.apple, onTap: () => SocialAuthData.signInWithApple(context)),
          UIHelper.horizontalSpace(16.w),
          SocialBtn(iconNm: Assets.icons.facebook, onTap: () => ToastUtil.showShortToast('Upcoming ....')),
        ],
      ),
    );
  }
}


