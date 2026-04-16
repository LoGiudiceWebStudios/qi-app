import 'dart:convert';
import 'package:aion_project/helpers/toast.dart';
import 'package:dio/dio.dart';
import '../../../../../networks/dio/dio.dart';
import '../../../../../networks/exception_handler/data_source.dart';
import '/networks/endpoints.dart';

final class SocialLoginApi {
  static final  SocialLoginApi _singleton = SocialLoginApi._internal();

  SocialLoginApi._internal();

  static  SocialLoginApi get instance => _singleton;

  Future<Map<String, dynamic>> signInApi({required String token, required dynamic provider}) async {
    try {
      // Create the request data map
      Map<String, dynamic> data = {
        "token": token,
        "provider": provider,
      };
      // Make the POST request
      Response response = await postHttp(Endpoints.socialLogin(), data);
      // Check the response status code

      if (response.statusCode == 200) {
        final data = json.decode(json.encode(response.data));
        ToastUtil.showShortToast('Verified Successfully');
        return data;

      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      print("Error during signup: $error");
      rethrow; // Re-throwing the error for further handling
    }
  }
}
