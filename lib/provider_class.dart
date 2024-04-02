import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'kakao_login_sdk.dart';

class UserInfo {
  final KaKaoLogIn _kakaologin = KaKaoLogIn();
  bool isLogined = false;
  User? user;

  Future login() async {
    isLogined = await _kakaologin.login();
    if (isLogined) {
      user = await UserApi.instance.me();
    }
  }

  Future logout() async {
    await _kakaologin.logout();
    isLogined = false;
    user = null;
  }
}
