
import 'package:aion_project/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:aion_project/common_widgets/action_btn.dart';
import 'package:aion_project/constants/text_font_style.dart';
import 'package:aion_project/gen/assets.gen.dart';
import 'package:aion_project/gen/colors.gen.dart';
import 'package:aion_project/helpers/all_routes.dart';
import 'package:aion_project/helpers/navigation_service.dart';
import 'package:aion_project/helpers/toast.dart';
import 'package:aion_project/helpers/ui_helpers.dart';
import 'package:aion_project/networks/api_acess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:timer_count_down/timer_count_down.dart';

class SignUpVerifyCodeScreen extends StatefulWidget {

  final String? email;
  const SignUpVerifyCodeScreen({super.key, this.email});

  @override
  State<SignUpVerifyCodeScreen> createState() => _SignUpVerifyCodeScreenState();
}

class _SignUpVerifyCodeScreenState extends State<SignUpVerifyCodeScreen> {

  @override
  void initState() {
    print(">>>>>>>>>>>>> What is the verified email: ${widget.email}");
    super.initState();
  }

  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _showButton = ValueNotifier<bool>(false);

  int selectedIndex = 0;
  final List<TextEditingController> _controllers =
  List.generate(4, (index) => TextEditingController());

  late String otpCodde = _controllers.map((controller) => controller.text).join();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.images.appBackground.path),
            // image: AssetImage(Assets.images.homeBg2.path),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.h),
          child: Column(
            children: [
              UIHelper.verticalSpace(25.h),
              appbarSection(),
              UIHelper.verticalSpace(16.h),
              Text(
                "Enter the 4 digit code that we just sent to:",
                style: TextFontStyle.headline16StyleInter.copyWith(
                  fontSize: 15.sp,
                ),
              ),
              Text(
                widget.email ?? '',
                style: TextFontStyle.headline14StyleInterSemiMedium.copyWith(
                  fontSize: 15.sp,
                ),
              ),
              UIHelper.verticalSpace(20.h),
              otpField(),
              UIHelper.verticalSpace(20.h),
              timerWidget(),
              UIHelper.verticalSpace(20.h),
              ValueListenableBuilder(
                  valueListenable: _showButton,
                  builder: (context, showButton, child) {
                    return showButton
                        ? Center(
                      child: RichText(
                        overflow: TextOverflow.clip,
                        textAlign: TextAlign.end,
                        textDirection: TextDirection.rtl,
                        softWrap: true,
                        maxLines: 1,
                        // ignore: deprecated_member_use
                        textScaleFactor: 1,
                        text: TextSpan(
                          text: 'Didn’t receive the OTP? ',
                          style: TextFontStyle.headline14StyleInter,
                          children: const <TextSpan>[
                            TextSpan(
                              text: 'Resend Otp',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        : const SizedBox.shrink();
                  }),
              const Spacer(),
              
              /// >>>>>>>>>>....  Button >>>>>>>>
              ValueListenableBuilder(
                  valueListenable: _isLoading,
                  builder: (context, isLoading, child) {
                    return ActionButton(
                      isLoading: isLoading,
                      btnNm: "Verify",
                      onTap: () {
                        if (otpCodde == "") {
                          ToastUtil.showShortToast("Please insert OTP code first");
                        } else {
                          _isLoading.value = true;
                          verifyOtpRXObj.verofyOtp(
                              email: widget.email ?? '',
                              otp: otpCodde).then((success) {

                            if (success) {
                              _isLoading.value = false;
                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                              authProvider.setAuthenticated();
                              NavigationService.navigateToReplacement(Routes.navigationScreen);
                              // NavigationService.navigateToReplaceWithArgs( Routes.setNewPassword, {'email': widget.email, 'otp': otpCodde });
                            }
                            _isLoading.value = false;
                          });
                        }
                      },
                    );
                  }),
              UIHelper.verticalSpaceMedium,

            ],
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
            "Verification Code",
            style: TextFontStyle.headline20StyleInter,
          ),
        ],
      ),
    );
  }

  Widget otpField() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          width: 65.w,
          height: 62.h,
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: selectedIndex == index
                ? const GradientBoxBorder(
              gradient: LinearGradient(
                colors: [
                  Colors.lightBlueAccent,
                  Colors.purple,
                  Colors.redAccent,
                ],
              ),
              width: 2,
            )
                : Border.all(color: Colors.grey, width: 2),
          ),
          child: TextField(
            controller: _controllers[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: TextFontStyle.headline16StyleInter.copyWith(
              fontSize: 35.sp,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
                FocusScope.of(context).nextFocus();
                setState(() {
                  selectedIndex = index + 1;
                });
              } else if (value.isEmpty && index > 0) {
                FocusScope.of(context).previousFocus();
                setState(() {
                  selectedIndex = index - 1;
                });
              }
            },
          ),
        );
      }),
    );
  }

  Widget timerWidget() {
    return Center(
      child: Container(
        width: 120.w,
        height: 48.h,
        decoration: BoxDecoration(
          color: AppColors.cFFFFFF,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.timer_outlined,
            ),
            UIHelper.horizontalSpaceSmall,
            // const Text("00:21")
            Countdown(
              seconds: 90,
              build: (BuildContext context, double time) =>
                  Text(("${time.toStringAsFixed(0)} Sec")),
              interval: const Duration(milliseconds: 100),
              onFinished: () {
                _showButton.value = true;
              },
            )
          ],
        ),
      ),
    );
  }



}
