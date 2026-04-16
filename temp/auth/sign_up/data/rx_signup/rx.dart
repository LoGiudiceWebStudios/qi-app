
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';
import '../../../../../helpers/toast.dart';
import '../../../../../networks/rx_base.dart';
import '../../model/signup_response_model.dart';
import 'api.dart';

final class GetSignupResponseRX extends RxResponseInt<SignUpResponseModel> {
  final api = SignupApi.instance;

  GetSignupResponseRX({required super.empty, required super.dataFetcher});

  ValueStream get getFileData => dataFetcher.stream;

  Future<bool> signup(
    {
    required String userName,
    required String email,
    required String password,
    required String confirmPw,
    }
  ) async {
    try {

      SignUpResponseModel data = await api.signup(
        userName: userName,
        email: email,
        password: password,
        confirmPw: confirmPw
      );
      handleSuccessWithReturn(data);
      return true;
    } catch (error) {
      return handleErrorWithReturn(error);
      
    }
  }

  // @override
  // handleSuccessWithReturn(SignUpResponseModel data) {
  //   appData.write(kKeyAccessToken, data.token);
  //   appData.write(kKeyIsLoggedIn, true);
  //   String token = appData.read(kKeyAccessToken);
  //   DioSingleton.instance.update(token);
  //
  //   dataFetcher.sink.add(data);
  //   return data;
  // }
  @override
  handleErrorWithReturn(dynamic error) {
    if(error is DioException){
      if(error.response!.statusCode == 422 ){
        ToastUtil.showShortToast(error.response!.data["message"]);
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
