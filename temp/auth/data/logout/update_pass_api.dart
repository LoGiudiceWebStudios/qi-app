// ignore_for_file: non_constant_identifier_names
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../networks/exception_handler/data_source.dart';
import '/networks/endpoints.dart';
import '../../../../../../networks/dio/dio.dart';

final class GetLogoutApi {
  static final GetLogoutApi _singleton = GetLogoutApi._internal();
  GetLogoutApi._internal();
  static GetLogoutApi get instance => _singleton;
  Future<Map> logout() async {
    try {
      Response response = await getHttp(
        Endpoints.logOut(),
      );
      if (response.statusCode == 200) {
        Map data = json.decode(json.encode(response.data));
        return data;
      } else {
        // Handle non-200 status code errors
        throw DataSource.DEFAULT.getFailure();
      }
    } catch (error) {
      // Handle generic errors
      throw ErrorHandler.handle(error).failure;
    }
  }
}
