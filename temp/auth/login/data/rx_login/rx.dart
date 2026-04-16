// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:aion_project/features/auth/login/data/rx_login/api.dart';
import 'package:aion_project/features/auth/login/model/login_response_model.dart';
import 'package:aion_project/networks/dio/dio.dart';
import 'package:dio/dio.dart';

import 'package:rxdart/rxdart.dart';

import '../../../../../constants/app_constants.dart';
import '../../../../../helpers/di.dart';
import '../../../../../helpers/toast.dart';
import '../../../../../networks/rx_base.dart';


final class GetLoginResponseRX extends RxResponseInt<LoginResponseModel> {
  final api = LogInApi.instance;

  GetLoginResponseRX({required super.empty, required super.dataFetcher});

  ValueStream get getFileData => dataFetcher.stream;

  Future<bool> logIn(
    {
    required String email,
    required String password,
    }
  ) async {
    try {

      LoginResponseModel data = await api.logIn(
        email: email,
        password: password,
      );
      handleSuccessWithReturn(data);
      return true;
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  @override
  handleSuccessWithReturn(LoginResponseModel data) {
    ToastUtil.showShortToast(data.message??"");
    appData.write(kKeyAccessToken, data.token);
    appData.write(kKeyIsLoggedIn, true);
    String token = appData.read(kKeyAccessToken);
    DioSingleton.instance.update(token);

    dataFetcher.sink.add(data);
    return data;
  }

  @override
  handleErrorWithReturn(dynamic error) {
    if(error is DioException){
      if(error.response!.statusCode == 401 ){
        ToastUtil.showShortToast(error.response!.data["data"]["error"]);
      }else{
         ToastUtil.showShortToast(error.response!.data["message"]);
      }
    }
    log(error.toString());
    dataFetcher.sink.addError(error);
    // throw error;
    return false;
  }




}
