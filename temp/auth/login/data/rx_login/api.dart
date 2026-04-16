import 'dart:convert';
import 'package:aion_project/features/auth/login/model/login_response_model.dart';
import 'package:aion_project/networks/exception_handler/data_source.dart';
import 'package:dio/dio.dart';
import '../../../../../networks/dio/dio.dart';
import '/networks/endpoints.dart';
import 'package:aion_project/constants/app_constants.dart';
import 'package:aion_project/helpers/toast.dart';
import 'package:aion_project/helpers/di.dart';

final class LogInApi {
  static final LogInApi _singleton = LogInApi._internal();
  LogInApi._internal();
  static LogInApi get instance => _singleton;

  Future<LoginResponseModel> logIn({required String email, required String password,}) async {
    try {

      Map data = {
        "email": email,
        "password": password,
      };

      Response response = await postHttp(Endpoints.logIn(), data);

      if (response.statusCode == 200) {
        final data = LoginResponseModel.fromRawJson(json.encode(response.data));
        
        
        //LoginModel loginModel = LoginModel.fromJson(response.data);

        if (data.token != null && data.token!.isNotEmpty) {
          // ****** AGGIUNGI QUESTE RIGHE PER SALVARE IL TOKEN ******
          appData.write(kKeyAccessToken, data.token!);
          print("Token salvato in GetStorage: ${data.token!}"); // Debug print

          
          // *******************************************************

          // Aggiorna Dio con il nuovo token
          DioSingleton.instance.update(data.token!);
          print("Dio Singleton aggiornato con il nuovo token."); // Debug print
          return data;

          
        } else {
          ToastUtil.showShortToast("Login fallito: ${response.data?['message'] ?? 'Credenziali non valide'}");
          
        }
        
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
      throw Exception("Login failed: Unable to retrieve a valid token.");
  } catch (error) {
    // Handle generic errors
    throw Exception("Login failed: ${error.toString()}");
    
  }
  }
}