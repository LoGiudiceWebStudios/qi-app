import 'dart:developer';

import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import '../../../networks/dio/dio.dart';
import '/helpers/di.dart';
import '../../../../../constants/app_constants.dart';
import '../../../../../networks/exception_handler/data_source.dart';
import '../../../../../networks/rx_base.dart';
import 'api.dart';

final class PostSocialLoginRx extends RxResponseInt<Map> {
  final api = SocialLoginApi.instance;
  String message = "Can't login!".tr;

  PostSocialLoginRx({required super.empty, required super.dataFetcher});

  ValueStream get getSocaialLoginRes => dataFetcher.stream;

  Future<void> postSocailLogin({
    required String registerType, required String token,
  }) async {
    try {
      Map resData = await api.signInApi(
          token: token,
          provider: registerType
      );
      log(" from response : $resData");
      return handleSuccessWithReturn(resData);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }


  @override
  handleSuccessWithReturn(data) async{
    message = data["message"];
    if (data["status"] == true) {
      String accesstoken = data["token"];
      log('rx token $accesstoken');
      String id = data["data"]["id"].toString();
      // dynamic trems = data["data"]["agree_to_terms"];
      await appData.write(kKeyIsLoggedIn, true);
      await appData.write(kKeyAccessToken, accesstoken);
      await appData.write(kKeyUserID, id);
      DioSingleton.instance.update(accesstoken);
      dataFetcher.sink.add(data);
      return data;
      // return true;
    } else {
      throw DataSource.DEFAULT.getFailure();
    }
  }
}
