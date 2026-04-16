import 'dart:convert';
import 'package:aion_project/features/auth/verification/model/verification_response_model.dart';
import 'package:dio/dio.dart';
import '../../../../../networks/dio/dio.dart';
import '../../../../../networks/exception_handler/data_source.dart';
import '/networks/endpoints.dart';

final class VerifyOtpApi {
  static final VerifyOtpApi _singleton = VerifyOtpApi._internal();
  VerifyOtpApi._internal();
  static VerifyOtpApi get instance => _singleton;

  Future<VerificationModel> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      Map data = {
        "email": email,
        "otp": otp
      };

      //Response response = await postHttp(Endpoints.verifyCode(), data);
      Response response = await postHttp(Endpoints.apiSignUpVerify(), data);

      if (response.statusCode == 200) {
        final data =
            VerificationModel.fromRawJson(json.encode(response.data));
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
