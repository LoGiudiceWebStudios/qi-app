import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../../helpers/toast.dart';
import '../../../../../networks/dio/dio.dart';
import '../../../../../networks/exception_handler/data_source.dart';
import '../../model/signup_response_model.dart';
import '/networks/endpoints.dart';

final class SignupApi {
  static final SignupApi _singleton = SignupApi._internal();
  SignupApi._internal();
  static SignupApi get instance => _singleton;

  Future<SignUpResponseModel> signup({
    required String userName,
    required String email,
    required String password,
    required String confirmPw,
  }) async {
    try {
      Map data = {
        "name": userName,
        "email": email,
        "password": password,
        "password_confirmation": confirmPw,
      };

      Response response = await postHttp(Endpoints.signUp(), data);

      if (response.statusCode == 200) {
        final data =
            SignUpResponseModel.fromRawJson(json.encode(response.data));
             ToastUtil.showShortToast("Sign Up Verification Code Sent");
        return data;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      // Handle generic errors
      rethrow;
    }
  }
}
