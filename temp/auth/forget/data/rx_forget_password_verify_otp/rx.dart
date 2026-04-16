// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../helpers/toast.dart';
import '../../../../../networks/rx_base.dart';
import '../../model/otp_verification_model.dart';
import 'api.dart';


final class ForgetPasswordVerifyOtpApiRx extends RxResponseInt<OtpVeificationResponseModel> {
  final api = ForgetPasswordVerifyOtpApi.instance;

  ForgetPasswordVerifyOtpApiRx({required super.empty, required super.dataFetcher});

  ValueStream get getFileData => dataFetcher.stream;

  Future<bool> verofyOtp(
    {
    required String email,
    required String otp,
    }
  ) async {
    try {
      OtpVeificationResponseModel data = (await api.verifyOtp(
        email: email,
        otp: otp
      ));
      ToastUtil.showShortToast(data.message!);
      handleSuccessWithReturn(data);
      return true;
    } catch (error) {
      return handleErrorWithReturn(error);

    }
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




