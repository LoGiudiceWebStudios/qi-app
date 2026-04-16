// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'package:aion_project/features/auth/set_password/data/rx_new_password/api.dart';
import 'package:aion_project/features/auth/set_password/model/reset_password_response_model.dart';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../helpers/toast.dart';
import '../../../../../networks/rx_base.dart';


final class GetNewPassowrdRX extends RxResponseInt<ResetPasswordResponseModel> {
  final api = NewPassowrdApi.instance;

  GetNewPassowrdRX({required super.empty, required super.dataFetcher});

  ValueStream get getFileData => dataFetcher.stream;

  Future<bool> setNewPassword(
    {
    required String email,
    required String otp,
    required String password,
    required String confirmPassword,
    }
  ) async {
    try {
      ResetPasswordResponseModel data = await api.setNewPassword(
        email: email,
        otp: otp,
        password: password,
        confirmPassword: confirmPassword,

      );
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
