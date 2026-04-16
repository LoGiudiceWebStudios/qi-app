
import 'dart:developer';
import 'package:aion_project/features/auth/forget/data/rx_reset_password/api.dart';
import 'package:aion_project/features/auth/forget/model/reset_password_response_model.dart';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../helpers/toast.dart';
import '../../../../../networks/rx_base.dart';

final class GetForgotPasswordResponseRX
    extends RxResponseInt<ResetResponseModel> {
  final api = ForgotPasswordApi.instance;

  GetForgotPasswordResponseRX(
      {required super.empty, required super.dataFetcher});

  ValueStream get getFileData => dataFetcher.stream;

  Future<bool> resetPassword({
    required String email,
  }) async {
    try {
      ResetResponseModel data = await api.resetPassword(
        email: email,
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
    if (error is DioException) {
      ToastUtil.showShortToast(error.response!.data["message"]);
    }
    log(error.toString());
    dataFetcher.sink.addError(error);
    // throw error;
    return false;
  }
}
