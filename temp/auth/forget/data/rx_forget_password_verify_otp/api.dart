import 'dart:convert';
import 'package:aion_project/features/auth/forget/model/otp_verification_model.dart';
import 'package:dio/dio.dart';
import '../../../../../networks/dio/dio.dart';
import '../../../../../networks/exception_handler/data_source.dart';
import '/networks/endpoints.dart';

final class ForgetPasswordVerifyOtpApi {
  static final ForgetPasswordVerifyOtpApi _singleton = ForgetPasswordVerifyOtpApi._internal();
  ForgetPasswordVerifyOtpApi._internal();
  static ForgetPasswordVerifyOtpApi get instance => _singleton;

  Future<OtpVeificationResponseModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      Map data = {
        "email": email,
        "code": otp
      };

      Response response = await postHttp(Endpoints.verifyCode(), data);

      if (response.statusCode == 200) {
        final data =
        OtpVeificationResponseModel.fromRawJson(json.encode(response.data));
        return data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      // Handle generic errors
      // throw ErrorHandler.handle(error).failure.responseMessage;
      rethrow;
    }
  }
}
