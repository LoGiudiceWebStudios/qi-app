import 'dart:convert';
import 'package:aion_project/features/auth/set_password/model/reset_password_response_model.dart';
import 'package:dio/dio.dart';
import '../../../../../networks/dio/dio.dart';
import '../../../../../networks/exception_handler/data_source.dart';
import '/networks/endpoints.dart';

final class NewPassowrdApi {
  static final NewPassowrdApi _singleton = NewPassowrdApi._internal();
  NewPassowrdApi._internal();
  static NewPassowrdApi get instance => _singleton;

  Future<ResetPasswordResponseModel> setNewPassword({
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      Map data = {
        "email": email,
        "code": otp,
        "password": password,
        "password_confirmation": confirmPassword
      };

      Response response = await postHttp(Endpoints.setNewPassword(), data);

      if (response.statusCode == 200) {
        final data = ResetPasswordResponseModel.fromRawJson(json.encode(response.data));
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
