// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'package:aion_project/constants/app_constants.dart';
import 'package:aion_project/features/auth/verification/data/rx_verify_otp/api.dart';
import 'package:aion_project/features/auth/verification/model/verification_response_model.dart';
import 'package:aion_project/helpers/di.dart';
import 'package:aion_project/networks/dio/dio.dart';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../helpers/toast.dart';
import '../../../../../networks/rx_base.dart';


final class GetVerifyOtpRX extends RxResponseInt<VerificationModel> {
  final api = VerifyOtpApi.instance;

  GetVerifyOtpRX({required super.empty, required super.dataFetcher});

  ValueStream get getFileData => dataFetcher.stream;

  Future<bool> verofyOtp(
    {
    required String email,
    required String otp,
    }
  ) async {
    try {
      VerificationModel data = (await api.verifyOtp(
        email: email,
        otp: otp
      )) as VerificationModel;
      ToastUtil.showShortToast(data.message!);
      handleSuccessWithReturn(data);
      return true;
    } catch (error) {
      return handleErrorWithReturn(error);

    }
  }


  @override
  handleSuccessWithReturn(VerificationModel data) {
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
      ToastUtil.showShortToast(error.response!.data["message"]);
    }
    log(error.toString());
    dataFetcher.sink.addError(error);
    // throw error;
    return false;
  }
}




