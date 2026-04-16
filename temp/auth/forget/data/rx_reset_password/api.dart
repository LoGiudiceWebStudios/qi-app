import 'dart:convert';
import 'package:aion_project/features/auth/forget/model/reset_password_response_model.dart';
import 'package:dio/dio.dart';
import '../../../../../networks/dio/dio.dart';
import '../../../../../networks/exception_handler/data_source.dart';
import '/networks/endpoints.dart';

final class ForgotPasswordApi {
  static final ForgotPasswordApi _singleton = ForgotPasswordApi._internal();
  ForgotPasswordApi._internal();
  static ForgotPasswordApi get instance => _singleton;

  Future<ResetResponseModel> resetPassword({
    required String email,
  }) async {
    try {
      Map data = {
        "email": email,
      };

      Response response = await postHttp(Endpoints.forgotPassword(), data);

      if (response.statusCode == 200) {
        final data =
            ResetResponseModel.fromRawJson(json.encode(response.data));
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
