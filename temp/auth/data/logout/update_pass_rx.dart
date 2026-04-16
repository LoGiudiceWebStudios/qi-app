// ignore_for_file: non_constant_identifier_names

import 'package:aion_project/helpers/di.dart';
import 'package:aion_project/networks/stream_cleaner.dart';
import 'package:rxdart/rxdart.dart';

import '../../../../constants/app_constants.dart';
import '../../../../networks/rx_base.dart';
import 'update_pass_api.dart';

final class GetLogoutRX extends RxResponseInt<Map> {
  final api = GetLogoutApi.instance;
  GetLogoutRX({required super.empty, required super.dataFetcher});
  ValueStream<Map> get Updatepassword => dataFetcher.stream;

  Future<void> logout() async {
    try {
      Map allData = await api.logout();
     await  handleSuccessWithReturn(allData) ;
    } catch (error) {
      handleErrorWithReturn(error);
    }
  }

  @override
  handleSuccessWithReturn(dynamic data) {
    dataFetcher.sink.add(data);
    appData.write(kKeyAccessToken, null);
    appData.write(kKeyIsLoggedIn, false);
    totalDataClean();
    return data;
  }
}
